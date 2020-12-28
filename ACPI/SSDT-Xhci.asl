/**
 * USB For NUC Hades Canyon
 */
DefinitionBlock ("", "SSDT", 2, "OSY86 ", "Xhci", 0x00001000)
{
    External (DTGP, MethodObj)    // 5 Arguments
    External (OSDW, MethodObj)    // 0 Arguments
    External (\_SB.PCI0.XHC, DeviceObj)
    External (\_SB.PCHV, MethodObj)
    External (\_SB.SPTH, IntObj)

    External (\_SB.PCI0.XHC.RHUB, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS01, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS02, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS03, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS04, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS05, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS06, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS07, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS08, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS09, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS10, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS11, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS12, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS13, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS14, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.SS01, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.SS02, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.SS03, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.SS04, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.SS05, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.SS06, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.SS07, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.SS08, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.SS09, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.SS10, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.USR1, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.USR2, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC._PRW, MethodObj)
    External (\_SB.PCI0.RP05.UPSB.DSB2.XHC2.MODU, MethodObj)

    Scope (\_SB.PCI0.XHC)
    {
        Method (RTPC, 1, Serialized)
        {
            Return (Zero)
        }

        Method (MODU, 0, Serialized)
        {
            If (CondRefOf (\_SB.PCI0.RP05.UPSB.DSB2.XHC2.MODU))
            {
                Return (\_SB.PCI0.RP05.UPSB.DSB2.XHC2.MODU ())
            }
            Else
            {
                Return (One)
            }
        }

        Scope (RHUB)
        {
            Scope (HS01) // front charging
            {
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00) {}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (HS02) // not used
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }

            Scope (HS03) // back USB A
            {
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00) {}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (HS04) // back USB A
            {
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00) {}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (HS05) // internal USB 3.0 header (2.0 mode)
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero) // skipped due to 15 port limit
                }
            }

            Scope (HS06) // internal USB 3.0 header (2.0 mode)
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero) // skipped due to 15 port limit
                }
            }

            Scope (HS07) // internal USB 2.0 header
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero) // use HX07 instead
                }
            }

            Device (HX07)
            {
                Name (_ADR, 0x07)  // _ADR: Address
                Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                {
                    0xFF, 
                    Zero, 
                    Zero, 
                    Zero
                })
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00) {}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (HS08) // internal USB 2.0 header
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero) // use HX08 instead
                }
            }

            Device (HX08)
            {
                Name (_ADR, 0x08)  // _ADR: Address
                Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                {
                    0xFF, 
                    Zero, 
                    Zero, 
                    Zero
                })
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00) {}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (HS09) // Bluetooth
            {
                Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                {
                    0xFF, 
                    0xFF, 
                    Zero, 
                    Zero
                })
                
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00) {}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (HS10) // back USB A
            {
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00) {}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (USR1) // not used
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }

            Scope (USR2) // not used
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }

            Scope (SS01) // front charging
            {
            }

            Scope (SS02) // back USB A
            {
            }

            Scope (SS03) // back USB A
            {
            }

            Scope (SS04) // back USB A
            {
            }

            Scope (SS05) // internal USB 3.0 header
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero) // skipped due to 15 port limit
                }
            }

            Scope (SS06) // internal USB 3.0 header
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero) // skipped due to 15 port limit
                }
            }

            If ((PCHV () == SPTH)) // Only for Kabylake-H series
            {
                Scope (HS11) // back USB A
                {
                    Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                    {
                        Local0 = Package (0x00) {}
                        DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                        Return (Local0)
                    }
                }

                Scope (HS12) // TB3 USB-C HS/LS, see SSDT-TbtCompanion.asl
                {
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x09, 
                        Zero, 
                        Zero
                    })
                }

                Scope (HS13) // TB3 USB-C HS/LS, see SSDT-TbtCompanion.asl
                {
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x09, 
                        Zero, 
                        Zero
                    })
                }

                Scope (HS14) // not used
                {
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Return (Zero)
                    }
                }

                Scope (SS07) // back USB A
                {
                }

                Scope (SS08) // not used
                {
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Return (Zero)
                    }
                }

                Scope (SS09) // not used
                {
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Return (Zero)
                    }
                }

                Scope (SS10) // not used
                {
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Return (Zero)
                    }
                }
            }
        }
    }

    // These ACPI fixes only apply to OSX
    If (OSDW ())
    {
        Device (\_SB.USBX)
        {
            Name(_ADR, 0)
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If (OSDW ())
                {
                    If ((Arg0 == ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b")))
                    {
                        Local0 = Package ()
                            {
                                "kUSBSleepPortCurrentLimit", 1500,
                                "kUSBSleepPowerSupply", 9600,
                                "kUSBWakePortCurrentLimit", 1500,
                                "kUSBWakePowerSupply", 9600,
                            }
                        DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                        Return (Local0)
                    }
                }

                Return (Zero)
            }
        }

        Device(\_SB.EC) // fake EC for AppleBusPowerController matching
        {
            Name(_HID, "EC000000")  // _HID: Hardware ID
        }

        Device (\_SB.USBW)
        {
            Name (_HID, "PNP0D10")  // _HID: Hardware ID
            Name (_UID, "WAKE")  // _UID: Unique ID

            Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
            {
                Return (\_SB.PCI0.XHC._PRW ())
            }
        }
    }
}

