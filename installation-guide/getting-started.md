# Getting Started

### Prerequisites

* A Mac or another Hackintosh to prepare the installer
* USB flash drive with at least 16GB of storage

{% hint style="info" %}
Please note that OSX software license prohibits running it on non-Apple hardware.
{% endhint %}

### Drivers

We will use a variety of drivers \(KEXTs\) to get all devices to work. Do not add any other KEXT such as WhateverGreen \(it does nothing for us\).

* [FakeSMC](https://github.com/RehabMan/OS-X-FakeSMC-kozlek): required for all PCs to masquerade as a Macintosh
* [IntelMausiEthernet](https://github.com/Mieze/IntelMausiEthernet): driver for the first ethernet port \(I219-LM\)
* [AppleIGB](https://github.com/andyvand/Intel-OS-X-LAN-Driver/tree/master/AppleIGB): driver for the second ethernet port \(I210-at\)
* [AppleALC](https://github.com/osy86/AppleALC): audio driver patches
* [Polaris22Fixup](https://github.com/osy86/Polaris22Fixup): fix graphics issues for Vega M, a custom build of Lilu is needed for now
* [Lilu](https://github.com/acidanthera/Lilu): kernel patching framework used by AppleALC and Polaris22Fixup
* OldX4000HWLibs: macOS 10.14.5 broke Vega M support, so we load a patched version from 10.14.5 beta 1 instead

All of the above are pre-built as part of the [HaC Mini release](https://github.com/osy86/HaC-Mini/releases).

{% hint style="warning" %}
We will be doing a clean installation. That means the SSD will be wiped and **any existing data will be lost**. If you plan to boot Windows and/or Linux, it is advised that you install those systems after OSX.
{% endhint %}

* * * 
