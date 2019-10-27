/**
 * TB3 For NUC Hades Canyon (Legacy)
 */
#define TBT_HOTPLUG_GPE _E20
DefinitionBlock ("", "SSDT", 2, "OSY86 ", "TbtLeg", 0x00001000)
{
    /* Support methods */
    External (DTGP, MethodObj)
    External (OSDW, MethodObj)                        // OS Is Darwin?
    External (\RMDT.P1, MethodObj)                    // Debug printing
    External (\RMDT.P2, MethodObj)                    // Debug printing
    External (\RMDT.P3, MethodObj)                    // Debug printing

    /* Patching existing devices */
    External (\_SB.PCI0.XHC, DeviceObj)
    External (\_SB.PCI0.RP05, DeviceObj)
    External (\_SB.PCI0.RP05.PXSX, DeviceObj)
    External (\_SB.PCI0.RP05.PXSX.TBDU, DeviceObj)
    External (\_SB.PCI0.RP05.PXSX.TBDU.XHC2, DeviceObj)
    External (\_SB.PCI0.RP05.PXSX.TBDU.XHC2.RHUB, DeviceObj)
    External (\_SB.PCI0.RP05.PXSX.TBDU.XHC2.RHUB.HS01, DeviceObj)
    External (\_SB.PCI0.RP05.PXSX.TBDU.XHC2.RHUB.HS02, DeviceObj)
    External (\_SB.PCI0.RP05.PXSX.TBDU.XHC2.RHUB.SS01, DeviceObj)
    External (\_SB.PCI0.RP05.PXSX.TBDU.XHC2.RHUB.SS02, DeviceObj)

    /* For hotplug */
    External (\_GPE.XTBT, MethodObj)                  // native hotplug support
    External (CPGN, FieldUnitObj)                     // CIO Hotplug GPIO
    External (TBSE, FieldUnitObj)                     // TB root port number

    Scope (\_GPE)
    {
        Method (TBT_HOTPLUG_GPE, 0, NotSerialized)  // _Exx: Edge-Triggered GPE
        {
            \_SB.PCI0.RP05.DBG1 ("_E20")
            \_GPE.XTBT (TBSE, CPGN)
            If (OSDW ())
            {
                Notify (\_SB.PCI0.RP05.PXSX.DSB0.NHI0, Zero)
                Notify (\_SB.PCI0.RP05.PXSX.TBDU.XHC2, Zero)
                Notify (\_SB.PCI0.XHC, Zero)
            }
            \_SB.PCI0.RP05.DBG1 ("End-of-_E20")
        }
    }

    Scope (\_SB.PCI0.RP05)
    {
        // Use https://github.com/RehabMan/OS-X-ACPI-Debug
        // to see debug messages
        
        Method (DBG1, 1, NotSerialized)
        {
            If (CondRefOf (\RMDT.P1))
            {
                \RMDT.P1 (Arg0)
            }
        }

        Method (DBG2, 2, NotSerialized)
        {
            If (CondRefOf (\RMDT.P2))
            {
                \RMDT.P2 (Arg0, Arg1)
            }
        }

        Method (DBG3, 3, NotSerialized)
        {
            If (CondRefOf (\RMDT.P3))
            {
                \RMDT.P3 (Arg0, Arg1, Arg2)
            }
        }

#include "SSDT-TbtLegacy-Power.asl"
#include "SSDT-TbtLegacy-Boot.asl"

        Method (_RMV, 0, NotSerialized)  // _RMV: Removal Status
        {
            Return (Zero)
        }

        If (OSDW ()) // only do force power patch for OSX
        {
            Method (_PS0, 0, Serialized)  // _PS0: Power State 0
            {
                TBON () // force power
            }

            Method (_PS3, 0, Serialized)  // _PS3: Power State 3
            {
                TBOF ()
            }
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
                                    Zero, 
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
                                Zero // disable companion device, not needed in legacy mode
                            }

                        DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                        Return (Local0)
                    }

                    Scope (RHUB)
                    {
                        Scope (HS01) // not used
                        {
                            Method (_STA, 0, NotSerialized)  // _STA: Status
                            {
                                Return (Zero)
                            }
                        }

                        Scope (HS02) // not used
                        {
                            Method (_STA, 0, NotSerialized)  // _STA: Status
                            {
                                Return (Zero)
                            }
                        }

                        Scope (SS01)
                        {
                            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                            {
                                Local0 = Package (0x04)
                                    {
                                        "UsbCPortNumber", 
                                        0x03, 
                                        "UsbCompanionControllerPresent", 
                                        Zero
                                    }

                                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                                Return (Local0)
                            }
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
                                        Zero
                                    }

                                DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                                Return (Local0)
                            }
                        }
                    }
                }
            }
        }
    }
}

