/**
 * USB For NUC Hades Canyon
 */
DefinitionBlock ("", "SSDT", 2, "OSY86 ", "Xhci", 0x00001000)
{
    External (\_SB.PCI0, DeviceObj)
    External (\_SB.PCI0.XHC, DeviceObj)
    External (\_SB.PCI0.GPCB, MethodObj)
    External (DTGP, MethodObj)    // 5 Arguments
    External (OSDW, MethodObj)    // 0 Arguments
    External (MPMC, FieldUnitObj)
    External (PMFS, FieldUnitObj)
    External (UWAB, FieldUnitObj)
    External (XWMB, FieldUnitObj)

    Name (SLTP, Zero)
    Method (_TTS, 1, NotSerialized)  // _TTS: Transition To State
    {
        SLTP = Arg0
    }

    Scope (\_SB.PCI0)
    {
        Scope (XHC)
        {
            // Disable XHC which we're replacing with XHC1
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (Zero)
            }
        }

        Device (XHC1)
        {
            Name (_ADR, 0x00140000)  // _ADR: Address
            Name (SDPC, Zero)
            //Name (_GPE, 0x6D) // deep idle support
            Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
            {
                If (OSDW ())
                {
                    Return (Package (0x02)
                    {
                        0x6D, 
                        0x04
                    })
                }
                Else
                {
                    Return (Package (0x02)
                    {
                        0x6D, 
                        0x03
                    })
                }
            }

            // NUC specific hook
            Method (GPEH, 0, NotSerialized)
            {
                Notify (\_SB.PCI0.XHC1, 0x02)
            }
        }

        Scope (\_SB.PCI0.XHC1)
        {
            Name (SBAR, Zero)
            OperationRegion (XPRT, PCI_Config, Zero, 0x0100)
            Field (XPRT, AnyAcc, NoLock, Preserve)
            {
                DVID,   16, 
                Offset (0x40), 
                    ,   11, 
                SWAI,   1, 
                Offset (0x44), 
                    ,   12, 
                SAIP,   2, 
                Offset (0x48), 
                Offset (0x50), 
                    ,   2, 
                //STGE,   1, 
                Offset (0x74), 
                D0D3,   2, 
                Offset (0x75), 
                PMEE,   1, 
                    ,   6, 
                PMES,   1, 
                Offset (0xA2), 
                    ,   2, 
                //D3HE,   1, 
                Offset (0xA8), 
                    ,   13, 
                MW13,   1, 
                MW14,   1, 
                Offset (0xAC), 
                Offset (0xB0), 
                    ,   13, 
                MB13,   1, 
                MB14,   1, 
                Offset (0xB4), 
                Offset (0xD0), 
                PR2,    32, 
                PR2M,   32, 
                PR3,    32, 
                PR3M,   32
            }

            Name (STGE, Zero)
            Name (D3HE, Zero)

            OperationRegion (XHCP, SystemMemory, (GPCB () + 0x000A0000), 0x0100)
            Field (XHCP, AnyAcc, Lock, Preserve)
            {
                Offset (0x04), 
                PDBM,   16, 
                Offset (0x10), 
                MEMB,   64
            }

            Method (_PS0, 0, Serialized)  // _PS0: Power State 0
            {
                If (OSDW ())
                {
                    Local2 = ^MEMB /* \_SB_.PCI0.XHC1.MEMB */
                    Local1 = ^PDBM /* \_SB_.PCI0.XHC1.PDBM */
                    ^PDBM &= 0xFFFFFFFFFFFFFFF9
                    D3HE = Zero
                    STGE = Zero
                    ^D0D3 = Zero
                    If (SBAR == Zero)
                    {
                        Local6 = Zero
                        Local7 = ^MEMB /* \_SB_.PCI0.XHC1.MEMB */
                        Local7 &= 0xFFFFFFFFFFFFFFF0
                        If ((Local7 == Zero) || (Local7 == 0xFFFFFFFFFFFFFFF0))
                        {
                            ^MEMB = XWMB
                            Local6 = One
                        }
                    }
                    Else
                    {
                        ^MEMB = SBAR /* \_SB_.PCI0.XHC1.SBAR */
                    }

                    ^PDBM = (Local1 | 0x02)
                    Local0 = ^MEMB /* \_SB_.PCI0.XHC1.MEMB */
                    Local0 &= 0xFFFFFFFFFFFFFFF0
                    OperationRegion (MCA1, SystemMemory, Local0, 0x9000)
                    Field (MCA1, DWordAcc, NoLock, Preserve)
                    {
                        Offset (0x80A4), 
                            ,   28, 
                        AX28,   1, 
                        Offset (0x80C0), 
                            ,   10, 
                        AX10,   1, 
                        Offset (0x81C4), 
                            ,   2, 
                        CLK0,   1, 
                            ,   3, 
                        CLK1,   1
                    }

                    AX10 = Zero
                    AX28 = One
                    Stall (0x33)
                    AX28 = Zero
                    CLK0 = Zero
                    CLK1 = Zero
                    OperationRegion (PSCA, SystemMemory, Local0, 0x0620)
                    Field (PSCA, DWordAcc, NoLock, Preserve)
                    {
                        Offset (0x580), 
                        PC17,   32, 
                        Offset (0x590), 
                        PC18,   32, 
                        Offset (0x5A0), 
                        PC19,   32, 
                        Offset (0x5B0), 
                        PC20,   32, 
                        Offset (0x5C0), 
                        PC21,   32, 
                        Offset (0x5D0), 
                        PC22,   32, 
                        Offset (0x5E0), 
                        PC23,   32, 
                        Offset (0x5F0), 
                        PC24,   32, 
                        Offset (0x600), 
                        PC25,   32, 
                        Offset (0x610), 
                        PC26,   32
                    }

                    Local1 = (PC17 & 0xFFFFFFFFFFFFFFFD)
                    If ((Local1 & 0x010203F9) == 0x02E0)
                    {
                        PC17 = (Local1 | 0x80000000)
                        Sleep (0x65)
                        Local1 = (PC17 & 0xFFFFFFFFFFFFFFFD)
                        PC17 = (Local1 | 0x00FE0000)
                    }

                    Local1 = (PC18 & 0xFFFFFFFFFFFFFFFD)
                    If ((Local1 & 0x010203F9) == 0x02E0)
                    {
                        PC18 = (Local1 | 0x80000000)
                        Sleep (0x65)
                        Local1 = (PC18 & 0xFFFFFFFFFFFFFFFD)
                        PC18 = (Local1 | 0x00FE0000)
                    }

                    Local1 = (PC19 & 0xFFFFFFFFFFFFFFFD)
                    If ((Local1 & 0x010203F9) == 0x02E0)
                    {
                        PC19 = (Local1 | 0x80000000)
                        Sleep (0x65)
                        Local1 = (PC19 & 0xFFFFFFFFFFFFFFFD)
                        PC19 = (Local1 | 0x00FE0000)
                    }

                    Local1 = (PC20 & 0xFFFFFFFFFFFFFFFD)
                    If ((Local1 & 0x010203F9) == 0x02E0)
                    {
                        PC20 = (Local1 | 0x80000000)
                        Sleep (0x65)
                        Local1 = (PC20 & 0xFFFFFFFFFFFFFFFD)
                        PC20 = (Local1 | 0x00FE0000)
                    }

                    Local1 = (PC21 & 0xFFFFFFFFFFFFFFFD)
                    If ((Local1 & 0x010203F9) == 0x02E0)
                    {
                        PC21 = (Local1 | 0x80000000)
                        Sleep (0x65)
                        Local1 = (PC21 & 0xFFFFFFFFFFFFFFFD)
                        PC21 = (Local1 | 0x00FE0000)
                    }

                    Local1 = (PC22 & 0xFFFFFFFFFFFFFFFD)
                    If ((Local1 & 0x010203F9) == 0x02E0)
                    {
                        PC22 = (Local1 | 0x80000000)
                        Sleep (0x65)
                        Local1 = (PC22 & 0xFFFFFFFFFFFFFFFD)
                        PC22 = (Local1 | 0x00FE0000)
                    }

                    Local1 = (PC23 & 0xFFFFFFFFFFFFFFFD)
                    If ((Local1 & 0x010203F9) == 0x02E0)
                    {
                        PC23 = (Local1 | 0x80000000)
                        Sleep (0x65)
                        Local1 = (PC23 & 0xFFFFFFFFFFFFFFFD)
                        PC23 = (Local1 | 0x00FE0000)
                    }

                    Local1 = (PC24 & 0xFFFFFFFFFFFFFFFD)
                    If ((Local1 & 0x010203F9) == 0x02E0)
                    {
                        PC24 = (Local1 | 0x80000000)
                        Sleep (0x65)
                        Local1 = (PC24 & 0xFFFFFFFFFFFFFFFD)
                        PC24 = (Local1 | 0x00FE0000)
                    }

                    Local1 = (PC25 & 0xFFFFFFFFFFFFFFFD)
                    If ((Local1 & 0x010203F9) == 0x02E0)
                    {
                        PC25 = (Local1 | 0x80000000)
                        Sleep (0x65)
                        Local1 = (PC25 & 0xFFFFFFFFFFFFFFFD)
                        PC25 = (Local1 | 0x00FE0000)
                    }

                    Local1 = (PC26 & 0xFFFFFFFFFFFFFFFD)
                    If ((Local1 & 0x010203F9) == 0x02E0)
                    {
                        PC26 = (Local1 | 0x80000000)
                        Sleep (0x65)
                        Local1 = (PC26 & 0xFFFFFFFFFFFFFFFD)
                        PC26 = (Local1 | 0x00FE0000)
                    }

                    ^PDBM &= 0xFFFFFFFFFFFFFFFD
                    ^MEMB = Local2
                    ^PDBM = Local1
                    If (UWAB && (D0D3 == Zero))
                    {
                        MPMC = One
                        Local0 = (Timer + 10000000)
                        While (Timer <= Local0)
                        {
                            If (PMFS == Zero)
                            {
                                Break
                            }

                            Sleep (0x0A)
                        }
                    }
                }
                Else
                {
                    If (^DVID == 0xFFFF)
                    {
                        Return (Zero)
                    }

                    Local2 = ^MEMB /* \_SB_.PCI0.XHC1.MEMB */
                    Local1 = ^PDBM /* \_SB_.PCI0.XHC1.PDBM */
                    ^PDBM &= 0xFFFFFFFFFFFFFFF9
                    D3HE = Zero
                    STGE = Zero
                    ^D0D3 = Zero
                    If (SBAR == Zero)
                    {
                        Local6 = Zero
                        Local7 = ^MEMB /* \_SB_.PCI0.XHC1.MEMB */
                        Local7 &= 0xFFFFFFFFFFFFFFF0
                        If ((Local7 == Zero) || (Local7 == 0xFFFFFFFFFFFFFFF0))
                        {
                            ^MEMB = XWMB
                            Local6 = One
                        }
                    }
                    Else
                    {
                        ^MEMB = SBAR /* \_SB_.PCI0.XHC1.SBAR */
                    }

                    ^PDBM = (Local1 | 0x02)
                    Local0 = ^MEMB /* \_SB_.PCI0.XHC1.MEMB */
                    Local0 &= 0xFFFFFFFFFFFFFFF0
                    OperationRegion (MC11, SystemMemory, Local0, 0x9000)
                    Field (MC11, DWordAcc, NoLock, Preserve)
                    {
                        Offset (0x81C4), 
                            ,   2, 
                        UPSW,   2
                    }

                    UPSW = Zero
                    ^PDBM &= 0xFFFFFFFFFFFFFFFD
                    ^MEMB = Local2
                    ^PDBM = Local1
                    If (UWAB && (D0D3 == Zero))
                    {
                        MPMC = One
                        Local0 = (Timer + 200000000)
                        While (Timer <= Local0)
                        {
                            If (PMFS == Zero)
                            {
                                Break
                            }

                            Sleep (0x0A)
                        }
                    }
                }
            }

            Method (_PS3, 0, Serialized)  // _PS3: Power State 3
            {
                If (OSDW ())
                {
                    Local1 = ^PDBM /* \_SB_.PCI0.XHC1.PDBM */
                    Local2 = ^MEMB /* \_SB_.PCI0.XHC1.MEMB */
                    ^PDBM &= 0xFFFFFFFFFFFFFFF9
                    If (OSDW ())
                    {
                        D3HE = One
                        STGE = One
                        If ((SLTP == 0x03) || (SLTP == Zero))
                        {
                            ^D0D3 = 0x03
                            Stall (30)
                        }
                    }

                    ^D0D3 = Zero
                    ^PDBM = (Local1 | 0x02)
                    If (!OSDW ())
                    {
                        D3HE = One
                        STGE = One
                    }

                    SBAR = ^MEMB /* \_SB_.PCI0.XHC1.MEMB */
                    If (SBAR == Zero)
                    {
                        Local6 = Zero
                        Local7 = ^MEMB /* \_SB_.PCI0.XHC1.MEMB */
                        Local7 &= 0xFFFFFFFFFFFFFFF0
                        If ((Local7 == Zero) || (Local7 == 0xFFFFFFFFFFFFFFF0))
                        {
                            ^MEMB = XWMB
                            Local6 = One
                        }
                    }

                    Local0 = ^MEMB /* \_SB_.PCI0.XHC1.MEMB */
                    Local0 &= 0xFFFFFFFFFFFFFFF0
                    OperationRegion (MCA1, SystemMemory, Local0, 0x9000)
                    Field (MCA1, DWordAcc, NoLock, Preserve)
                    {
                        Offset (0x480), 
                        PC01,   32, 
                        Offset (0x490), 
                        PC02,   32, 
                        Offset (0x4A0), 
                        PC03,   32, 
                        Offset (0x4B0), 
                        PC04,   32, 
                        Offset (0x4C0), 
                        PC05,   32, 
                        Offset (0x80A4), 
                            ,   28, 
                        AX28,   1, 
                        Offset (0x80C0), 
                            ,   10, 
                        AX10,   1, 
                        Offset (0x81C4), 
                            ,   2, 
                        CLK0,   1, 
                            ,   3, 
                        CLK1,   1
                    }

                    If (OSDW ())
                    {
                        Local6 = PC05 /* \_SB_.PCI0.XHC1._PS3.PC05 */
                        Local6 = (PC05 & 0xFFFFFFFFFFFFFFFD)
                        PC05 = (Local6 & 0xFFFFFFFFFDFFFFFF)
                        Sleep (0x0A)
                        Local6 = PC05 /* \_SB_.PCI0.XHC1._PS3.PC05 */
                    }

                    If ((SLTP == 0x03) || (SLTP == Zero))
                    {
                        AX10 = One
                        Stall (20)
                    }

                    CLK0 = Zero
                    CLK1 = One
                    ^PDBM = Local1
                    ^D0D3 = 0x03
                    ^MEMB = Local2
                    ^PDBM = Local1
                    If (UWAB && (D0D3 == 0x03))
                    {
                        MPMC = 0x03
                        Local0 = (Timer + 10000000)
                        While (Timer <= Local0)
                        {
                            If (PMFS == Zero)
                            {
                                Break
                            }

                            Sleep (0x0A)
                        }
                    }
                }
                Else
                {
                    If (^DVID == 0xFFFF)
                    {
                        Return (Zero)
                    }

                    Local2 = ^MEMB /* \_SB_.PCI0.XHC1.MEMB */
                    Local1 = ^PDBM /* \_SB_.PCI0.XHC1.PDBM */
                    ^PDBM &= 0xFFFFFFFFFFFFFFF9
                    ^D0D3 = Zero
                    If (SBAR == Zero)
                    {
                        Local6 = Zero
                        Local7 = ^MEMB /* \_SB_.PCI0.XHC1.MEMB */
                        Local7 &= 0xFFFFFFFFFFFFFFF0
                        If ((Local7 == Zero) || (Local7 == 0xFFFFFFFFFFFFFFF0))
                        {
                            ^MEMB = XWMB
                            Local6 = One
                        }
                    }
                    Else
                    {
                        ^MEMB = SBAR /* \_SB_.PCI0.XHC1.SBAR */
                    }

                    ^PDBM = (Local1 | 0x02)
                    Local0 = ^MEMB /* \_SB_.PCI0.XHC1.MEMB */
                    Local0 &= 0xFFFFFFFFFFFFFFF0
                    OperationRegion (MC11, SystemMemory, Local0, 0x9000)
                    Field (MC11, DWordAcc, NoLock, Preserve)
                    {
                        Offset (0x81C4), 
                            ,   2, 
                        UPSW,   2
                    }

                    UPSW = 0x03
                    ^PDBM &= 0xFFFFFFFFFFFFFFFD
                    D3HE = One
                    STGE = One
                    ^D0D3 = 0x03
                    ^MEMB = Local2
                    ^PDBM = Local1
                    If (UWAB && (D0D3 == Zero))
                    {
                        MPMC = 0x03
                        Local0 = (Timer + 200000000)
                        While (Timer <= Local0)
                        {
                            If (PMFS == Zero)
                            {
                                Break
                            }

                            Sleep (0x0A)
                        }
                    }
                }
            }

            Method (RTPC, 1, Serialized)
            {
                Return (Zero)
            }

/*
            Method (USBM, 0, Serialized)
            {
                ^D0D3 = Zero
                Local1 = ^PDBM // \_SB_.PCI0.XHC1.PDBM
                Local2 = ^MEMB // \_SB_.PCI0.XHC1.MEMB
                ^PDBM = (Local1 | 0x02)
                Local0 = ^MEMB // \_SB_.PCI0.XHC1.MEMB
                Local0 &= 0xFFFFFFFFFFFFFFF0
                OperationRegion (PSCA, SystemMemory, Local0, 0x0600)
                Field (PSCA, DWordAcc, NoLock, Preserve)
                {
                    Offset (0x480), 
                    PC01,   32, 
                    Offset (0x490), 
                    PC02,   32, 
                    Offset (0x4A0), 
                    PC03,   32, 
                    Offset (0x4B0), 
                    PC04,   32
                }

                Local6 = PC03 // \_SB_.PCI0.XHC1.USBM.PC03
                Local6 = (PC03 & 0xFFFFFFFFFFFFFFFD)
                PC03 = (Local6 & 0xFFFFFFFFFFFFFDFF)
                Sleep (0x32)
                Local6 = PC03 // \_SB_.PCI0.XHC1.USBM.PC03
                ^PDBM &= 0xFFFFFFFFFFFFFFF9
                ^D0D3 = 0x03
                ^MEMB = Local2
                ^PDBM = Local1
                Return (Zero)
            }
            */

            Device (RHUB)
            {
                Name (_ADR, Zero)  // _ADR: Address
                Device (HS01) // front charging
                {
                    Name (_ADR, One)  // _ADR: Address
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x03, 
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
                            PLD_UserVisible        = 0x1,
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

                Device (HS03) // back USB A
                {
                    Name (_ADR, 0x03)  // _ADR: Address
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x03, 
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
                            PLD_UserVisible        = 0x1,
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

                Device (HS04) // back USB A
                {
                    Name (_ADR, 0x04)  // _ADR: Address
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x03, 
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
                            PLD_UserVisible        = 0x1,
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

                Device (HS09) // Bluetooth
                {
                    Name (_ADR, 0x09)  // _ADR: Address
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

                Device (HS10) // back USB A
                {
                    Name (_ADR, 0x0A)  // _ADR: Address
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x03, 
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
                            PLD_UserVisible        = 0x1,
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

                Device (HS11) // back USB A
                {
                    Name (_ADR, 0x0B)  // _ADR: Address
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x03, 
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
                            PLD_UserVisible        = 0x1,
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

                Device (HS12) // TB3 USB-C HS/LS
                {
                    Name (_ADR, 0x0C)  // _ADR: Address
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x03, 
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
                            PLD_UserVisible        = 0x1,
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

                Device (HS13) // TB3 USB-C HS/LS
                {
                    Name (_ADR, 0x0D)  // _ADR: Address
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x03, 
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
                            PLD_UserVisible        = 0x1,
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

                Device (SS01) // front charging
                {
                    Name (_ADR, 0x11)  // _ADR: Address
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x03, 
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
                            PLD_UserVisible        = 0x1,
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
                }

                Device (SS02) // back USB A
                {
                    Name (_ADR, 0x12)  // _ADR: Address
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x03, 
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
                            PLD_UserVisible        = 0x1,
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
                }

                Device (SS03) // back USB A
                {
                    Name (_ADR, 0x13)  // _ADR: Address
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x03, 
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
                            PLD_UserVisible        = 0x1,
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
                }

                Device (SS04) // back USB A
                {
                    Name (_ADR, 0x14)  // _ADR: Address
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x03, 
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
                            PLD_UserVisible        = 0x1,
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
                }

                Device (SS07) // back USB A
                {
                    Name (_ADR, 0x17)  // _ADR: Address
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x03, 
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
                            PLD_UserVisible        = 0x1,
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
                }
            }

            Method (MBSD, 0, NotSerialized)
            {
                Return (One)
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
    }
}

