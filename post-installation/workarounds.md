# Workarounds

Outstanding issues are tracked and worked on in the [Github issues](https://github.com/osy86/HaC-Mini/issues). Some of the most common unresolved issues are documented here along with possible workarounds.

### [Wakeup from USB does not power on display](https://github.com/osy86/HaC-Mini/issues/9)

You can press any key after the NUC wakes up \(and screen still dark\) to trigger a "second" wake. You can also use the power button on the NUC instead of keyboard/mouse press to wake up without display issues. Another solution is to add the boot-arg `darkwake=0` but note this disables dark wake/Power Nap features.

### [Panic/restart on wakeup if TB3/back USB-C is used](https://github.com/osy86/HaC-Mini/issues/3)

You need to make sure the TB controller isn't powered off \(the hardware will try to save power but OSX isn't friendly to it\). The easiest workaround is to not use the back USB-C/TB3 ports \(USB-C DP mode is okay\); you can even disable it in BIOS. If you need to use those ports, make sure that you never go to sleep without a device plugged in. You can remove/hotplug as many devices as you want while awake, but make sure that something is plugged in before sleep and nothing is disconnected before wake.

### [Front headphone jack does not output sound](https://github.com/osy86/HaC-Mini/issues/4)

The front HP jack is not working yet, use the back audio out with your headphones. The headphone mic will not work. Digital out does not work either.

