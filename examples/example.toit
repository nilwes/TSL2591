// Copyright (C) 2021 Toitware ApS. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be found
// in the LICENSE file.

import gpio
import i2c
import ..src.TSL2591

main:
  raw := []
  full/int := 0
  infrared/int := 0
  visible/int := 0

  bus := i2c.Bus
    --sda=gpio.Pin 21
    --scl=gpio.Pin 22
  
  device := bus.device I2C_ADDRESS
  sensor := tsl2591 device

  sensor.enable --gain = "medium" --time = 200

  sleep --ms=200 // Required pause to allow for the ADC to integrate
  50.repeat:
    raw = sensor.read_raw
    print_ "Raw:$(raw[0]), $(raw[1])" // print_ <-- Only print to serial output
    sleep --ms = 200
    full = sensor.read_full_spectrum
    print_ "Full spectrum:$(full)"
    sleep --ms = 200  
    infrared = sensor.read_infrared
    print_ "Infrared:$(infrared)"
    sleep --ms = 200  
    visible = sensor.read_visible
    print_ "Visible:$(visible)"
    sleep --ms = 200  
    print_ "+++++++++++++++++++++++++++++++++++"
