# Support

Support are provided in the following ways:

* [Github issue tracker](https://github.com/osy86/HaC-Mini/issues)
* [InsanelyMac](https://www.insanelymac.com/forum/topic/339291-guide-hac-mini-osx-mojave-on-intel-hades-canyon-nuc8i7hvknuc8i7hnk/)
* [/r/Hackintosh Discord](http://discord.io/hackintosh)

Do **not** ask for help in tonymacx86 \(better yet, stop going to tonymacx86!\). They do not permit discussion of anything except for their own "approved" installation methods--which are all pretty problematic. We tried to provide help there in the past but was banned for linking to a non-tonymac approved guide.

## Known Issues

Outstanding issues are tracked and worked on in the [Github issues](https://github.com/osy86/HaC-Mini/issues). Some of the most common unresolved issues are documented here along with possible workarounds.

### [USB disconnected on sleep wakeup](https://github.com/osy86/HaC-Mini/issues/8)

This is a hardware issue and cannot be worked around without Intel support or extensive kernel patching. If you require a USB device to not be disconnected \(an external HDD for example\), you can use the blue USB 3.0 Type A port on the front of the NUC. This port is connected to the CPU directly \(does not go through the buggy PCH\) and does not exhibit the same wakeup issue. However, it does experience a separate issue where if you have the device connected before powering on, then it will get disconnected after the first sleep. You should either plug in the device after OSX boots or suffer a single disconnect before the issue goes away. 

### Only boot entry is "Windows Boot Manager"

Windows sometimes modifies the NVRAM variables for force the BIOS to only show Windows as a boot option. If you have an external media with OpenCore installed, you can use it to [reset the NVRAM](support.md#reset-nvram). If you do not have access to an external media with OC installed, you need to open the case and remove the BIOS Security Jumper \(see [section 2.2.3.4](https://www.intel.com/content/dam/support/us/en/documents/mini-pcs/nuc-kits/NUC8i7HVK_TechProdSpec.pdf)\) to reset all BIOS settings.

### Black screen powering up with TB DP display or TB port not working

If the Ridge controller crashes, you won't get DP output \(or anything else\) from the TB ports. Perform a hard reset by unplugging the power cord and plugging it back in. Then press the power button and wait until your keyboard shows up. Then press Ctrl+Alt+Del to soft-reset and you should see the display working again.

### Black screen after POST when booting up or after selecting boot drive

First get into the [boot picker menu](support.md#getting-into-boot-picker-menu), and boot into OSX. Then, you need to make sure the right startup device is selected in System Preferences -&gt; Startup Disk. Select your OSX installation you wish to boot into and press Restart. This should fix the issue for future boots.

## Troubleshooting

Before asking for help, make sure you try all the following troubleshooting advice first.

### Getting into boot picker menu

Reboot and when you see the boot logo, you need to hold or repeatedly tap the Alt key \(Opt key on Apple keyboards\). Sometimes holding works and sometimes tapping works and sometimes neither works. This is a known issue with OpenCore and you have to keep trying.

### Reset NVRAM

Sometimes incorrect settings and boot-args will cause issues. You need to [get into boot picker](support.md#getting-into-boot-picker-menu) and then select the NVRAM reset option.

### Reset BIOS

Make sure you are on the [latest BIOS version](https://downloadcenter.intel.com/product/126143). Also try resetting BIOS to factory settings and then re-do the [needed changes](../installation-guide/bios-settings.md).

### Remove Wifi Card

There are known compatibility issues with the [DW1820A](dw1820a-wifi.md). If you cannot boot, remove the card and try again.

### Reinstall HaC Mini

Follow the [existing install](../installation-guide/installation.md#update-existing-install) directions to update/reinstall the latest version of HaC Mini. This will replace your OpenCore settings but by default a backup will be created in /EFI-backups/OC. If you made changes to the configuration and a reinstall worked, you can try adding the changes back one at a time to see what is the cause of the issue.

### Disable any third party extensions

You can try booting into safe mode by holding Win+S \(Cmd+S on Apple keyboards\) during boot. If this does not work, [get into boot picker](support.md#getting-into-boot-picker-menu) and hold the keys while pressing the number corrosponding to your boot drive. If the issue is resolved check if any extension added in `/Library/Extensions` or `/System/Library/Extensions` are the cause by enabling them one at a time.

### Enable verbose boot

Modify `EFI/OC/config.plist` from the EFI partition and in `boot-args` add `-v keepsyms=1 debug=0x100` which will enable verbose boot, show debugging symbols, and disable restart on panic. If there is a panic, take a picture and include it in your support request.

