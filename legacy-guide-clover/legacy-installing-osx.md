# Installation

### Preparing Installer USB

{% hint style="warning" %}
Note all data on the USB drive **will be erased**.
{% endhint %}

1. On another OSX machine \(or another Hackintosh\), download **macOS Mojave** from the [App Store](https://apps.apple.com/us/app/macos-mojave/id1398502828).
2. Insert your USB drive and open up Terminal.
3. Open up Disk Utility to format your USB drive:
   1. Find your USB drive in the left sidebar under External \(if there are multiple sub-drives under your USB drive, select the top-most one\).
   2. Press the "Erase" button on the top toolbar.
   3. Give the name **Installer** and make sure to select **GUID Partition Map** as the Scheme.
   4. Press Erase, wait until it completes, and quit Disk Utility.
4. Open up Terminal and create the installer
   1. Run the following command `sudo "/Applications/Install macOS Mojave.app/Contents/Resources/createinstallmedia" --volume /Volumes/Installer` and type in your password when prompted.
   2. Wait for the process to complete. This can take around 30 minutes to an hour.
5. Download the latest build of [Clover](https://cloverdb.com) \(you'll want the one that ends with .pkg\) and install it to the installer USB drive.
   1. Launch the installer pkg you downloaded.
   2. When prompted, choose **Change Install Location...** and select your USB drive \(it should be named **Install macOS Mojave**\).
   3. Next, click the **Customize** button.
   4. You'll want to check the following options \(you can also install any additional theme, but don't check anything else\):
      1. Clover for UEFI booting only
      2. Install Clover in the ESP
      3. UEFI Drivers -&gt; ApfsDriverLoader-64 \(for APFS support\)
      4. UEFI Drivers -&gt; SMCHelper-64 \(for FakeSMC support\)
      5. UEFI Drivers -&gt; AptioMemoryFix-64 \(for FileVault support\)
      6. UEFI Drivers -&gt; HFSPlus \(for HFS+ support\)
      7. UEFI Drivers -&gt; UsbKbDxe-64 \(needed for FileVault support\)
      8. FileVault 2 UEFI Drivers -&gt; AppleUISupport-64 \(for FileVault support\)
6. Once the installation completes, you should see a new drive named **EFI** get mounted.
7. Download the [HaC Mini release package](https://github.com/osy86/HaC-Mini/releases) and merge the `EFI` directory into the one on the EFI drive. Replace any existing file \(which should just be _config.plist_\).
8. Safely remove the USB drive.

### Installing macOS

1. Insert your newly created USB installer into any USB slot and power on the NUC.
2. Press **F10** at the prompt to get into the boot menu.
3. Select your USB drive and press enter.
4. You should see the Clover menu. Select the USB drive.
5. The OSX installer should load.
   1. Partition your SSD using **Disk Utility**. You should wipe the entire drive and format it as APFS with GUID Partition Map. This will also create the EFI and Recovery partitions.
   2. Installation will reboot a few times. Each time it reboots, you must press **F10** at boot and boot from the USB drive again.
   3. Once in Clover, you should select the drive named **Boot macOS Install from ...** if it appears.
6. After installation completes, you should still boot from the USB drive and in Clover, select **Boot macOS from ...**.

### Installing Clover Bootloader

Now we will move Clover from the installation USB to your boot drive so you can boot without having the USB inserted.

{% hint style="warning" %}
If you have an existing Clover installation, it will be replaced. Please back up anything you need. Note that most KEXTs and patches blindly recommended by most guides are actually not needed for our setup. Details of the Clover configuration [can be found here](clover-settings-annotated.md).
{% endhint %}

1. Download and install [Clover Configurator](https://mackie100projects.altervista.org/download-clover-configurator/) \([alternative download link](https://www.macupdate.com/app/mac/61090/clover-configurator)\).
2. Open Clover Configurator and choose **Mount EFI** on the left sidebar.
3. You should see at least two entries under Efi Partitions. One corrosponding to your SSD where you installed macOS to and another one corrosponding to your installer USB.
4. Click **Mount Partition** for both entries and enter your password if prompted.
5. Click **Open Partition** on your USB installer's EFI entry and a Finder window should open. Copy the directory named **EFI** \(it should be the only item\).
6. Back in Clover Configurator, click **Open Partition** this time on your SSD's EFI entry. Another Finder window should open. Paste the directory your just copied. Choose to **Replace** the existing directory.
7. In the same Finder window you just pasted into, traverse to _EFI_ and then _CLOVER_ and you should see a file named _config.plist_. Open this file with Clover Configurator and you should get a new window.
8. In the new Clover Configurator window, choose the **SMBIOS** tab on the left sidebar.
9. Now click the **Generate New** button next to _Serial Number_ and then **Generate New** next to _SmUUID_. This is important because it ensures you have a unique serial and are not using the same static serial as everyone else who didn't follow this guide correctly. Without a unique serial number, some Apple services won't work correctly.
10. Save your config.plist changes.

You can now eject the USB installer and you no longer need it to boot into the system!

