/**
 * Enable OSX power management features
 */
DefinitionBlock ("", "SSDT", 2, "OSY86 ", "PmEnable", 0x00001000)
{
    External (DTGP, MethodObj)    // 5 Arguments
    External (OSDW, MethodObj)    // 0 Arguments
    External (\_PR.PR00, ProcessorObj)

    Scope (\_PR.PR00) // CPU PM
    {
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

