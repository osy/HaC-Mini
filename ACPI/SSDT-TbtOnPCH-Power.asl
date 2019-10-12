/**
 * Force power and init functions
 * On ICM based Ridges, we can force power with a 
 * GPIO signal. After powering up, we need to do a 
 * OSUP handshake before the PID is revealed.
 * 
 * Copyright (c) 2019 osy86
 */
// Scope (\_SB.PCI0.RP05)
// {
        External (\_GPE.TBFF, MethodObj)                  // detect TB root port
        External (\_GPE.TFPS, MethodObj)                  // TB force status
        External (\_SB.TBFP, MethodObj)                   // TB force power
        External (FFTB, MethodObj)                        // Detect TB powered on
        External (MMRP, MethodObj)                        // Memory mapped root port
        External (OSUM, MutexObj)                         // OSUP mutex
        External (SOHP, FieldUnitObj)                     // SMI on Hot Plug
        External (TNAT, FieldUnitObj)                     // Native hot plug
        External (TWIN, FieldUnitObj)                     // TB Windows 10 support

        /**
         * ThunderboltPowerUp
         * Force power with controller and does init.
         * Returns 1 if power up was successful
         */
        Method (TBON, 0, Serialized)
        {
            DBG1 ("TBON")
            If (\_GPE.TFPS ())
            {
                DBG1 ("Already on")
                Return (Zero)
            }

            TWIN = Zero // disable Win10 mode
            TBFP (One) // force power
            DBG1 ("Wait for TB root power up")
            Local1 = Timer + 6000000 // timeout in 600ms
            While (Timer < Local1 && FFTB (TBSE))
            {
                Sleep (1) // 1 millisecond
            }

            DBG1 ("Sending OSUP handshake")
            Acquire (OSUM, 0xFFFF)
            Local0 = \_GPE.TBFF (TBSE) // calls OSUP if not already up
            Release (OSUM)
            DBG2 ("TBFF", Local0)

            DBG1 ("TB hardware init sequence")
            SOHP = Zero
            TNAT = One
            \_GPE.XTBT (TBSE, CPGN)

            DBG1 ("Waiting for controller to appear")

            OperationRegion (UPS0, SystemMemory, MMTB (TBSE), 0x04)
            Field (UPS0, DWordAcc, NoLock, Preserve)
            {
                UPV0,   32, 
            }

            Local1 = Timer + 50000000 // timeout in 5s
            While (Timer < Local1 && UPV0 == 0xFFFFFFFF)
            {
                Sleep (100) // 100 milliseconds
            }

            If (UPV0 != 0xFFFFFFFF)
            {
                DBG2 ("Seen controller", UPV0)
                Return (One)
            }
            Else
            {
                DBG1 ("Failed")
                Return (Zero)
            }
        }

        /**
         * ThunderboltPowerOff
         * Release force power. This does not poll until controller 
         * is actually down!
         * Return 1 if power down was successful.
         */
        Method (TBOF, 0, Serialized)
        {
            DBG1 ("TBOF")
            If (\_GPE.TFPS ())
            {
                TBFP (Zero)
                Return (One)
            }
            Else
            {
                DBG1 ("Already off")
                Return (Zero)
            }
        }

        /**
         * SendCMD
         * Sends command to TB controller. Assumes powered up.
         */
        Method (SCMD, 2, Serialized)
        {
            DBG1 ("SCMD")
            Local0 = (MMTB (TBSE) + 0x0548)
            OperationRegion (PXVD, SystemMemory, Local0, 0x8)
            Field (PXVD, DWordAcc, NoLock, Preserve)
            {
                TB2P,   32, 
                P2TB,   32
            }

            P2TB = (Arg1 << 8) | (Arg0 << 1) | 0x1
            Local0 = 50
            While (Local0 > 0)
            {
                If (TB2P == 0xC || (TB2P & 1)) // 0xC = error, 0x1 = success
                {
                    Break
                }
                Local0--
                Sleep (100)
            }
            DBG2 ("P2TB", P2TB)
            DBG2 ("TB2P", TB2P)
            P2TB = Zero
        }
// }