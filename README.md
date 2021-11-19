# TSL2591
Toit driver for the TSL2591 light sensor.

The TSL2591 is a very-high sensitivity light-to-digital converter
that transforms light intensity into a digital signal output
capable of direct I2C interface. The device combines one
broadband photodiode (visible plus infrared) and one
infrared-responding photodiode on a single CMOS integrated
circuit. Two integrating ADCs convert the photodiode currents
into a digital output that represents the irradiance measured on
each channel. This digital output can be input to a
microprocessor where illuminance (ambient light level) in lux is
derived using an empirical formula to approximate the human
eye response. The TSL2591 supports a traditional level style
interrupt that remains asserted until the firmware clears it.

## Usage

A simple usage example.

```
import TSL2591

main:
  ...
```

See the `examples` folder for more examples.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/nilwes/TSL2591/issues