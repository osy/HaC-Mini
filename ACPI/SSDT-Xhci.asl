/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20200528 (64-bit version)
 * Copyright (c) 2000 - 2020 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of iASLvebm7D.aml, Sat Oct 24 23:19:42 2020
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x000006C0 (1728)
 *     Revision         0x02
 *     Checksum         0x7A
 *     OEM ID           "OSY86 "
 *     OEM Table ID     "Xhci"
 *     OEM Revision     0x00001000 (4096)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20161210 (538317328)
 */
DefinitionBlock ("", "SSDT", 2, "OSY86 ", "Xhci", 0x00001000)
{
    External (_SB_.PCHV, MethodObj)    // 0 Arguments
    External (_SB_.PCI0.RP05.UPSB.DSB2.XHC2.MODU, MethodObj)    // 0 Arguments
    External (_SB_.PCI0.XHC_, DeviceObj)
    External (_SB_.PCI0.XHC_._PRW, MethodObj)    // 0 Arguments
    External (_SB_.PCI0.XHC_.RHUB, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.HS01, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.HS02, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.HS03, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.HS04, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.HS05, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.HS06, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.HS07, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.HS08, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.HS09, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.HS10, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.HS11, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.HS12, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.HS13, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.HS14, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.SS01, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.SS02, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.SS03, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.SS04, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.SS05, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.SS06, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.SS07, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.SS08, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.SS09, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.SS10, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.USR1, DeviceObj)
    External (_SB_.PCI0.XHC_.RHUB.USR2, DeviceObj)
    External (_SB_.SPTH, IntObj)
    External (DTGP, MethodObj)    // 5 Arguments
    External (OSDW, MethodObj)    // 0 Arguments

    Scope (\_SB.PCI0.XHC)
    {
        Method (RTPC, 1, Serialized)
        {
            Return (Zero)
        }

        Method (MODU, 0, Serialized)
        {
            If (CondRefOf (\_SB.PCI0.RP05.UPSB.DSB2.XHC2.MODU))
            {
                Return (\_SB.PCI0.RP05.UPSB.DSB2.XHC2.MODU ())
            }
            Else
            {
                Return (One)
            }
        }

        Scope (RHUB)
        {
            Scope (HS01)
            {
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00){}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (HS02)
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }

            Scope (HS03)
            {
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00){}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (HS04)
            {
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00){}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (HS05)
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }

            Scope (HS06)
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }

            Scope (HS07)
            {
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00){}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (HS08)
            {
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00){}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (HS09)
            {
                Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                {
                    0xFF, 
                    0xFF, 
                    Zero, 
                    Zero
                })
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00){}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (HS10)
            {
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    Local0 = Package (0x00){}
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }
            }

            Scope (USR1)
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }

            Scope (USR2)
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }

            Scope (SS01)
            {
            }

            Scope (SS02)
            {
            }

            Scope (SS03)
            {
            }

            Scope (SS04)
            {
            }

            Scope (SS05)
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }

            Scope (SS06)
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (Zero)
                }
            }

            If ((PCHV () == SPTH))
            {
                Scope (HS11)
                {
                    Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                    {
                        Local0 = Package (0x00){}
                        DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                        Return (Local0)
                    }
                }

                Scope (HS12)
                {
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x09, 
                        Zero, 
                        Zero
                    })
                }

                Scope (HS13)
                {
                    Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
                    {
                        0xFF, 
                        0x09, 
                        Zero, 
                        Zero
                    })
                }

                Scope (HS14)
                {
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Return (Zero)
                    }
                }

                Scope (SS07)
                {
                }

                Scope (SS08)
                {
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Return (Zero)
                    }
                }

                Scope (SS09)
                {
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Return (Zero)
                    }
                }

                Scope (SS10)
                {
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Return (Zero)
                    }
                }
            }
        }
    }

    If (OSDW ())
    {
        Device (\_SB.USBX)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If (OSDW ())
                {
                    If ((Arg0 == ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b")))
                    {
                        Local0 = Package (0x08)
                            {
                                "kUSBSleepPortCurrentLimit", 
                                0x05DC, 
                                "kUSBSleepPowerSupply", 
                                0x2580, 
                                "kUSBWakePortCurrentLimit", 
                                0x05DC, 
                                "kUSBWakePowerSupply", 
                                0x2580
                            }
                        DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                        Return (Local0)
                    }
                }

                Return (Zero)
            }
        }

        Device (\_SB.EC)
        {
            Name (_HID, "EC000000")  // _HID: Hardware ID
        }

        Device (\_SB.USBW)
        {
            Name (_HID, "PNP0D10" /* XHCI USB Controller with debug */)  // _HID: Hardware ID
            Name (_UID, "WAKE")  // _UID: Unique ID
            Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
            {
                Return (\_SB.PCI0.XHC._PRW ())
            }
        }
    }
}

