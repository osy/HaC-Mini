# Installation

The HaC Mini installer will install the OpenCore bootloader along with patches, configurations, and drivers for a fully working Hackintosh.

### Installer Download

[Github](https://github.com/osy86/HaC-Mini/releases)

## New Install

A brand new clean install is the recommended way. Existing installations may have unneeded patches/hacks that conflict with HaC Mini and cause issues. OSX "distributions" and pre-made generic installers (such as MultiBeast) are **highly discouraged** for any machine and especially NUC Hades Canyon because they contain many outdated and broken patches.

### Prerequisites

* A Mac or another Hackintosh to prepare the installer (running at least macOS 10.14)
* macOS 10.14.5+ installer (lower versions _not_ supported)
* USB flash drive with at least 16GB of storage

{% hint style="info" %}
Please note that OSX software license prohibits running it on non-Apple hardware.
{% endhint %}

### Creating OSX Installer

{% hint style="warning" %}
Note all data on the USB drive **will be erased**.
{% endhint %}

1. On another OSX machine (or another Hackintosh), download **macOS Catalina** or higher from the [App Store](https://apps.apple.com/us/app/macos-catalina/id1466841314?mt=12).
2. Insert your USB drive and open up Terminal.
3. Open up Disk Utility to format your USB drive:
   1. Find your USB drive in the left sidebar under External (if there are multiple sub-drives under your USB drive, select the top-most one). You may need to choose **View** -> **Show All Devices** in order to see the full disk.
   2. Press the "Erase" button on the top toolbar.
   3. Give the name **Installer** and make sure to select **MacOS Extended (Journaled)** as the Format and **GUID Partition Map** as the Scheme.
   4. Press Erase, wait until it completes, and quit Disk Utility.
4. Open up Terminal and create the installer
   1. Run the following command `sudo "/Applications/Install macOS Catalina.app/Contents/Resources/createinstallmedia" --volume /Volumes/Installer` and type in your password when prompted.
   2. Wait for the process to complete. This can take around 30 minutes to an hour.

### Patching OSX Installer

{% hint style="info" %}
macOS Big Sur (11.0) and higher no longer supports installer patching. Skip this section if this applies to you.
{% endhint %}

We will use the HaC Mini installer (link at top of the page) to modify the vanilla OSX installer to install HaC Mini automatically after OSX installation completes.

1. Make sure your OSX installer USB is inserted and open **HaCMini.pkg**
2. Continue with the install until you reach the _Installation Type_ page.
3. Press _Change Install Location..._
4. Select your OSX installer USB from the list of destinations.
   1. Make sure you do **not** select your booted drive or you will install HaC Mini on the computer you're currently using.
   2. If the OSX installer USB cannot be selected, make sure the installer is for OSX 10.14.5 or later.
5. Press _Continue_ and then _Customize_
6. Check _Patch OSX installer_ if it is not disabled
   1. If the option is disabled, make sure you selected the OSX installer USB as the destination in the previous step.
   2. If it is still disabled, the macOS installer is not compatible. You can still proceed, however, you must follow the [update section](installation.md#update-existing-install) after installing macOS.
7. Press _Install_ and finish the installation.

### Installing macOS

{% hint style="warning" %}
We will be doing a clean installation. That means the SSD will be wiped and **any existing data will be lost**. If you plan to boot Windows and/or Linux, it is advised that you install those systems after OSX.
{% endhint %}

1. Insert your newly created USB installer into any USB slot and power on the NUC.
2. Press **F2** to enter BIOS and in **Boot** -> **Boot Priority**, make sure your USB drive is first.
3. Reboot and you should boot into the OSX installer
   1. If not, you need to [get into the boot picker](../post-installation/support.md#getting-into-boot-picker-menu) menu and select the installer.
4. The OSX installer should load.
   1. Partition your SSD using **Disk Utility**. You may need to choose **View** -> **Show All Devices** in order to find your drive. You should wipe the entire drive and format it as APFS with GUID Partition Map. This will also create the EFI and Recovery partitions.
5. Run the installer to completion.
   1. If the installer fails with an error message "This copy ... is damaged, and can’t be used to install macOS," check out the [support page](../post-installation/support.md#this-copy-is-damaged-and-cant-be-used-to-install-macos).
   2. Installation will reboot a few times. Because USB has first boot priority, you do not have to touch anything.
   3. If you see the boot picker after rebooting, select "macOS Installer."
6. After installation completes, you can remove the USB and boot from your SSD. You can revert the boot priority changes if desired.

## Install or Update HaC Mini Patches

{% hint style="info" %}
This section is optional (but recommended) if you've followed "Patching OSX Installer" above. It is required for users on macOS Big Sur (11.0) and higher.
{% endhint %}

When a macOS update is released, you should install it through normal means. Major macOS updates may not work 100% on day one and may have known issues, you should check the [issues page](https://github.com/osy86/HaC-Mini/issues) before a major upgrade. When a [new release](https://github.com/osy86/HaC-Mini/releases/latest) of HaC Mini comes out, you can follow the steps below to update the drivers and patches. Always update HaC Mini first before updating macOS to avoid potential boot issues.

{% hint style="danger" %}
You should never follow instructions or install drivers found on other Hackintosh sites and "distributions" as they do not apply to HaC Mini. When applicable, follow instructions from Apple's KB site or instructions for Mac mini.
{% endhint %}

1. Download the installer and run **HaCMini.pkg**
2. Run the installer to completion
   1. You may wish to click _Customize_ at the third step to install additional drivers and optional patches.
   2. It is highly recommended that you check "Boot Options -> Enable boot security" as it provides [additional security](../details/secure-boot.md) and is required for OTA updates on macOS 12.2 and above. [Extra steps are needed](../post-installation/support.md#cannot-boot-when-secure-boot-is-enabled) if this is the first time enabling boot security.
3. If you've selected to install _Native Thunderbolt_ support, run **Thunderbolt Patcher** from Applications after rebooting and patch your Thunderbolt controller. (This only needs to be done once.)

{% hint style="success" %}
Your NUC is now a Mac.
{% endhint %}
