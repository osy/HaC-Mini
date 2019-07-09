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
					<string>change XHC.GPEH to XHC1.GPEH</string>
					<key>Disabled</key>
					<false/>
					<key>Find</key>
					<data>
					X1NCX1BDSTBYSENfR1BFSA==
					</data>
					<key>Replace</key>
					<data>
					X1NCX1BDSTBYSEMxR1BFSA==
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
			</array>
		</dict>
```

`SAT0` patch fixes potential SATA compatibility issues \(untested\). `HDEF` is checked by `AppleHDAController` to identify a controller as "not GFX." The `NTFY` and `RWAK` patches are to [fix TB3 hotplugging](thunderbolt-3-fix.md#hotplug-event). The two patches to rename `TBDU.XHC` to `TBDU.XHC2` are required for [TB3 companion ports](thunderbolt-3-fix.md#usb-companion-device) because they require a unique device name and `XHC` is already taken by the PCH XHCI controller. The `XHC.GPEH` patch redirects the USB hotplug events from the original `SB.PCI0.XHC` device \(which we disable in a custom SSDT\) to our port-fixed `SB.PCI0.XHC1` device. Finally we disable the `PNP0C09` device which is recognized as the embedded-controller by OSX. It has to be disabled because the NUC has a "virtual" EC that ignores reads/writes to it and this confuses OSX \(for example, if it sees there's an EC, it will try to write sleep/wake info to it\).

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
	<string>alcid=11</string>
	<key>Boot</key>
	<dict>
		<key>NeverHibernate</key>
		<true/>
	</dict>
	<key>XMPDetection</key>
	<string>Yes</string>
```

The alcid argument is for AppleALC for our [HDA fix](hda-fix.md). Hiberation is not implemented so we make sure we do not accidently trip it. XMP detection is only useful for people who overclock their RAM.

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
				<key>device-id</key>
				<data>
				wZwAAA==
				</data>
			</dict>
		</dict>
	</dict>
```

The first `device-id` patch chages the Vega M to be recognized as a Baffin GPU so the graphics accelerator can be enabled. The `name` patch changes the device name for the SD card reader so it can be recognized by `AppleSDHC`. The second `device-id` patch makes AppleLPC get recognized on the LPC device \(the driver does some non-critical power management\).

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

