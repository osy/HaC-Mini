/**
 * Enable OSX power management features
 */
DefinitionBlock ("", "SSDT", 2, "OSY86 ", "PmEnable", 0x00001000)
{
    External (\_PR.PR00, ProcessorObj)

    Scope (\_PR.PR00) // CPU PM
    {
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

        // This enables XCPM
        Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
        {
            If (OSDW ())
            {
                If ((Arg0 == ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b")))
                {
                    Local0 = Package ()
                        {
                            "plugin-type", One,
                        }
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Return (Zero)
        }
    }

    Scope (\_SB)
    {
        // This enables deep idle
        Method (LPS0, 0, NotSerialized)
        {
            Return (One)
        }
    }
     
    Scope (\_GPE)
    {
        // This tells xnu to evaluate _GPE.Lxx methods on resume
        Method (LXEN, 0, NotSerialized)
        {
            Return (One)
        }
    }
}

