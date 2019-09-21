# USB Fix

## Wakeup Detection

The first issue can be observed with darkwake enabled and the device is woken up from USB. The computer wakes up but not the monitor. You need a second keyboard press or some other wake event to power up the monitor as well.

The first workaround proposed was to disable the darkwake feature. Dark wake is Apple's term for a partial wakeup where background tasks can run but the display and some other services will not run. It's primary use is that the computer can wake up on a timer in order to do tasks like check email and get notifications. It can also be paired with wake-on-lan for remote SSH and other remote tasks. Note that dark wake is distinct from the Apple advertised Power Nap feature, which has similar functionality but \(in theory\) uses less power in the background tasks because it does not have to wake up the processor at all.

Unfortunately, if we turn off dark wake then these periodic wakeups will also wake up the display which can be annoying. If you turn off periodic wakeups then you lose all the functionalities of that feature. We will root cause the issue and then attempt to fix it.

How does USB sleep & wakeup work? In ACPI S3 sleep \(suspend-to-RAM\), all the chipsets are either powered off or placed into a low power mode \(if supported\). The processor tells the PCH to enter S3. The PCH tells the USB XHCI controller to enter D3. The XHCI host side is a PCIe interface with [PCI power management](https://lekensteyn.nl/files/docs/PCI_Power_Management_12.pdf) capabilities. The XHCI client side is a USB PHY interface which connects to the USB keyboard \(or whatever\). The keyboard is asked to enter a USB defined low power state, then the XHCI controller itself enters D3.

When you press a key on the keyboard, the USB device sends an interrupt to the USB XHCI controller which wakes it up. The XHCI controller then wakes up the PCH which wakes up the processor through the PCIe interface through the PME\# signal. The PCH maps all the PME\# signals from its various internal controllers into a single GPE, which is seen by the processor. On the Intel 100 series PCH, the USB, LAN, HDA, and SATA controllers share a single GPE \(0x6D\). These controllers are seen by the processor as separate PCIe devices, but are all implemented internally in the PCH \(a single chip\) and controls different protocols. As an aside, the PCH also has PCIe controllers which acts as a PCIe root bus to the processor. The PME\# signals for those map to a separate GPE \(0x6B\).

If multiple PCI devices can map to a single GPE interrupt signal, then how does the operating system know which device caused the interrupt? There are two ways OSX checks.

First, if the system has an [Embedded Controller](https://en.wikipedia.org/wiki/Embedded_controller) \(most modern laptops do for battery management\), then the GPE is effectively ignored \(it's seen as a "legacy feature"\). The EC provides much more information about what caused the interrupt and can even differentiate between events such as "low battery" and "battery charged" even though they come from the same event source.

On the NUC \(and many other desktop systems\), there is no EC and then OSX falls back to using the GPE. By querying the ACPI tables, OSX can get a list of all possible event sources corresponding to a single GPE. It then does a series of filtering actions. First, it removes duplicates \(any device that shows up both as an ACPI device and a PCI device\). Then, for each PCI device, it queries the PMCS register to look at PM\_Status. PM\_Status is set to 1 by hardware when PME\# is asserted \(remember, this signal is what wakes up PCH, which wakes up the processor\). Here's the confusing part: when you write a 1 back to PMCS.PM\_Status by the processor, it _clears_ PM\_Status. This allows OS designers to read PMCS once, then write the same value back which clears it. Then it will only be set again by the next PME\# and prevent any race condition. OSX looks for any PCI device corresponding to the GPE that has PM\_Status set to 1. \(It will not clear it, but instead much later in the wakeup process, the IOPCIDevice driver will clear it.\) Finally the list of potential wake sources is created from the filtered set: any PCI power management capable device with PM\_Status set, any PCI devices without power management, and then any non-PCI devices. For each potential wake source, a device property `acpi-wake-type` is queried \(such as user, timer, networking, etc\). Then out of all the potential wake sources, the wake type with the highest priority \(for example any user triggered wakeup takes priority over stuff like battery notifications or timers\) becomes the `Wake Type` written to IOPMrootDomain for XNU to act upon.

The first problem we run into is that the XHCI device does not have `acpi-wake-type`. My guess is that because GPE handing is legacy code, so there's no Apple code that adds it \(I can't find it in any Mac ACPI dumps\). All modern Macs have an EC. We can use Clover/OpenCore's property injection to add `acpi-wake-type` set to `1` for `User`. If every wake source doesn't have that property, then the default action from XNU is a darkwake.

But that doesn't work. The reason why took a long time of reverse engineering the BIOS.

### Intel Errata

Intel released an [errata](https://www.intel.com/content/www/us/en/products/docs/chipsets/100-series-chipset-spec-update.html) \(which they call "specification updates" because that's better marketing\) for the 100 series PCH. If you read the list, of all the hardware issues \(47 of them\), none of them are "bad" enough for Intel marketing to feel the need to revise the chip. Instead, each bug is either deemed not a real issue, or some workaround is implemented in the driver and/or BIOS. \(Aside: this is one reason why USB is full of problems.\)

Let's look at issue 41 titled _USB2.0 PLL may fail to lock during S3 resume_.

> When a system is woken from S3 using a USB2.0 device, the USB2.0 PLL may fail to lock during the initialization process. Then, the eXtensible Host Controller may not send the Start of Frame \(SOF\) packets at the correct interval as specified per USB 2.0 specification.
>
> USB2.0 devices may not enumerate correctly or yellow bang after resuming from S3.
>
> **A BIOS code change has been identified and may be implemented as a workaround for this erratum.**

You don't have to understand the issue itself, only that it necessated a BIOS change. After reversing the SiInit BIOS module, I found the following PCH XHCI init code.

```c
int XhciInit(char *PciConfigBase, char *MmioBase)
{
...
  v22 = PchSeries(MmioBase);
  v20 = PchStepping();
  v19 = PchGeneration();
  v4 = *(_DWORD *)(MmioBase + 0x8008);
  v21 = (*(_DWORD *)(MmioBase + 0x8028) >> 8) & 0xFF;
  *(_BYTE *)(PciConfigBase + 0x41) |= 1u;
  *(_BYTE *)(PciConfigBase + 0x42) |= 0x34u;
  v5 = v22 == 2;
  *(_DWORD *)(PciConfigBase + 0x44) |= 0xFC688u;
  *(_DWORD *)(PciConfigBase + 0x50) = 0xFCE6E5F;
  if ( v5 )
    *(_DWORD *)(MmioBase + 0x80C0) &= 0xFFFFFBFF;
  *(_WORD *)(PciConfigBase + 0x74) |= 3u;
  SleepUS(20);
  *(_BYTE *)(PciConfigBase + 0x74) &= 0xFCu;
  *(_BYTE *)(PciConfigBase + 0x41) |= 1u;
  *(_BYTE *)(PciConfigBase + 0x42) |= 0x34u;
  *(_DWORD *)(PciConfigBase + 0x44) |= 0xFC688u;
...
}
```

What this does is beyond the scope of this post, but it basically uses a bunch of undocumented registers \(undocumented in series 100, but [documented in another similar chip](https://www.intel.cn/content/dam/www/public/us/en/documents/datasheets/pentium-celeron-n-series-j-series-datasheet-vol-2.pdf)\) to work around the USB 2.0 PLL issue above. The only thing we care about is this line

```c
*(_WORD *)(PciConfigBase + 0x74) |= 3u;
```

Referring back to the [PCI power management](https://lekensteyn.nl/files/docs/PCI_Power_Management_12.pdf) specs, this reads PMCS and then writes back the value ORed with 3 \(indicating request to enter D3 state\). Remember what we said about PMCS.PM\_Status earlier? This effectively clears PMCS.PM\_Status if it is set because it writes the same value back. **So what Intel did here is introduce a PCI specification violation in their software workaround to a hardware bug in their PCH chip.** Digging around the errata documents for various Intel PCH chips, it seems like the same issue exists in other chips as well. So on any of these systems, PMCS for XHCI is broken.

### Workaround

So now that we understand the issue, our workaround for the issue introduced by Intel's workaround is simple. We create a new "fake" \(non-PCI\) ACPI device and claim that it is associated with the 0x6D GPE. Then we add the `acpi-wake-type` property to the fake device with a fake driver. Then when OSX attempts to identify the "source" of the wakeup, it will see our fake device and assume that was the source.

But that's not all. Remember there is a priority of wake types? Remember that GPE 0x6D is shared with LAN, HDA, and SATA? Well HDA and SATA don't have a special wake type, so they're the same priority as USB. But LAN falls under the "Network" type which has lower priority than USB's "User" type. A proper fix would have to somehow differentiate between a USB wakeup and a LAN wakeup. It might not even be possible due to Intel trashing the USB's PMCS register. Fortunately for us though, the third party LAN drivers we use don't support wake-on-lan so it's not an issue.



