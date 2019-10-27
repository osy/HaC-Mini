/**
 * Companion ports used for RTD3 power savings
 */
DefinitionBlock ("", "SSDT", 2, "OSY86 ", "TbtComp", 0x00001000)
{
    External (DTGP, MethodObj)    // 5 Arguments
    External (OSDW, MethodObj)    // 0 Arguments
    External (\_SB.PCI0.XHC, DeviceObj)
    External (\_SB.PCI0.XHC.RHUB, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS12, DeviceObj)    // (from opcode)
    External (\_SB.PCI0.XHC.RHUB.HS13, DeviceObj)    // (from opcode)

    Scope (\_SB.PCI0.XHC)
    {
        Scope (RHUB)
        {
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