# Installation

The HaC Mini installer will install the OpenCore bootloader along with patches, configurations, and drivers for a fully working Hackintosh.

### Installer Download

[Github](https://github.com/osy86/HaC-Mini/releases)

## New Install

A brand new clean install is the recommended way. Existing installations may have unneeded patches/hacks that conflict with HaC Mini and cause issues. OSX "distributions" and pre-made generic installers \(such as MultiBeast\) are **highly discouraged** for any machine and especially NUC Hades Canyon because they contain many outdated and broken patches.

### Prerequisites

* A Mac or another Hackintosh to prepare the installer
* macOS 10.14.5+ installer
* USB flash drive with at least 16GB of storage

{% hint style="info" %}
Please note that OSX software license prohibits running it on non-Apple hardware.
{% endhint %}

### Creating OSX Installer

{% hint style="warning" %}
Note all data on the USB drive **will be erased**.
{% endhint %}

1. On another OSX machine \(or another Hackintosh\), download **macOS Mojave** or higher from the [App Store](https://apps.apple.com/us/app/macos-mojave/id1398502828).
2. Insert your USB drive and open up Terminal.
3. Open up Disk Utility to format your USB drive:
   1. Find your USB drive in the left sidebar under External \(if there are multiple sub-drives under your USB drive, select the top-most one\). You may need to choose **View** -&gt; **Show All Devices** in order to see the full disk.
   2. Press the "Erase" button on the top toolbar.
   3. Give the name **Installer** and make sure to select **GUID Partition Map** as the Scheme.
   4. Press Erase, wait until it completes, and quit Disk Utility.
4. Open up Terminal and create the installer
   1. Run the following command `sudo "/Applications/Install macOS Mojave.app/Contents/Resources/createinstallmedia" --volume /Volumes/Installer` and type in your password when prompted.
   2. Wait for the process to complete. This can take around 30 minutes to an hour.

### Patching OSX Installer

We will use the HaC Mini installer \(link at top of the page\) to modify the vanilla OSX installer to install HaC Mini automatically after OSX installation completes.

1. Make sure your OSX installer USB is inserted and open **HaCMini.pkg**
2. Continue with the install until you reach the _Installation Type_ page.
3. Press _Change Install Location..._
4. Select your OSX installer USB from the list of destinations.
   1. Make sure you do **not** select your booted drive or you will install HaC Mini on the computer you're currently using.
   2. If the OSX installer USB cannot be selected, make sure the installer is for OSX 10.14.5 or later.
5. Press _Continue_ and then _Customize_
6. Make sure to check _Patch OSX installer_
   1. If the option is disabled, make sure you selected the OSX installer USB as the destination in the previous step.
7. Press _Install_ and finish the installation.

### Installing macOS

{% hint style="warning" %}
We will be doing a clean installation. That means the SSD will be wiped and **any existing data will be lost**. If you plan to boot Windows and/or Linux, it is advised that you install those systems after OSX.
{% endhint %}

1. Insert your newly created USB installer into any USB slot and power on the NUC.
2. Press **F2** to enter BIOS and in **Boot** -&gt; **Boot Priority**, make sure your USB drive is first.
3. Reboot and you should boot into the OSX installer
   1. If not, you need to [get into the boot picker](../post-installation/support.md#getting-into-boot-picker-menu) menu and select the installer.
4. The OSX installer should load.
   1. Partition your SSD using **Disk Utility**. You may need to choose **View** -&gt; **Show All Devices** in order to find your drive. You should wipe the entire drive and format it as APFS with GUID Partition Map. This will also create the EFI and Recovery partitions.
   2. Installation will reboot a few times. Because USB has first boot priority, you do not have to touch anything.
5. After installation completes, you can remove the USB and boot from your SSD. You can revert the boot priority changes if desired.

## Update Existing Install

If you have an existing working Hackintosh installed on your NUC Hades Canyon, you can upgrade to HaC Mini with OpenCore for a more stable experience. You should also follow these steps when a new release of HaC Mini comes out. You do not need to follow these steps if you already done a clean install with the steps above.

{% hint style="danger" %}
You should never use MultiBeast or similar OSX "distributions" as they include broken and outdated patches and are not customized for your specific system. If you use a distribution, it is recommended that you back up your system then follow the "clean install" instructions above and then restore your files.
{% endhint %}

1. Download the installer and run **HaCMini.pkg**
2. Run the installer to completion
3. If you've selected to install _Native Thunderbolt_ support, run **Thunderbolt Patcher** from Applications after rebooting and patch your Thunderbolt controller.
4. If you're updating from an OpenCore release \(v2.0+\) then your previous serial will be preserved by default. If you're updating from a Clover release \(v1.x\), then a new serial will be generated. If you wish to use your old values, you need to manually edit `EFI/OC/config.plist` and copy the values over from `EFI/Clover/config.plist`.

