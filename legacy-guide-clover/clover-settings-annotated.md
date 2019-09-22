# Clover Settings Annotated

Do not blindly enable Clover options because some random poster recommended it. Always start with an empty configuration and enable only options that are needed. This page details the reasoning behind each entry in config.plist.

### ACPI

```markup
	<key>ACPI</key>
	<dict>
		<key>DSDT</key>
		<dict>
			<key>Patches</key>
			<array>
				<dict>
					<key>Comment</key>
					<string>change SAT0 to SATA</string>
					<key>Disabled</key>
					<false/>
					<key>Find</key>
					<data>
					U0FUMA==
					</data>
					<key>Replace</key>
					<data>
					U0FUQQ==
					</data>
				</dict>
				<dict>
					<key>Comment</key>
					<string>change HDAS to HDEF</string>
					<key>Disabled</key>
					<false/>
					<key>Find</key>
					<data>
					SERBUw==
					</data>
					<key>Replace</key>
					<data>
					SERFRg==
					</data>
				</dict>
				<dict>
					<key>Comment</key>
					<string>change NTFY to XTFY</string>
					<key>Disabled</key>
					<false/>
					<key>Find</key>
					<data>
					TlRGWQk=
					</data>
					<key>Replace</key>
					<data>
					WFRGWQk=
					</data>
				</dict>
				<dict>
					<key>Comment</key>
					<string>change RWAK to XWAK</string>
					<key>Disabled</key>
					<false/>
					<key>Find</key>
					<data>
					UldBSwk=
					</data>
					<key>Replace</key>
					<data>
					WFdBSwk=
					</data>
				</dict>
				<dict>
					<key>Comment</key>
					<string>change XHC to XHC2 on TBDU</string>
					<key>Disabled</key>
					<false/>
					<key>Find</key>
					<data>
					WEhDXwhfQURSAA==
					</data>
					<key>Replace</key>
					<data>
					WEhDMghfQURSAA==
					</data>
				</dict>
				<dict>
					<key>Comment</key>
					<string>change TBDU.XHC to TBDU.XHC2</string>
					<key>Disabled</key>
					<false/>
					<key>Find</key>
					<data>
					VEJEVVhIQ18=
					</data>
					<key>Replace</key>
					<data>
					VEJEVVhIQzI=
					</data>
				</dict>
				<dict>
					<key>Comment</key>
					<string>change PNP0C09 to PNPFFFF</string>
					<key>Disabled</key>
					<false/>
					<key>Find</key>
					<data>
					QdAMCQ==
					</data>
					<key>Replace</key>
					<data>
					QdD//w==
					</data>
				</dict>
				<dict>
					<key>Comment</key>
					<string>change HS09._UPC to HS09.XUPC</string>
					<key>Disabled</key>
					<false/>
					<key>Find</key>
					<data>
					SFMwORQMX1VQQw==
					</data>
					<key>Replace</key>
					<data>
					SFMwORQMWFVQQw==
					</data>
				</dict>
				<dict>
					<key>Comment</key>
					<string>change GFX0 to IGPU</string>
					<key>Disabled</key>
					<false/>
					<key>Find</key>
					<data>
					R0ZYMA==
					</data>
					<key>Replace</key>
					<data>
					SUdQVQ==
					</data>
				</dict>
				<dict>
					<key>Comment</key>
					<string>change H_EC to EC</string>
					<key>Disabled</key>
					<false/>
					<key>Find</key>
					<data>
					SF9FQw==
					</data>
					<key>Replace</key>
					<data>
					RUNfXw==
					</data>
				</dict>
			</array>
		</dict>
```

