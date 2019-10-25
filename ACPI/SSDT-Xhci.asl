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
            If (CondRefOf (\_SB.PCI0.RP05.UPSB.DSB2.XHC2.MODU, Local0))
            {
                Local0 = \_SB.PCI0.RP05.UPSB.DSB2.XHC2.MODU ()
            }
            Local1 = Zero
            If ((Local0 == One) || (Local1 == One))
            {
                Local0 = One
            }
            ElseIf ((Local0 == 0xFF) || (Local1 == 0xFF))
            {
                Local0 = 0xFF
            }
            Else
            {
                Local0 = Zero
            }

            Return (Local0)
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

            Scope (HS05) // not used
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }

            Scope (HS06) // not used
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }

            Scope (HS07) // not used
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }

            Scope (HS08) // not used
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
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

            Scope (SS05) // not used
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }

            Scope (SS06) // not used
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
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

                Scope (HS12) // TB3 USB-C HS/LS
                {
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x09, 
                        Zero, 
                        Zero
                    })
                    Name (SSP, Package (0x02)
                    {
                        "XHC2", 
                        0x03
                    })
                    Name (SS, Package (0x02)
                    {
                        "XHC2", 
                        0x03
                    })
                    Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                    {
                        Local0 = Package (0x02)
                            {
                                "UsbCPortNumber", 
                                0x03
                            }

                        DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                        Return (Local0)
                    }
                }

                Scope (HS13) // TB3 USB-C HS/LS
                {
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x09, 
                        Zero, 
                        Zero
                    })
                    Name (SSP, Package (0x02)
                    {
                        "XHC2", 
                        0x04
                    })
                    Name (SS, Package (0x02)
                    {
                        "XHC2", 
                        0x04
                    })
                    Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                    {
                        Local0 = Package (0x02)
                            {
                                "UsbCPortNumber", 
                                0x04
                            }

                        DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                        Return (Local0)
                    }
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

        Name (SSP, Package (0x01)
        {
            "XHC2"
        })
        Name (SS, Package (0x01)
        {
            "XHC2"
        })
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

