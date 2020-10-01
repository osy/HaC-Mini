# Boot Camp

This section is optional for people who wish to boot Windows as well \(booting Linux is an advanced exercise left for the user to figure out\). It is important to install Windows after OSX because OSX is less forgiving about the partition scheme.

With OpenCore, booting Windows is done through Boot Camp, just as with a real Mac.

### Installing Windows

{% hint style="info" %}
Note latest versions of macOS no longer have an option to create a USB. Either use macOS 10.14's Boot Camp Assistrant or create an installer USB from Windows on another machine.
{% endhint %}

{% hint style="info" %}
macOS does not support Boot Camp if you have two SSDs installed. You must manually install Windows, which is outside the scope of this guide.
{% endhint %}

1. Launch **Boot Camp Assistant** from Launchpad \(it's in the Other folder on a fresh install\).
2. Follow the directions in the assistant to partition your SSD and create a Windows 10 installer USB.
3. After the process is done, _before restarting_, we need to delete some irrelevant drivers that do not apply to the NUC. The list of files to delete from the newly created Windows 10 installer USB is listed below.
4. Restart and boot into the USB drive to run the Windows installer.

#### Unneeded Drivers

* Everything in `$WinPEDriver$` but do **not** delete the directory itself. Leave it empty.
* `BootCamp/Drivers/Broadcom`
* `BootCamp/Drivers/Intel`

The remaining drivers are for Apple peripherals and Mac-specific hardware \(which are unused and should not cause issues\).

### Fixing Boot

After Windows is installed, you'll notice that the NUC will automatically boot into Windows and not OpenCore. To fix this, open an administrator PowerShell window and type in

```text
bcdedit /set '{bootmgr}' path \EFI\OC\OpenCore.efi
```

You should also disable Fast Boot from Windows settings as well as the NUC BIOS settings. Even with Fast Boot disabled, there is a known issue with NUCs not properly booting with Windows installed \(after a power cycle\). A [workaround is described here](../post-installation/support.md#black-screen-on-reboot).

### Drivers

Apple drivers \(including Apple keyboards\) should be installed as part of the Boot Camp installer. If you used an [Apple Wifi replacement](../post-installation/wifi.md), then you need to get the Broadcom drivers [here](https://github.com/osy86/HaC-Mini/releases/download/v2.1/BCM94360CS2.zip). Finally, you should download the NUC drivers [from Intel](https://downloadcenter.intel.com/product/126143/Intel-NUC-Kit-NUC8i7HVK).

### Booting to/from Windows

OpenCore works like Macs. When you `bless` a partition, it will be the default boot option. In OSX, you can select the default boot partition from **System Preferences** -&gt; **Startup Disk**. In Windows, it is in Control **Panel** -&gt; **Boot Camp**. If you want to boot into the non-blessed partition on startup, you need to [trigger the OpenCore boot picker](../post-installation/support.md#getting-into-boot-picker-menu).

