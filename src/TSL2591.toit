// Copyright (C) 2021 Toitware ApS. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be found
// in the LICENSE file.

// TSL2591 data sheet: https://ams.com/documents/20143/36005/TSL2591_DS000338_6-00.pdf/090eb50d-bb18-5b45-4938-9b3672f86b80

import binary
import serial.device as serial
import serial.registers as serial

I2C_ADDRESS     ::= 0x29

class tsl2591:
  //Device Registers
  static DEVICE_ID_        ::=  0x50
  
  static COMMAND_BIT_      ::=  0xA0 // Data sheet, page 14
  static ENABLE_REG_       ::=  0x00
  static CONTROL_REG_      ::=  0x01
  static DEVICE_ID_REG_    ::=  0x12
  static STATUS_REG_       ::=  0x13
  
  static CH0_DATA_L_       ::=  0x14
  static CH0_DATA_H_       ::=  0x15
  static CH1_DATA_L_       ::=  0x16
  static CH1_DATA_H_       ::=  0x17
  //Commands
  static ENABLE_PON_AEN_       ::= 0b0_0_0_0_00_1_1 // Power on and ALS enable
  static ENABLE_POFF_AENOFF_   ::= 0b0_0_0_0_00_0_0
  static CONTROL_SRESET        ::= 0b1_0000000
  //Settings
  static A_GAIN_ ::= { // Gain for internal integration amplifier
      "low"     : 0b00_00_0000,
      "medium"  : 0b00_01_0000,
      "high"    : 0b00_10_0000,
      "max"     : 0b00_11_0000,
  }
  static A_TIME_ ::= { //ADC integration time in ms (sets both channels)
      100  : 0b00000_000,
      200  : 0b00000_001,
      300  : 0b00000_010,
      400  : 0b00000_011,
      500  : 0b00000_100,
      600  : 0b00000_101,
  }

  reg_/serial.Registers ::= ?
  als_gain_ := 0
  als_time_ := 0

  constructor dev/serial.Device:
    reg_ = dev.registers
    // Check chip ID
    if (reg_.read_u8 (COMMAND_BIT_ | DEVICE_ID_REG_)) != 0x50: throw "INVALID_CHIP"

  /**
  Enables the sensor.
  The $gain parameter defines the gain of the internal integration amplifiers for both
  photodiode channels.
  Valid values for $gain are:
  - "low" --> 1
  - "medium" --> 25 <-- Default value
  - "high" --> 428
  - "max" --> 9876

  The $time parameter defines the ADC integration step time, in ms.
  Valid values for $time are:
  - 100
  - 200
  - 300 <-- Default value
  - 400
  - 500
  - 600
  */
  enable --gain = "medium" --time = 300:
    als_gain_ = gain
    als_time_ = time
    reg_.write_u8 (COMMAND_BIT_ | ENABLE_REG_) ENABLE_PON_AEN_
    reg_.write_u8 (COMMAND_BIT_ | CONTROL_REG_) (A_GAIN_[als_gain_] | A_TIME_[als_time_])

  read_raw -> List:
    ch0_ := reg_.read_u16_le (COMMAND_BIT_ | CH0_DATA_L_)
    ch1_ := reg_.read_u16_le (COMMAND_BIT_ | CH1_DATA_L_)
    return [ch0_, ch1_]

  /** 
  Reads the full spectrum (IR + visible) light and return its value as a 32-bit unsigned number.
  */
  read_full_spectrum -> int:
    ch := []
    ch = read_raw
    return (ch[1] << 16) | ch[0]

  /**
  Reads the infrared light and return its value as a 16-bit unsigned number.
  */
  read_infrared -> int:
    ch := []
    ch = read_raw
    return ch[1]

  /**
  Reads the visible light and return its value as a 32-bit unsigned number.
  */
  read_visible -> int:
    ch := []
    full/int := 0
    ch = read_raw
    full = (ch[1] << 16) | ch[0]
    return (full - ch[1])

  /**
  Disables the sensor and does a power down
  */
  disable -> none:
    reg_.write_u8 (COMMAND_BIT_ | ENABLE_REG_) ENABLE_POFF_AENOFF_

  /**
  Full reset of sensor.
  */
  reset -> none:
    reg_.write_u8 (COMMAND_BIT_ | CONTROL_REG_) CONTROL_SRESET