# Welcome

The goal of this guide is to create the perfect Mac mini alternative using the Intel NUC **Ha**des **C**anyon \(NUC8i7HNK/NUC8i7HVK\) and **macOS**. This guide is not for setting up a Hackintosh for any other machine. For a general Hackintosh guide, the [Vanilla Hackintosh Guide](https://hackintosh.gitbook.io/-r-hackintosh-vanilla-desktop-guide/) is highly recommended and is the main source of inspiration for this guide.

### Overview

Installation is simple and requires no prior knowledge or experience with Hackintoshes. All you need to do is make some BIOS changes, build an OSX installer flash drive from another Mac \(with some patches\), and run that installer on the NUC. The guide will explain all of this in detail.

[Get started with the build!](installation-guide/bios-settings.md)

### Status

This project aims to be the most complete Hackintosh build with no details overlooked. We have developed custom drivers, patches, and configurations specifically for the NUC Hades Canyon. We also follow Apple's lead in packaging all this in a user-friendly solution that does not require editing config files or understanding a list of jargon.

This is the only Hackintosh project developed from scratch to target a specific non-Apple board. We spent hundreds of hours reverse engineering Apple bootloaders, drivers, and NUC BIOS. We designed custom patches and drivers to bring macOS support to NUC Hades Canyon. As such, the level of compatibility is unprecedented.

#### Working Hardware

* [x] GPU acceleration
* [x] Video encoder/decoder hardware
* [x] Multiple displays \(six 4K displays max\)
* [x] 5K display
* [x] Ethernet \(both ports\)
* [x] Analog Audio \(both ports, no headsets\)
* [x] Digital Audio
* [x] Microphone \(both stereo mics\)
* [x] HDMI/DP audio
* [x] USB A ports
* [x] USB C ports
* [x] Thunderbolt 3 ports \(including hotplug\)
* [x] Thunderbolt IP \(XDomain, internet sharing\)
* [x] eGPU \(with hotplug\)
* [x] SD card slot
* [x] NVMe/SATA SSD
* [x] CPU power management
* [x] Sleep/Resume
* [x] Wifi/BT \(using Apple Wifi card\)
* [x] Secure Boot \(with High Security\)

**Working Software**

* [x] Installer, App Store, app updates, OS updates
* [x] iMessage, iCloud, Siri, iTunes, other services
* [x] FileVault2, APFS, Time Machine, SSD TRIM
* [x] Metal, GPU accelerated applications, hardware video encoder/decoder
* [x] Parallels/VMWare, other VM software
* [x] Handoff, Continuity, Universal Clipboard, Apple Watch unlock \(using Apple Wifi card\)
* [x] SIP, Gate Keeper, all OSX security features

#### Not Working/Issues

Please report and track [issues here](https://github.com/osy/HaC-Mini/issues).

