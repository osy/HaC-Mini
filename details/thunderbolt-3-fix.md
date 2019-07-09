# Thunderbolt 3 Fix

Getting Thunderbolt 3 working completely in Hackintoshes require patches to the ACPI tables. There are quite a few issues to resolve so we fix them up one at a time.

### Force Power

The first issue is that if a TB3 or USB-C device is not plugged in during boot, then OSX does not recognize the TB3 chip at all. This is due to a power-saving feature in the controller. The BIOS can power gate the TB3 controller until Windows wants to use it. Yes, Windows. This is implemented through a custom ACPI interface that is \(supposed\) to be unique to windows called the WMI. There is a Linux implementation of WMI and we can use that to understand how force power works.

We see that a [WMI device](https://github.com/torvalds/linux/blob/master/drivers/platform/x86/intel-wmi-thunderbolt.c) implemented a function with UUID `86CCFD48-205E-4A77-9C48-2021CBEDE341` which lets the OS power on the TB3 controller.

On OSX, it's not as easy because the PCI drivers does not play well with a non-hotplug device that can power on independent of the device's PCI power management functions. If you try to write a device driver for the WMI device and manage to power on the controller, it still will not work 100% of the time because there is a race with the PCI drivers which enumerates the PCI devices. It seems that having PCI verbose logging is the only way to trigger the TB force power mechanism consistently.

A better solution is to write a custom Clover driver that powers on the TB3 controller _before_ XNU boot and [thanks to al3x](https://github.com/osy86/ThunderboltPkg), that solves the race issue with trying to do force power during XNU boot. We also do the force power during sleep resume by using the device's `_PS0` ACPI function. XNU calls it during wakeup.

### Hotplug Event

Next, we have to implement hotplug support. If we dump the SSDT from a TB3 MacBook, we can find a lot of hotplug related code but it's quite a daunting task to port it to the NUC because it's filled with references to device-specific ports, offsets, and addresses. Instead, it's easier to focus on just the reserved objects \(ones that starts with an underscore\). The reasoning here is that anything that isn't a reserved object \(usually\) isn't seen by the OS so we don't really care what they do aside from providing functionality to the reserved objects. \(In programming terms, a reserved object is like an exported/global object while everything else are static objects\).

Taking a look at the 2016 MBP, we see that `_GPE._L33` calls `AMPE` which calls `Notify (_SB.PCI0.RP09.UPSB.DSB0.NHI0, Zero)`. We know \(from reading the ACPI specifications\) that `_GPE._Lxx` are level-triggered events \(in order words an interrupt wire is tripped\). We know that `Notify` with the second argument of zero means that it's notifying a change in the bus state. So from this we deduce that the OSX kernel expects a notification on the `NHI0` device when the hotplug wire is tripped. `Notify` calls into the kernel itself and the hotplug is handled.

Since hotplug works in Linux, we know that the NUC implemented the same functionality differently. Our task is to "rewire" the NUC's hotplug functionality into something that OSX recognizes.

We start by locating the TB3 root PCIE hub which happens to be named `RP05`. We look for any `_GPE` that triggers a `Notify` on `RP05` with the second argument of zero because we know that the code will be related in some way to bus state changes. There is only one candidate:

`_GPE._E20` calls the local method `XTBT` which calls `NTFY` which eventually calls `Notify (_SB.PCI0.RP05, Zero)`. It seems like the reason why hot-plug doesn't work is that OSX expects an notification on the NHI device \(`RP05.UPSB.DSB0.NHI0`\) while the NUC notifes the root device \(`RP05`\). To resolve this _disconnect_ \(haha get it\) in the understanding, we can patch `NTFY` to alert the right device.

Before we can do that though, we have to define the right device in a custom SDST table. We can do that like so

```text
    Scope (\_SB.PCI0.RP05)
    {
        Scope (PXSX)
        {
            Device (DSB0)
            {
                Name (_ADR, Zero)  // _ADR: Address
                
                Device (NHI0)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Name (_STR, Unicode ("Thunderbolt"))  // _STR: Description String
                }
            }
        }
    }
```

Now that we have a name for this device \(`RP05.PXSX.DSB0.NHI0`\), we can refer to it with `Notify`. Since we can only add, not replace, ACPI objects, we need to use Clover's patching capabilities. We rename the original `NTFY` implementation to `XTFY` as the name is unused, and we get it out of the way. Then we implement `NTFY` as follows

```text
    Scope (\_GPE)
    {
        // use NUC's own hot plug detection
        Method (NTFY, 1, Serialized)
        {
            Switch (ToInteger (Arg0))
            {
                Case (0x05)
                {
                    Notify (\_SB.PCI0.RP05.PXSX.DSB0.NHI0, Zero) // TB3 controller
                }
            }
        }
    }
```

And now, hot plug works! But waking from sleep doesn't restore our TB3/USB-C devices. This is because we are missing the other call to `Notify` that happens in `_WAK` \(called on wakeup\).

`_WAK` calls local method `RWAK` which eventually wakes up the right port if there is a device connected:

```text
            If ((\_SB.PCI0.RP05.VDID != 0xFFFFFFFF))
            {
                Notify (\_SB.PCI0.RP05, Zero)
            }
```

Once again, we cannot update existing code so we have to get creative to hook the right call. We use Clover again to remake `RWAK` to `XWAK`. Now we can re-write `RWAK` into our own implementation with the right changes but it's a lot of code \(and a lot unrelated to TB3\) and we might mess up something else. Instead what we do is call the original `RWAK` in our new `RWAK` first and then do the TB3 notification stuff as well.

```text
    Method (RWAK, 1, Serialized)
    {
        XWAK (Arg0)

        If (((Arg0 == 0x03) || (Arg0 == 0x04)))
        {
            If ((\_SB.PCI0.RP05.VDID != 0xFFFFFFFF))
            {
                Notify (\_SB.PCI0.RP05.PXSX.DSB0.NHI0, Zero) // TB3 controller
            }
        }

        Return (Package (0x02)
        {
            Zero, 
            Zero
        })
    }
```

### USB Companion Device

We might notice that a USB 2.0 device plugged into an adapter doesn't work with hotplugging. This is because the TB3 XHCI controller does not handle USB HS/LS and instead passes it along to the system's other XHCI controller. OSX calls these "companion" controllers and if we reproduce what the 2016 MBP does, we can see how the companion controllers find each other. On the NUC, the processor `XHC` bus hosts the HS USB companion ports \(we boot up with the USB 2.0 device attached and see that `HS12` and `HS13` are the right ports\). We make sure that the USB Injector knows this and injects the proper properties. We also make sure to inject the companion properties as well.

Finally, there is an annoying quirk in the NUC's SDST tables. The TB3 XHC device is also called `XHC` and since the companion port matching is by name, we can't have both XHC devices have the same name. The fix is to rename the TB3 device to `XHC2` and we can do that with Clover.



