# Support

Check out the [Github Discussions](https://github.com/osy/HaC-Mini/discussions) for community discussion and support if you need help getting things set up. If you are running into issues or kernel panics or other bugs, please open a [Github issue](https://github.com/osy/HaC-Mini/issues) after doing a search to make sure the issue is not already reported. When opening an issue, please provide all the information in the template. If you are getting a panic or crash, please attach the crash log either as a text file or as a picture of the screen (if it crashes during boot). You need to [enable verbose logging](support.md#enable-verbose-boot) to see the crash log at boot.

## Known Issues

Outstanding issues are tracked and worked on in the [Github issues](https://github.com/osy86/HaC-Mini/issues). Some of the most common unresolved issues are documented here along with possible workarounds.

### [USB disconnected on sleep wakeup](https://github.com/osy86/HaC-Mini/issues/8)

This is a hardware issue and cannot be worked around without Intel support or extensive kernel patching. If you require a USB device to not be disconnected (an external HDD for example), you can use the blue USB 3.0 Type A port on the front of the NUC. This port is connected to the CPU directly (does not go through the buggy PCH) and does not exhibit the same wakeup issue. However, it does experience a separate issue where if you have the device connected before powering on, then it will get disconnected after the first sleep. You should either plug in the device after OSX boots or suffer a single disconnect before the issue goes away.

### Only boot entry is "Windows Boot Manager"

Windows sometimes modifies the NVRAM variables for force the BIOS to only show Windows as a boot option. If you have an external media with OpenCore installed, you can use it to [reset the NVRAM](support.md#reset-nvram). If you do not have access to an external media with OC installed, you need to open the case and remove the BIOS Security Jumper (see [section 2.2.3.4](https://www.intel.com/content/dam/support/us/en/documents/mini-pcs/nuc-kits/NUC8i7HVK\_TechProdSpec.pdf)) to reset all BIOS settings.

### Black screen powering up with TB DP display or TB port not working

If the Ridge controller crashes, you won't get DP output (or anything else) from the TB ports. Perform a hard reset by unplugging the power cord and plugging it back in. Then press the power button and wait until your keyboard shows up. Then press Ctrl+Alt+Del to soft-reset and you should see the display working again.

### Black screen after POST when booting up or after selecting boot drive

First get into the [boot picker menu](support.md#getting-into-boot-picker-menu), and boot into OSX. Then, you need to make sure the right startup device is selected in System Preferences -> Startup Disk. Select your OSX installation you wish to boot into and press Restart. This should fix the issue for future boots.

If this happens during an OSX upgrade, you need to manually select the updater option. After the upgrade is complete, you can configure the Startup Disk.

## Troubleshooting

Before asking for help, make sure you try all the following troubleshooting advice first.

### Getting into boot picker menu

Reboot and when you see the boot logo, press F10 when starting up the computer and you should see the BIOS boot menu.

* If you see the name of your boot device, select it and immediately tap the Alt key (Opt key on Apple keyboards) until the OpenCore boot picker shows up.
* If you see one entry for "OpenCore", select it and immediately tap the Alt key repeatedly (Opt key on Apple keyboards) until the OpenCore boot picker shows up.
* If you see multiple entries for "OpenCore" or if selecting it fails (for example, it throws you back in the BIOS menu), then you need to reset your BIOS settings and follow the [first part of the guide](../installation-guide/bios-settings.md) again.

### "This copy ... is damaged, and can’t be used to install macOS."

If you get this message while installing, make sure your BIOS clock is set to the correct time and that you are connected to the internet.

If that did not solve the issue, follow the [install instructions](../installation-guide/installation.md) again starting from the top, but this time do not select "Patch OSX Installer" after running the package. Finally, after installation, you have to follow the [upgrade instructions](../installation-guide/installation.md#update-existing-install).

### "The Installer encountered an error that caused the installation to fail."

If you get this error while trying to install the HaC mini package, it is because the installer script failed. There are two common causes:

1. Your drive is not [formatted as GUID](../legacy-guide-clover/legacy-installing-osx.md#preparing-installer-usb).
2. You do not have Xcode or Xcode Command Line Tools installed. (Run `xcode-select --install` in Terminal to resolve.)

If those do not solve the issue, [create a new issue on GitHub](https://github.com/osy/HaC-Mini/issues/new?assignees=\&labels=installer\&template=installer-bug-report.md\&title=) and attach the file `/var/log/install.log`.

### Cannot boot when "secure boot" is enabled

If you enable secure boot from the installer, you may not be able to boot into an existing macOS installation or the installer for a new installation. The reason for this is because macOS will be personalized with a random value generated by the installer. This means that you can no longer boot with OpenCore installed to a USB drive as the random value will be different. If you did not install macOS with secure boot enabled, you can either re-install macOS or boot into recoveryOS and run the following command

`$ bless --folder "/Volumes/Macintosh HD/System/Library/CoreServices" --bootefi --personalize`

Replace "Machintosh HD" with the name of the partition containing the macOS install that will not boot. If you run into an error, make sure you do not have two SSDs installed (temporarily disable one from BIOS), then run First Aid from Disk Utility, and also make sure you are connected to the internet and can ping apple.com (from recoveryOS).

### Reset NVRAM

Sometimes incorrect settings and boot-args will cause issues. You need to [get into boot picker](support.md#getting-into-boot-picker-menu) and then select the NVRAM reset option.

### Reset BIOS

Make sure you are on the [latest BIOS version](https://downloadcenter.intel.com/product/126143). Also try resetting BIOS to factory settings and then re-do the [needed changes](../installation-guide/bios-settings.md).

### Remove/disable Wifi Card and second M.2 drive

There are known compatibility issues with the [DW1820A](dw1820a-wifi.md) and the Intel wireless card. There are also known issues with having a second M.2 drive installed (for example Boot Camp Utility does not work if you have two internal drives). One troubleshooting advice is to disable the hardware in BIOS and see if the problem persists. Alternatively, you may wish to physically remove the hardware while debugging the issue.

### Reinstall HaC Mini

Follow the [existing install](../installation-guide/installation.md#update-existing-install) directions to update/reinstall the latest version of HaC Mini. This will replace your OpenCore settings but by default a backup will be created in /EFI-backups/OC. If you made changes to the configuration and a reinstall worked, you can try adding the changes back one at a time to see what is the cause of the issue.

### Disable any third party extensions

You can try booting into safe mode by holding Win+S (Cmd+S on Apple keyboards) during boot. If this does not work, [get into boot picker](support.md#getting-into-boot-picker-menu) and hold the keys while pressing the number corrosponding to your boot drive. If the issue is resolved check if any extension added in `/Library/Extensions` or `/System/Library/Extensions` are the cause by enabling them one at a time.

### Enable verbose boot

Rerun the HaC Mini installer and select the following options: Verbose Boot, Debug mode, Reset boot-args. If this fails, try it without "Reset boot-args" and then [reset NVRAM](support.md#reset-nvram). If there is a panic, take a picture and include it in your support request.
