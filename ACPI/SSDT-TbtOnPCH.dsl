/**
 * TB3 For NUC Hades Canyon
 */
DefinitionBlock ("", "SSDT", 2, "OSY86 ", "TbtOnPCH", 0x00001000)
{
    External (\_SB.PCI0.RP05, DeviceObj)
    External (\_SB.PCI0.RP05.PXSX, DeviceObj)
    External (XWAK, MethodObj) // renamed in Clover patch
    External (\_GPE.XTFY, MethodObj) // renamed in Clover patch
    External (\_SB.PCI0.RP05.VDID, FieldUnitObj)

    External (\_SB.PCI0.RP05.PXSX.TBDU, DeviceObj)
    External (\_SB.PCI0.RP05.PXSX.TBDU.XHC2, DeviceObj)
    External (\_SB.PCI0.RP05.PXSX.TBDU.XHC2.RHUB, DeviceObj)
    External (\_SB.PCI0.RP05.PXSX.TBDU.XHC2.RHUB.SS01, DeviceObj)
    External (\_SB.PCI0.RP05.PXSX.TBDU.XHC2.RHUB.SS02, DeviceObj)

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

    Method (RWAK, 1, Serialized)
    {
        XWAK (Arg0)

        If (((Arg0 == 0x03) || (Arg0 == 0x04)))
        {
            If ((\_SB.PCI0.RP05.VDID != 0xFFFFFFFF))
            {
                Notify (\_SB.PCI0.RP05.PXSX.DSB0.NHI0, Zero) // TB3 controller
            }
        }

        Return (Package (0x02)
        {
            Zero, 
            Zero
        })
    }

    Scope (\_GPE)
    {
        // use NUC's own hot plug detection
        Method (NTFY, 1, Serialized)
        {
            If (OSDW () && Arg0 == 0x05)
            {
                Notify (\_SB.PCI0.RP05.PXSX.DSB0.NHI0, Zero) // TB3 controller
            }
            Else
            {
                XTFY (Arg0)
            }
        }
    }

    Scope (\_SB.PCI0.RP05)
    {
        Method (_RMV, 0, NotSerialized)  // _RMV: Removal Status
        {
            Return (Zero)
        }

        Scope (PXSX)
        {
            OperationRegion (A1E0, PCI_Config, Zero, 0x40)
            Field (A1E0, ByteAcc, NoLock, Preserve)
            {
                AVND,   32, 
                BMIE,   3, 
                Offset (0x18), 
                PRIB,   8, 
                SECB,   8, 
                SUBB,   8, 
                Offset (0x1E), 
                    ,   13, 
                MABT,   1
            }

            Method (_BBN, 0, NotSerialized)  // _BBN: BIOS Bus Number
            {
                Return (SECB) /* \_SB_.PCI0.RP05.PXSX.SECB */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }

            /* // defined in SDST
            Method (_RMV, 0, NotSerialized)  // _RMV: Removal Status
            {
                Return (Zero)
            }
            */

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If (OSDW ())
                {
                    If ((Arg0 == ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b")))
                    {
                        Local0 = Package (0x02)
                            {
                                "PCI-Thunderbolt", 
                                One
                            }
                        DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                        Return (Local0)
                    }
                }

                Return (Zero)
            }

            Device (DSB0)
            {
                Name (_ADR, Zero)  // _ADR: Address
                OperationRegion (A1E0, PCI_Config, Zero, 0x40)
                Field (A1E0, ByteAcc, NoLock, Preserve)
                {
                    AVND,   32, 
                    BMIE,   3, 
                    Offset (0x18), 
                    PRIB,   8, 
                    SECB,   8, 
                    SUBB,   8, 
                    Offset (0x1E), 
                        ,   13, 
                    MABT,   1
                }

                Method (_BBN, 0, NotSerialized)  // _BBN: BIOS Bus Number
                {
                    Return (SECB) /* \_SB_.PCI0.RP05.PXSX.DSB0.SECB */
                }

                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (0x0F)
                }

                Method (_RMV, 0, NotSerialized)  // _RMV: Removal Status
                {
                    Return (Zero)
                }

                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    If (OSDW ())
                    {
                        If ((Arg0 == ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b")))
                        {
                            Local0 = Package (0x02)
                                {
                                    "PCIHotplugCapable", 
                                    Zero
                                }
                            DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                            Return (Local0)
                        }
                    }

                    Return (Zero)
                }

                Device (NHI0)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Name (_STR, Unicode ("Thunderbolt"))  // _STR: Description String

                    Method (_RMV, 0, NotSerialized)  // _RMV: Removal Status
                    {
                        Return (Zero)
                    }

                    Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                    {
                        If (OSDW ())
                        {
                            Local0 = Package (0x03)
                                {
                                    "power-save", 
                                    One, 
                                    Buffer (One)
                                    {
                                         0x00                                             // .
                                    }
                                }
                            DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                            Return (Local0)
                        }

                        Return (Zero)
                    }
                }
            }

            Scope (TBDU)
            {
                OperationRegion (A1E0, PCI_Config, Zero, 0x40)
                Field (A1E0, ByteAcc, NoLock, Preserve)
                {
                    AVND,   32, 
                    BMIE,   3, 
                    Offset (0x18), 
                    PRIB,   8, 
                    SECB,   8, 
                    SUBB,   8, 
                    Offset (0x1E), 
                        ,   13, 
                    MABT,   1
                }

                Method (_BBN, 0, NotSerialized)  // _BBN: BIOS Bus Number
                {
                    Return (SECB) /* \_SB_.PCI0.RP05.PXSX.TBDU.SECB */
                }

                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (0x0F)
                }

                Method (_RMV, 0, NotSerialized)  // _RMV: Removal Status
                {
                    Return (Zero)
                }

                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    If (OSDW ())
                    {
                        If ((Arg0 == ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b")))
                        {
                            Local0 = Package (0x02)
                                {
                                    "PCIHotplugCapable", 
                                    Zero
                                }
                            DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                            Return (Local0)
                        }
                    }

                    Return (Zero)
                }

                Scope (XHC2)
                {
                    Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                    {
                        Local0 = Package (0x06)
                            {
                                "USBBusNumber", 
                                Zero, 
                                "AAPL,xhci-clock-id", 
                                One, 
                                "UsbCompanionControllerPresent", 
                                One
                            }

                        DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                        Return (Local0)
                    }

                    Name (HS, Package (0x01)
                    {
                        "XHC1"
                    })
                    Name (FS, Package (0x01)
                    {
                        "XHC1"
                    })
                    Name (LS, Package (0x01)
                    {
                        "XHC1"
                    })

                    Scope (RHUB)
                    {
                        Scope (SS01)
                        {
                            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                            {
                                Local0 = Package (0x04)
                                    {
                                        "UsbCPortNumber", 
                                        0x03, 
                                        "UsbCompanionControllerPresent", 
                                        One
                                    }

                                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                                Return (Local0)
                            }

                            Name (HS, Package (0x02)
                            {
                                "XHC1", 
                                0x0C
                            })
                            Name (FS, Package (0x02)
                            {
                                "XHC1", 
                                0x0C
                            })
                            Name (LS, Package (0x02)
                            {
                                "XHC1", 
                                0x0C
                            })
                        }

                        Scope (SS02)
                        {
                            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                            {
                                Local0 = Package (0x04)
                                    {
                                        "UsbCPortNumber", 
                                        0x04, 
                                        "UsbCompanionControllerPresent", 
                                        One
                                    }

                                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                                Return (Local0)
                            }
                            
                            Name (HS, Package (0x02)
                            {
                                "XHC1", 
                                0x0D
                            })
                            Name (FS, Package (0x02)
                            {
                                "XHC1", 
                                0x0D
                            })
                            Name (LS, Package (0x02)
                            {
                                "XHC1", 
                                0x0D
                            })
                        }
                    }
                }
            }
        }
    }
}

