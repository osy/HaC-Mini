/**
 * TI PD controller support
 */
#define HPM0_I2C_ADDRESS 0x3B
#define HPM1_I2C_ADDRESS 0x38
#define HPM2_I2C_ADDRESS 0x27
DefinitionBlock ("", "SSDT", 2, "OSY86 ", "HPM", 0x00001000)
{
    External (DTGP, MethodObj)    // 5 Arguments
    External (OSDW, MethodObj)    // 0 Arguments
    External (\_SB.PCI0.I2C1, DeviceObj)
    External (\_SB.PCI0.I2C2, DeviceObj)

    Scope (\_SB.PCI0.I2C1)
    {
        Device (HPM0) // this is the front USB-C port
        {
            Name (_CID, "apple-i2c-hpm0")  // _CID: Compatible ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Name (_ADR, Zero)  // _ADR: Address
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (OSDW ())
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If (LEqual (Arg0, ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b")))
                {
                    Store (Package ()
                        {
                            "i2cAddress", 
                            ToBuffer (HPM0_I2C_ADDRESS), 

                            "i2cSize", 
                            ToBuffer (16), 

                            "addrWidth", 
                            ToBuffer (7), 

                            "dataWidth", 
                            ToBuffer (8), 

                            "sclMode", 
                            ToBuffer (2), 

                            "sclLcnt", 
                            ToBuffer (192), 

                            "sclHcnt", 
                            ToBuffer (101), 

                            "sclPeriod", 
                            ToBuffer (2500), 

                            "sclHz", 
                            ToBuffer (400000), 

                            "sdaHold", 
                            ToBuffer (82), 

                            "sdaSetup", 
                            ToBuffer (Zero), 

                            "ioVoltageSelect", 
                            ToBuffer (3), 

                            "ltrSWMode", 
                            ToBuffer (One), 

                            "ltrEnb", 
                            ToBuffer (Zero), 

                            "powerStrategy", 
                            ToBuffer (0x5442)
                        }, Local0)
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }

                Return (Zero)
            }
        }
    }

    Scope (\_SB.PCI0.I2C2)
    {
        Device (HPM1) // this is the primary TB3 port
        {
            Name (_CID, "apple-i2c-hpm0")  // _CID: Compatible ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Name (_ADR, Zero)  // _ADR: Address
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (OSDW ())
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If (LEqual (Arg0, ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b")))
                {
                    Store (Package ()
                        {
                            "i2cAddress", 
                            ToBuffer (HPM1_I2C_ADDRESS), 

                            "i2cSize", 
                            ToBuffer (16), 

                            "addrWidth", 
                            ToBuffer (7), 

                            "dataWidth", 
                            ToBuffer (8), 

                            "sclMode", 
                            ToBuffer (2), 

                            "sclLcnt", 
                            ToBuffer (192), 

                            "sclHcnt", 
                            ToBuffer (101), 

                            "sclPeriod", 
                            ToBuffer (2500), 

                            "sclHz", 
                            ToBuffer (400000), 

                            "sdaHold", 
                            ToBuffer (82), 

                            "sdaSetup", 
                            ToBuffer (Zero), 

                            "ioVoltageSelect", 
                            ToBuffer (3), 

                            "ltrSWMode", 
                            ToBuffer (One), 

                            "ltrEnb", 
                            ToBuffer (Zero), 

                            "powerStrategy", 
                            ToBuffer (0x5442)
                        }, Local0)
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }

                Return (Zero)
            }
        }

        Device (HPM2) // this is the secondary TB3 port
        {
            Name (_CID, "apple-i2c-hpm1")  // _CID: Compatible ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Name (_ADR, Zero)  // _ADR: Address
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (OSDW ())
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If (LEqual (Arg0, ToUUID ("a0b5b7c6-1318-441c-b0c9-fe695eaf949b")))
                {
                    Store (Package ()
                        {
                            "i2cAddress", 
                            ToBuffer (HPM2_I2C_ADDRESS), 

                            "i2cSize", 
                            ToBuffer (16), 

                            "addrWidth", 
                            ToBuffer (7), 

                            "dataWidth", 
                            ToBuffer (8), 

                            "sclMode", 
                            ToBuffer (2), 

                            "sclLcnt", 
                            ToBuffer (192), 

                            "sclHcnt", 
                            ToBuffer (101), 

                            "sclPeriod", 
                            ToBuffer (2500), 

                            "sclHz", 
                            ToBuffer (400000), 

                            "sdaHold", 
                            ToBuffer (82), 

                            "sdaSetup", 
                            ToBuffer (Zero), 

                            "ioVoltageSelect", 
                            ToBuffer (3), 

                            "ltrSWMode", 
                            ToBuffer (One), 

                            "ltrEnb", 
                            ToBuffer (Zero), 

                            "powerStrategy", 
                            ToBuffer (0x5442)
                        }, Local0)
                    DTGP (Arg0, Arg1, Arg2, Arg3, RefOf (Local0))
                    Return (Local0)
                }

                Return (Zero)
            }
        }
    }
}