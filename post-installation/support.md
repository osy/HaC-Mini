# Support

Support are provided in the following ways:

* [Github issue tracker](https://github.com/osy86/HaC-Mini/issues)
* [InsanelyMac](https://www.insanelymac.com/forum/topic/339291-guide-hac-mini-osx-mojave-on-intel-hades-canyon-nuc8i7hvknuc8i7hnk/)
* [/r/Hackintosh Discord](http://discord.io/hackintosh)

Do **not** ask for help in tonymacx86 \(better yet, stop going to tonymacx86!\). They do not permit discussion of anything except for their own "approved" installation methods--which are all pretty problematic. We tried to provide help there in the past but was banned for linking to a non-tonymac approved guide.

## Troubleshooting

Before asking for help, make sure you try all the following troubleshooting advice first.

### Getting into boot picker menu

Reboot and when you see the boot logo, you need to hold or repeatedly tap the Alt key \(Opt key on Apple keyboards\). Sometimes holding works and sometimes tapping works and sometimes neither works. This is a known issue with OpenCore and you have to keep trying.

### Reset NVRAM

Sometimes incorrect settings and boot-args will cause issues. You need to [get into boot picker](support.md#getting-into-boot-picker-menu) and then select the NVRAM reset option.

### Reinstall HaC Mini

Follow the [existing install](../installation-guide/installation.md#update-existing-install) directions to update/reinstall the latest version of HaC Mini. This will replace your OpenCore settings but by default a backup will be created in /EFI-backups/OC. If you made changes to the configuration and a reinstall worked, you can try adding the changes back one at a time to see what is the cause of the issue.

### Disable any third party extensions

You can try booting into safe mode by holding Win+S \(Cmd+S on Apple keyboards\) during boot. If this does not work, [get into boot picker](support.md#getting-into-boot-picker-menu) and hold the keys while pressing the number corrosponding to your boot drive. If the issue is resolved check if any extension added in `/Library/Extensions` or `/System/Library/Extensions` are the cause by enabling them one at a time.

### Enable verbose boot

Modify `EFI/OC/config.plist` from the EFI partition and in `boot-args` add `-v keepsyms=1 debug=0x100` which will enable verbose boot, show debugging symbols, and disable restart on panic. If there is a panic, take a picture and include it in your support request.

