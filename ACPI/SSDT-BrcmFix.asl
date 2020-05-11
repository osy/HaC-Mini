/**
 * DW1820A Property Injection
 */
DefinitionBlock ("", "SSDT", 2, "OSY86 ", "BrcmFix", 0x00001000)
{
    External (DTGP, MethodObj)    // 5 Arguments
    External (OSDW, MethodObj)    // 0 Arguments
    External (\_SB.PCI0.RP03.PXSX, DeviceObj)

    Scope (\_SB.PCI0.RP03.PXSX)
    {
        Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
        {
            If (OSDW ())
            {
                If ((Arg0 == ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b")))
                {
                    Local0 = Package ()
                        {
                            "pci-aspm-default", Buffer() { 0x00, 0x00 },
                            "brcmfx-country", Buffer() { "#a" },
                        }
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Return (Zero)
        }
    }
}
