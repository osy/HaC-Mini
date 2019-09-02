/**
 * AMD dGPU spoofing NUC HC
 */
DefinitionBlock ("", "SSDT", 2, "OSY86 ", "GpuSpoof", 0x00001000)
{
    External (\_SB.PCI0.PEG0.PEGP, DeviceObj)

    Scope (\_SB.PCI0.PEG0.PEGP) // dGPU
    {
        OperationRegion (PXCS, PCI_Config, Zero, 0x4)
        Field (PXCS, AnyAcc, NoLock, Preserve)
        {
            VDID,   32
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

        Method (MODL, 0, Serialized)
        {
            Switch (ToInteger (VDID))
            {
                Case (0x694c1002)
                {
                    Return (Buffer() { "AMD Radeon RX Vega M GH" })
                }
                Case (0x694e1002)
                {
                    Return (Buffer() { "AMD Radeon RX Vega M GL" })
                }
                Case (0x694f1002)
                {
                    Return (Buffer() { "AMD Radeon Pro WX Vega M GL" })
                }
                Default
                {
                    Return (Buffer() { "Unknown" })
                }

            }
        }

        Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
        {
            If (OSDW ())
            {
                If ((Arg0 == ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b")))
                {
                    Local0 = Package ()
                        {
                            "model", Buffer() { "Unknown" },
                            "device-id", Buffer() { 0xdf, 0x67, 0x00, 0x00 },
                            "revision-id", Buffer() { 0xc2, 0x00, 0x00, 0x00 },
                        }
                    Index(Local0, 1) = MODL ()
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Return (Zero)
        }
    }
}

