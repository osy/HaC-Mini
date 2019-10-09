# Thunderbolt 3 Fix \(Part 2\)

[In the last series](thunderbolt-3-fix.md), we discussed how to get the system to power on the Thunderbolt controller, how to detect hotplug events, and getting it all to work on warm boot as well. For all intents and purposes, most Thunderbolt devices work with this setup. However, that was, at best, a halfway solution. While devices were getting detected, they essentially operate in a compatibility mode where OSX sees the Thunderbolt PCI bridge as a generic PCI bridge device and the devices get set up, enumerated, and show up on the bridge thanks to a processor running side of the Alpine Ridge chip \(the ICM firmware\). Noticeably what's missing is the matching of OSX's Thunderbolt controller drivers and along with it any power saving functionalities, cable detection, updating of device firmware, and compatibility with TB devices that require special drivers.

The main reason for this incompatibility is because on Macs, the OSX driver handles low level tasks like link management manually while on non-Macs, the ICM firmware takes care of everything and just exposes a PCI bridge to the computer. If you try to send these low level commands, the controller will not respond. This has been a sore spot for the Linux-on-Macs community, and they have a [more in-depth explanation of the differences](https://lwn.net/Articles/707616/). Windows only supports ICM managed mode, so on Macs running Bootcamp, Apple's ACPI code will reset the controller to enable this ICM mode. We find a similar function in the Linux kernel as well along with Intel documented names and comments.

As an aside, there is no public documentation for these Ridge controllers from Intel. Aside from reverse engineering OSX code and ACPI code, the main source of information comes from the [Linux code from reverse engineered Apple drivers](https://github.com/intel/thunderbolt-software-kernel-tree/tree/master/drivers/thunderbolt), the [Intel Linux code for Thunderbolt networking](https://github.com/intel/thunderbolt-software-kernel-tree/tree/networking/drivers/thunderbolt/icm), and the [EDK-II platform code for Kaby Lake](https://github.com/tianocore/edk2-platforms/tree/master/Platform/Intel/KabylakeOpenBoardPkg/Features/Tbt). I will attempt to digest all that information and present here, step by step, how the Alpine Ridge controller is powered on, initialized, and interfaced with by OSX.

### Power Up

When the computer powers on, if there is no device plugged into the TB3 port, then the Ridge will be power gated. Since this is outside of the PCI power management, to the PCI bus, it appears that there is no device attached. This is where [force power](thunderbolt-3-fix.md#force-power) comes in. This GPIO signal will tell the Ridge to turn on even if no device is plugged in. There appears to be two separate power domains for the Thunderbolt host and the XHCI host. If you boot with only one device attached, the host that is not used will be power gated. On Macs, a separate GPIO signal controls the power gating for each power domain. On other platforms, there is a single GPIO that controls both.

If powered on with a device attached, the Ridge will set it up through the ICM firmware and when the operating system does PCI enumeration, it will see the bridge and the device attached to it.

If powered on with the force power GPIO, the Ridge will identify itself with a PID of `0xFFFFFFFF`. This is because most code that detects if a PCI device exists will read the PID register and check that it is NOT `0xFFFFFFFF`. Effectively, the Ridge is cloaking itself when it is powered on without any devices attached. I can only speculate that it is for some weird compatibility reasons. For the PID to show up properly, the CPU uses a pair of undocumented registers in the PCI configuration space at offset `0x54C`. It writes `0xD` to register `0x54C` and then polls `0x548` until bit 0 is set. According to the [openboard UEFI source](https://github.com/tianocore/edk2-platforms/blob/master/Platform/Intel/KabylakeOpenBoardPkg/Features/Tbt/Include/Library/TbtCommonLib.h#L17-L18), these are mailbox registers for communicating with the Ridge host controller. The NUC's ACPI code will do this handshake automatically on init through a method called `OSUP`. This OSUP command seems to be a way for the CPU to indicate to the Ridge that it is out of BIOS/DXE mode and is in the OS proper and therefore is safe for it to come out and declare its PID to the world.

### ICM Reset

Now we can power on the Ridge and get it recognized by the PCI enumerator. However, when OSX matches the Thunderbolt Ridge drivers, the driver code dies waiting for a response to the command it sends to get the NHI interface to identify the controller. This goes back to the ICM firmware. In ICM managed mode, packets sent to the host controller seem to be ignored. This makes sense because the OS is not supposed to be communicating with the host controller; it is the ICM firmware's responsibility. Therefore, we need to turn off the ICM. Luckily, Intel's Linux code has a method for _starting_ the ICM \(presumably on Macs where it is not started by default\).

```c
static int icm_firmware_reset(struct tb *tb, struct tb_nhi *nhi)
{
    struct icm *icm = tb_priv(tb);
    u32 val;

    if (!icm->upstream_port)
        return -ENODEV;

    /* Put ARC to wait for CIO reset event to happen */
    val = ioread32(nhi->iobase + REG_FW_STS);
    val |= REG_FW_STS_CIO_RESET_REQ;
    iowrite32(val, nhi->iobase + REG_FW_STS);

    /* Re-start ARC */
    val = ioread32(nhi->iobase + REG_FW_STS);
    val |= REG_FW_STS_ICM_EN_INVERT;
    val |= REG_FW_STS_ICM_EN_CPU;
    iowrite32(val, nhi->iobase + REG_FW_STS);

    /* Trigger CIO reset now */
    return icm->cio_reset(tb);
}
```

This matches up with what we see in the `ICMS` ACPI method dumped from an iMac for setting up ICM on Bootcamp. By replicating the `ICMS` ACPI method and masking out the `REG_FW_STS_ICM_EN_CPU` flag, we can disable the ICM firmware.

### Power Management

On Windows, Thunderbolt power management is handled by the ICM. Because we are asserting "force power" and disabling the ICM, we lose any hope of responsible energy usage. According to LWN, the controller uses 2W on idle. Macs implement the power management for the Ridge through ACPI. Why not through the OSX driver like most other PCI devices? The answer is in the strange architecture of the Ridge Thunderbolt controllers. Essentially, two host controllers are exposed to the operating system: the Thunderbolt NHI controller and the USB XHCI controller. Both are controlled by their respective drivers and uses PCI power management \(D-states\) and can support PCI active link power management. Additionally, USB 2.0 legacy devices can be supported through a "companion" controller \(usually the PCH XHCI controller\) instead of directly by the Ridge. All this means that for effective power management beyond that offered through the PCI specifications \(which leaves us with the 2W under idle\), the three controllers must communicate with each other. However, the code can get rather messy so Apple opted to do the dirty work in ACPI instead.

#### XHCI

On the XHCI side, first we must talk about the companion controller. The concept of USB companion controllers were popular when USB 3.0 was just starting to be adopted. At the time, some XHCI controllers do not support legacy mode so OEMs opted to use a separate EHCI controller for most of their ports and add a XHCI controller for the one or two USB 3.0 ports. Because those 3.0 ports must support EHCI as well, they can either be physically wired to both controllers or use some software hand off mechanism. The companion controller seems to have fallen out of favor as most XHCI controller supports legacy mode and the complexity of companion controllers are painful to deal with.

For some reason, Intel decided to use companion controllers with the NUC's TB3 ports and Apple has also done it with their TB3 ports. It doesn't seem like compatibility is the issue because the Alpine Ridge does support USB 2.0 on its own XHCI controller and other OEMs have designed it that way. Regardless of why, to support power management, the Ridge XHCI controller must know when the companion USB 2.0 port is idle. OSX handles this by some custom ACPI entries on both controllers.

A second issue is that the XHCI controller must do a cable detection check to know if a port is not used or just idle with a plugged in device. Since cable plug management is taken care of from the NHI side, it looks for an ACPI method called `MODU` to return the current cable state.

When the XHCI driver sees that all the idle conditions are met, it calls an ACPI method `RTPC` to signal that it is ready to be turned off. Then it enters D3 PCI power state and waits.

#### NHI

On the Thunderbolt NHI side, an ACPI method called `MUST` is invoked whenever the cable plug state changes. This change will be reported by `MODU` when the XHCI driver queries it. The NHI driver calls its own `RTPC` when it is ready to be turned off and then it also enters D3.

#### ACPI

OSX's PCI bridge driver will automatically put the bridge into D3 when all its children are in D3 and power management is enabled. Any PCI power transition will invoke the `_PSx` ACPI method \(`x` is the state number\). In the `_PS3` handler for the port where the Ridge attaches to, if it detects that `RTPC` was called for both XHCI and NHI, then it will power off the Ridge. If any device needs to wake up, then OSX would first have to wake up the PCI bridge to D0 and call `_PS0`, which can re-assert the force power.

To put everything together, on the NUC, we have to re-disable the ICM firmware after power-up. However, this is a bit tricky because we need to access the NHI device to reset ICM and it is located a few PCI bridges down. When the root port's `_PS0` is called, everything below it is still in D3 state. Therefore, we can set a flag indicating that we need to reset ICM as soon as the NHI device is up. Then in the NHI's `_PS0` handler, we do the actual ICM reset.

