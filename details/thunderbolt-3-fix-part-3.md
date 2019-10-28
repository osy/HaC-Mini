# Thunderbolt 3 Fix \(Part 3\)

WIP

### Comparison

The three attempted fixes for Thunderbolt described in this three part article are not perfect. Below is a summary of issues seen in each method.

|  | Legacy | Hybrid | Native |
| :--- | :--- | :--- | :--- |
| Bootup with TB | Yes \(1\) | Yes \(1\) | Yes |
| Bootup with USB | Yes | Yes | Yes |
| Hotplug USB | Yes \(1\) | Yes \(1\) | Yes |
| Hotplug TB | Yes | Yes | Yes |
| CIO Device | No | Yes | Yes |
| PCIE Device | Yes | Yes | Yes |
| USB Device | Yes | Yes | Yes |
| RTD3 \(Save Power\) | No | Yes | No |
| Sleep | Yes | Yes \(2\) | Yes |
| Wakeup | Yes \(1,3\) | Yes \(1\) | Yes |
| Windows: USB | Yes | Yes | Yes |
| Windows: TB | Yes | Yes | No \(4\) |

\(1\) If booted up or woken up with a TB device and NO USB device, then the XHCI controller will not be powered up and USB 3.0 will not work until next reboot.

\(2\) Sleep works 50% of the time. Due to LC quirks, device will insta-wake half the time. However, OSX will try again and again until it succeeds.

\(3\) If woken up without any device attached, &lt; 25% chance of kernel panic as the LC does not become ready fast enough.

\(4\) If the LC already set up a PCIE device \(in OSX\) and then warm-reboot into Windows, that device will still be available.

In summary, for maximum compatibility with Windows, use the legacy method and disable sleep. Otherwise, if OSX is your main OS, the native method is recommended.