`SAT0` patch fixes potential SATA compatibility issues \(untested\). `HDEF` is checked by `AppleHDAController` to identify a controller as "not GFX." The `NTFY` and `RWAK` patches are to [fix TB3 hotplugging](../details/thunderbolt-3-fix.md#hotplug-event). The two patches to rename `TBDU.XHC` to `TBDU.XHC2` are required for [TB3 companion ports](../details/thunderbolt-3-fix.md#usb-companion-device) because they require a unique device name and `XHC` is already taken by the PCH XHCI controller. The `XHC.GPEH` patch redirects the USB hotplug events from the original `SB.PCI0.XHC` device \(which we disable in a custom SSDT\) to the PCH XHCI `SB.PCI0.XHC` device. We disable the `PNP0C09` device which is recognized as the embedded-controller by OSX. It has to be disabled because the NUC has a "virtual" EC that ignores reads/writes to it and this confuses OSX \(for example, if it sees there's an EC, it will try to write sleep/wake info to it\). However, to enable USB power management, we still rename `H_EC` to `EC` even though we do not use the EC. The power management kext does not actually do anything hardware-wise, but it does set static limits for the USB controller to use. The `HS09._UPC` change allows us to redefine the `_UPC` method in the SDST in order for OSX to recogize the Wifi/BT card as internal \(otherwise the port does not show up\). Finally, the `GFX0` to `IGPU` patch allows the graphics power management drivers to load for the Intel iGPU.

```markup
		<key>SSDT</key>
		<dict>
			<key>Generate</key>
			<dict>
				<key>PluginType</key>
				<true/>
			</dict>
		</dict>
	</dict>
```

This is needed to [enable XCPM](https://pikeralpha.wordpress.com/2016/07/26/xcpm-for-unsupported-processor/).

### Boot

```markup
	<key>Arguments</key>
	<string>alcid=11 -disablegfxfirmware</string>
	<key>Boot</key>
	<dict>
		<key>NeverHibernate</key>
		<true/>
	</dict>
	<key>XMPDetection</key>
	<string>Yes</string>
```

The alcid argument is for AppleALC for our [HDA fix](../details/hda-fix.md). `disablegfxfirmware` is required for Intel iGPU to boot since Apple's iGPU firmware is not supported. Hiberation is not implemented so we make sure we do not accidently trip it. XMP detection is only useful for people who overclock their RAM.

### Devices

```markup
	<key>Devices</key>
	<dict>
		<key>Properties</key>
		<dict>
			<key>PciRoot(0)/Pci(1,0)/Pci(0,0)</key>
			<dict>
				<key>device-id</key>
				<data>
				4GcAAA==
				</data>
			</dict>
			<key>PciRoot(0)/Pci(1,2)/Pci(0,0)</key>
			<dict>
				<key>name</key>
				<string>pci14e4,16bc</string>
			</dict>
			<key>PciRoot(0)/Pci(31,0)</key>
			<dict>
				<key>name</key>
				<string>pci8086,9cc1</string>
			</dict>
		</dict>
	</dict>
```

The first `device-id` patch chages the Vega M to be recognized as a Baffin GPU so the graphics accelerator can be enabled. The first `name` patch changes the device name for the SD card reader so it can be recognized by `AppleSDHC`. The second `name` patch makes AppleLPC get recognized on the LPC device \(the driver does some non-critical power management\).

### Graphics

```markup
	<key>Graphics</key>
	<dict>
		<key>Inject</key>
		<dict>
			<key>Intel</key>
			<true/>
		</dict>
		<key>ig-platform-id</key>
		<string>0x59120003</string>
	</dict>
```

This enables the iGPU.

### KernelAndKextPatches

```markup
	<key>KernelAndKextPatches</key>
	<dict>
		<key>KernelPm</key>
		<true/>
		<key>KernelToPatch</key>
		<array>
			<dict>
				<key>Comment</key>
				<string>MSR 0xE2 _xcpm_idle instant reboot(c) Pike R. Alpha</string>
				<key>Disabled</key>
				<false/>
				<key>Find</key>
				<data>
				ILniAAAADzA=
				</data>
				<key>Replace</key>
				<data>
				ILniAAAAkJA=
				</data>
			</dict>
		</array>
```

These are needed for CPU power management. Both patch issues with a locked MSR 0xE2 \(many motherboards including Intel NUC do this\) in different places.

