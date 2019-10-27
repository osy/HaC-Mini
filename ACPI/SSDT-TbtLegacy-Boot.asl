/**
 * Force power on TB controller.
 * We must do this early in _INI before XNU PCI 
 * enumeration.
 * 
 * Copyright (c) 2019 osy86
 */
// Scope (\_SB.PCI0.RP05)
// {
        External (MMRP, MethodObj)                        // Memory mapped root port
        External (MMTB, MethodObj)                        // Memory mapped TB port
        External (\_SB.PCI0.GPCB, MethodObj)              // get PCI MMIO base
        External (\_SB.PCI0.RP05.XINI, MethodObj)         // original _INI patched by OC

        Name (EICM, Zero)
        Name (R020, Zero) // RP base/limit from UEFI
        Name (R024, Zero) // RP prefetch base/limit from UEFI
        Name (R118, Zero) // UPSB Pri Bus = RP Sec Bus (UEFI)
        Name (R119, Zero) // UPSB Sec Bus = RP Sec Bus + 1
        Name (R11A, Zero) // UPSB Sub Bus = RP Sub Bus (UEFI)
        Name (R11C, Zero) // UPSB IO base/limit = RP IO base/limit (UEFI)
        Name (R120, Zero) // UPSB mem base/limit = RP mem base/limit (UEFI)
        Name (R124, Zero) // UPSB pre base/limit = RP pre base/limit (UEFI)
        Name (R218, Zero) // DSB0 Pri Bus = UPSB Sec Bus
        Name (R219, Zero) // DSB0 Sec Bus = UPSB Sec Bus + 1
        Name (R21A, Zero) // DSB0 Sub Bus = UPSB Sub Bus
        Name (R21C, Zero) // DSB0 IO base/limit = UPSB IO base/limit
        Name (R220, Zero) // DSB0 mem base/limit = UPSB mem base/limit
        Name (R224, Zero) // DSB0 pre base/limit = UPSB pre base/limit
        Name (R318, Zero) // DSB1 Pri Bus = UPSB Sec Bus
        Name (R319, Zero) // DSB1 Sec Bus = UPSB Sec Bus + 2
        Name (R31A, Zero) // DSB1 Sub Bus = no children
        Name (R31C, Zero) // DSB1 disable IO
        Name (R320, Zero) // DSB1 disable mem
        Name (R324, Zero) // DSB1 disable prefetch
        Name (R418, Zero) // DSB2 Pri Bus = UPSB Sec Bus
        Name (R419, Zero) // DSB2 Sec Bus = UPSB Sec Bus + 3
        Name (R41A, Zero) // DSB2 Sub Bus = no children
        Name (R41C, Zero) // DSB2 disable IO
        Name (R420, Zero) // DSB2 disable mem
        Name (R424, Zero) // DSB2 disable prefetch
        Name (RVES, Zero) // DSB2 offset 0x564, unknown
        Name (R518, Zero) // DSB4 Pri Bus = UPSB Sec Bus
        Name (R519, Zero) // DSB4 Sec Bus = UPSB Sec Bus + 4
        Name (R51A, Zero) // DSB4 Sub Bus = no children
        Name (R51C, Zero) // DSB4 disable IO
        Name (R520, Zero) // DSB4 disable mem
        Name (R524, Zero) // DSB4 disable prefetch
        Name (R618, Zero)
        Name (R619, Zero)
        Name (R61A, Zero)
        Name (R61C, Zero)
        Name (R620, Zero)
        Name (R624, Zero)
        Name (RH10, Zero) // NHI0 BAR0 = DSB0 mem base
        Name (RH14, Zero) // NHI0 BAR1 unused
        Name (POC0, Zero)

        /**
         * Get PCI base address
         * Arg0 = bus, Arg1 = device, Arg2 = function
         */
        Method (MMIO, 3, NotSerialized)
        {
            Local0 = \_SB.PCI0.GPCB () // base address
            Local0 += (Arg0 << 20)
            Local0 += (Arg1 << 15)
            Local0 += (Arg2 << 12)
            Return (Local0)
        }

        // Root port configuration base
        OperationRegion (RPSM, SystemMemory, MMRP (TBSE), 0x54)
        Field (RPSM, DWordAcc, NoLock, Preserve)
        {
            RPVD,   32, 
            RPR4,   8, 
            Offset (0x18), 
            RP18,   8, 
            RP19,   8, 
            RP1A,   8, 
            Offset (0x1C), 
            RP1C,   16, 
            Offset (0x20), 
            R_20,   32, 
            R_24,   32, 
            Offset (0x52), 
                ,   11, 
            RPLT,   1, 
            Offset (0x54)
        }

        // UPSB (up stream port) configuration base
        OperationRegion (UPSM, SystemMemory, MMTB (TBSE), 0x0550)
        Field (UPSM, DWordAcc, NoLock, Preserve)
        {
            UPVD,   32, 
            UP04,   8, 
            Offset (0x08), 
            CLRD,   32, 
            Offset (0x18), 
            UP18,   8, 
            UP19,   8, 
            UP1A,   8, 
            Offset (0x1C), 
            UP1C,   16, 
            Offset (0x20), 
            UP20,   32, 
            UP24,   32, 
            Offset (0xD2), 
                ,   11, 
            UPLT,   1, 
            Offset (0xD4), 
            Offset (0x544), 
            UPMB,   1, 
            Offset (0x548),
            T2PR,   32, 
            P2TR,   32
        }

        // DSB0 configuration base
        OperationRegion (DNSM, SystemMemory, MMIO (RP19 + 1, 0, 0), 0xD4)
        Field (DNSM, DWordAcc, NoLock, Preserve)
        {
            DPVD,   32, 
            DP04,   8, 
            Offset (0x18), 
            DP18,   8, 
            DP19,   8, 
            DP1A,   8, 
            Offset (0x1C), 
            DP1C,   16, 
            Offset (0x20), 
            DP20,   32, 
            DP24,   32, 
            Offset (0xD2), 
                ,   11, 
            DPLT,   1, 
            Offset (0xD4)
        }

        // DSB1 configuration base
        OperationRegion (DS3M, SystemMemory, MMIO (RP19 + 1, 1, 0), 0x40)
        Field (DS3M, DWordAcc, NoLock, Preserve)
        {
            D3VD,   32, 
            D304,   8, 
            Offset (0x18), 
            D318,   8, 
            D319,   8, 
            D31A,   8, 
            Offset (0x1C), 
            D31C,   16, 
            Offset (0x20), 
            D320,   32, 
            D324,   32
        }

        // DSB2 configuration base
        OperationRegion (DS4M, SystemMemory, MMIO (RP19 + 1, 2, 0), 0x0568)
        Field (DS4M, DWordAcc, NoLock, Preserve)
        {
            D4VD,   32, 
            D404,   8, 
            Offset (0x18), 
            D418,   8, 
            D419,   8, 
            D41A,   8, 
            Offset (0x1C), 
            D41C,   16, 
            Offset (0x20), 
            D420,   32, 
            D424,   32, 
            Offset (0x564), 
            DVES,   32
        }

        // DSB4 configuration base
        OperationRegion (DS5M, SystemMemory, MMIO (RP19 + 1, 4, 0), 0x40)
        Field (DS5M, DWordAcc, NoLock, Preserve)
        {
            D5VD,   32, 
            D504,   8, 
            Offset (0x18), 
            D518,   8, 
            D519,   8, 
            D51A,   8, 
            Offset (0x1C), 
            D51C,   16, 
            Offset (0x20), 
            D520,   32, 
            D524,   32
        }

        OperationRegion (NHIM, SystemMemory, MMIO (RP19 + 2, 0, 0), 0x40)
        Field (NHIM, DWordAcc, NoLock, Preserve)
        {
            NH00,   32, 
            NH04,   8, 
            Offset (0x10), 
            NH10,   32, 
            NH14,   32
        }

        OperationRegion (RSTR, SystemMemory, ((R_20 & 0xFFFC) << 16 & 0xFFF00000) + 0x39854, 0x0100)
        Field (RSTR, DWordAcc, NoLock, Preserve)
        {
            CIOR,   32, 
            Offset (0xB8), 
            ISTA,   32, 
            Offset (0xF0), 
            ICME,   32
        }

        OperationRegion (XHCM, SystemMemory, MMIO (RP19 + 4, 0, 0), 0x40)
        Field (XHCM, DWordAcc, NoLock, Preserve)
        {
            XH00,   32, 
            XH04,   8, 
            Offset (0x10), 
            XH10,   32, 
            XH14,   32
        }

        Method (_INI, 0, NotSerialized)  // _INI: Initialize
        {
            If (OSDW ())
            {
                DBG3 ("RP", RPVD, R_20)
                R020 = R_20 // RP base/limit from UEFI
                R024 = R_24 // RP prefetch base/limit from UEFI
                R118 = RP19 // UPSB Pri Bus = RP Sec Bus (UEFI)
                R119 = RP19 + 1 // UPSB Sec Bus = RP Sec Bus + 1
                R11A = RP1A // UPSB Sub Bus = RP Sub Bus (UEFI)
                R11C = RP1C // UPSB IO base/limit = RP IO base/limit (UEFI)
                R120 = R_20 // UPSB mem base/limit = RP mem base/limit (UEFI)
                R124 = R_24 // UPSB pre base/limit = RP pre base/limit (UEFI)
                R218 = R119 // DSB0 Pri Bus = UPSB Sec Bus
                R219 = R119 + 1 // DSB0 Sec Bus = UPSB Sec Bus + 1
                R21A = R11A // DSB0 Sub Bus = UPSB Sub Bus
                R21C = R11C // DSB0 IO base/limit = UPSB IO base/limit
                R220 = R120 // DSB0 mem base/limit = UPSB mem base/limit
                R224 = R124 // DSB0 pre base/limit = UPSB pre base/limit
                R318 = R119 // DSB1 Pri Bus = UPSB Sec Bus
                R319 = R119 + 2 // DSB1 Sec Bus = UPSB Sec Bus + 2
                R31A = R119 + 2 // DSB1 Sub Bus = no children
                R31C = Zero // DSB1 disable IO
                R320 = Zero // DSB1 disable mem
                R324 = Zero // DSB1 disable prefetch
                R418 = R119 // DSB2 Pri Bus = UPSB Sec Bus
                R419 = R119 + 3 // DSB2 Sec Bus = UPSB Sec Bus + 3
                R41A = R119 + 3 // DSB2 Sub Bus = no children
                R41C = Zero // DSB2 disable IO
                R420 = Zero // DSB2 disable mem
                R424 = Zero // DSB2 disable prefetch
                RVES = Zero // DSB2 offset 0x564, unknown
                R518 = R119 // DSB4 Pri Bus = UPSB Sec Bus
                R519 = R119 + 4 // DSB4 Sec Bus = UPSB Sec Bus + 4
                R51A = R119 + 4 // DSB4 Sub Bus = no children
                R51C = Zero // DSB4 disable IO
                R520 = Zero // DSB4 disable mem
                R524 = Zero // DSB4 disable prefetch
                R618 = Zero
                R619 = Zero
                R61A = Zero
                R61C = Zero
                R620 = Zero
                R624 = Zero
                RH10 = (R220 & 0xFFFC) << 16 // NHI0 BAR0 = DSB0 mem base
                RH14 = Zero // NHI0 BAR1 unused
                Sleep (One)
                TBON ()
                ICMS ()
            }
            Else
            {
                XINI () // original _INI ()
            }
        }

        Method (ICMS, 0, NotSerialized)
        {
            \_SB.PCI0.RP05.POC0 = One
            DBG2 ("ICME", \_SB.PCI0.RP05.ICME)
            If (\_SB.PCI0.RP05.ICME != 0x800001A3)
            {
                If (\_SB.PCI0.RP05.CNHI ())
                {
                    DBG2 ("ICME", \_SB.PCI0.RP05.ICME)
                    If (\_SB.PCI0.RP05.ICME != 0xFFFFFFFF)
                    {
                        \_SB.PCI0.RP05.WTLT ()
                        DBG2 ("ICME", \_SB.PCI0.RP05.ICME)
                    }
                }
            }

            \_SB.PCI0.RP05.POC0 = Zero
        }

        /**
         * Configure NHI device
         */
        Method (CNHI, 0, Serialized)
        {
            Local0 = 10

            // Configure root port
            DBG1 ("Configure root")
            While (Local0)
            {
                R_20 = R020 // Memory Base/Limit
                R_24 = R024 // Prefetch Base/Limit
                RPR4 = 0x07 // Command
                If (R020 == R_20) // read back check
                {
                    Break
                }

                Sleep (One)
                Local0--
            }

            If (R020 != R_20) // configure failed
            {
                Return (Zero)
            }

            // Configure UPSB
            DBG1 ("Configure UPSB")
            Local0 = 10
            While (Local0)
            {
                UP18 = R118 // UPSB Pri Bus
                UP19 = R119 // UPSB Sec Bus
                UP1A = R11A // UPSB Sub Bus
                UP1C = R11C // UPSB IO Base/Limit
                UP20 = R120 // UPSB Memory Base/Limit
                UP24 = R124 // UPSB Prefetch Base/Limit
                UP04 = 0x07 // UPSB Command
                If (R119 == UP19) // read back check
                {
                    Break
                }

                Sleep (One)
                Local0--
            }

            If (R119 != UP19) // configure failed
            {
                Return (Zero)
            }

            DBG1 ("Wait for link training")
            If (WTLT () != One)
            {
                Return (Zero)
            }

            // Configure DSB0
            DBG1 ("Configure DSB")
            Local0 = 10
            While (Local0)
            {
                DP18 = R218 // Pri Bus
                DP19 = R219 // Sec Bus
                DP1A = R21A // Sub Bus
                DP1C = R21C // IO Base/Limit
                DP20 = R220 // Memory Base/Limit
                DP24 = R224 // Prefetch Base/Limit
                DP04 = 0x07 // Command
                D318 = R318 // Pri Bus
                D319 = R319 // Sec Bus
                D31A = R31A // Sub Bus
                D31C = R31C // IO Base/Limit
                D320 = R320 // Memory Base/Limit
                D324 = R324 // Prefetch Base/Limit
                D304 = 0x07 // Command
                D418 = R418 // Pri Bus
                D419 = R419 // Sec Bus
                D41A = R41A // Sub Bus
                D41C = R41C // IO Base/Limit
                D420 = R420 // Memory Base/Limit
                D424 = R424 // Prefetch Base/Limit
                DVES = RVES // DSB2 0x564
                D404 = 0x07 // Command
                D518 = R518 // Pri Bus
                D519 = R519 // Sec Bus
                D51A = R51A // Sub Bus
                D51C = R51C // IO Base/Limit
                D520 = R520 // Memory Base/Limit
                D524 = R524 // Prefetch Base/Limit
                D504 = 0x07 // Command
                If (R219 == DP19) // read back check
                {
                    Break
                }

                Sleep (One)
                Local0--
            }

            If (R219 != DP19) // configure failed
            {
                Return (Zero)
            }

            DBG1 ("Wait for down link")
            If (WTDL () != One)
            {
                Return (Zero)
            }

            // Configure NHI
            DBG1 ("Configure NHI")
            Local0 = 100
            While (Local0)
            {
                NH10 = RH10 // NHI BAR 0
                NH14 = RH14 // NHI BAR 1
                NH04 = 0x07 // NHI Command
                If (RH10 == NH10) // read back check
                {
                    Break
                }

                Sleep (One)
                Local0--
            }
            DBG2 ("NHI BAR", NH10)

            If (RH10 != NH10) // configure failed
            {
                Return (Zero)
            }

            DBG1 ("CNHI done")

            Return (One)
        }

        /**
         * Uplink check
         */
        Method (UPCK, 0, Serialized)
        {
            If ((UPVD & 0xFFFF) == 0x8086)
            {
                Return (One)
            }
            Else
            {
                Return (Zero)
            }
        }

        /**
         * Uplink training check
         */
        Method (ULTC, 0, Serialized)
        {
            If (RPLT == Zero)
            {
                If (UPLT == Zero)
                {
                    Return (One)
                }
            }

            Return (Zero)
        }

        /**
         * Wait for link training
         */
        Method (WTLT, 0, Serialized)
        {
            Local0 = 2000
            Local1 = Zero
            While (Local0)
            {
                If (RPR4 == 0x07)
                {
                    If (ULTC ())
                    {
                        If (UPCK ())
                        {
                            Local1 = One
                            Break
                        }
                    }
                }

                Sleep (One)
                Local0--
            }

            Return (Local1)
        }

        /**
         * Downlink training check
         */
        Method (DLTC, 0, Serialized)
        {
            If (RPLT == Zero)
            {
                If (UPLT == Zero)
                {
                    If (DPLT == Zero)
                    {
                        Return (One)
                    }
                }
            }

            Return (Zero)
        }

        /**
         * Wait for downlink training
         */
        Method (WTDL, 0, Serialized)
        {
            Local0 = 2000
            Local1 = Zero
            While (Local0)
            {
                If (RPR4 == 0x07)
                {
                    If (DLTC ())
                    {
                        If (UPCK ())
                        {
                            Local1 = One
                            Break
                        }
                    }
                }

                Sleep (One)
                Local0--
            }

            Return (Local1)
        }
// }
