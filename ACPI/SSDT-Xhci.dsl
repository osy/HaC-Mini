/**
 * USB For NUC Hades Canyon
 */
DefinitionBlock ("", "SSDT", 2, "OSY86 ", "Xhci", 0x00001000)
{
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

    Scope (\_SB.PCI0.XHC)
    {
        Method (DTGP, 5, NotSerialized)
        {
            If ((Arg0 == ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b")))
            {
                If ((Arg1 == One))
                {
                    If ((Arg2 == Zero))
                    {
                        Arg4 = Buffer (One)
                            {
                                 0x03                                             // .
                            }
                        Return (One)
                    }

                    If ((Arg2 == One))
                    {
                        Return (One)
                    }
                }
            }

            Arg4 = Buffer (One)
                {
                     0x00                                             // .
                }
            Return (Zero)
        }

        Method (OSDW, 0, NotSerialized)
        {
            If (CondRefOf (\_OSI, Local0))
            {
                If (_OSI ("Darwin"))
                {
                    Return (One) // Is OSX
                }
            }
            Return (Zero)
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

                Name (_PLD, Package (0x01)  // _PLD: Physical Location of Device
                {
                    ToPLD (
                        PLD_Revision           = 0x1,
                        PLD_IgnoreColor        = 0x1,
                        PLD_Red                = 0x0,
                        PLD_Green              = 0x0,
                        PLD_Blue               = 0x0,
                        PLD_Width              = 0x0,
                        PLD_Height             = 0x0,
                        PLD_UserVisible        = 0x0,
                        PLD_Dock               = 0x0,
                        PLD_Lid                = 0x0,
                        PLD_Panel              = "UNKNOWN",
                        PLD_VerticalPosition   = "UPPER",
                        PLD_HorizontalPosition = "LEFT",
                        PLD_Shape              = "UNKNOWN",
                        PLD_GroupOrientation   = 0x0,
                        PLD_GroupToken         = 0x0,
                        PLD_GroupPosition      = 0x0,
                        PLD_Bay                = 0x0,
                        PLD_Ejectable          = 0x0,
                        PLD_EjectRequired      = 0x0,
                        PLD_CabinetNumber      = 0x0,
                        PLD_CardCageNumber     = 0x0,
                        PLD_Reference          = 0x0,
                        PLD_Rotation           = 0x0,
                        PLD_Order              = 0x0)

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
/*
                Scope (HS12) // TB3 USB-C HS/LS
                {
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
*/
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
/*
        Name (SSP, Package (0x01)
        {
            "XHC2"
        })
        Name (SS, Package (0x01)
        {
            "XHC2"
        })
*/
    }

    Device (\_SB.USBX)
    {
        Name(_ADR, 0)
        Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
        {
            If (\_SB.PCI0.XHC.OSDW ())
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
                    \_SB.PCI0.XHC.DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
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

