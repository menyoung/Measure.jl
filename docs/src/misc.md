# Measure.jl Miscellaneous Documentation

## Architecture

### Instrument abstract types
* Instrument
	* methods read, write, and ask
	* name is the only required attribute
	* other attributes that are physically tied to the whole instrument, i.e. lock-in constant
* VisaInstrument extends Instrument
	* `vi` attribute is the ViSession ID onto which standard VISA operations are applied
* GpibInstrument extends VisaInstrument
	* in addition, GPIB specific stuff like board number and address
* SocketInstrument extends Instrument
	* IP address, port number, and socket object (a stream)

### Signal abstract types (cannot use the word "Channel" any more)
* Signal
	* required internal attribute: `label::Label`
	* Label is tuple type of Strings `name` and `unit`.
	* must expose "lazy" evaluation: `value()` function or `.value` attribute
	* channels can satisfy some of these traits below:
* Output extends Signal
	* `source`, (optional) on/off
* Input extends Signal (can be immutable?)
	* `measure`
* BufferedInput extends Input
	* `trigger`
	* `fetch`
* BufferedOutput extends Output
	* `load`
	* fire
* VirtualOutput implements BufferedOutput
	* hooks to DependentOutput channels
	* `load` to change value
	* `fire` actually calls source on dependents
* DependentOutput implements Output
	* hook to Output channel: source the value!
	* pointers to VirtualOutput channels
	* user provides anonymous function that calculates the output from closures (e.g. VirtualOutputs)
	* no nesting.
* PID extends Signal
	* setpt, on/off.
	* P, I, and D.
* MathInput implements Input
	* anonymous function with closures to Signal methods and objects
	* user provides anonymous function that calculates.
	* use case: resistance bridge to measure temperature, Rcb and Gvb.
	* also, to save GPIB calls by using "SNAP" inputs then referring to those inputs

#### Arrays of things
* Array of Signal objects
	* way to implement special cases where one command controls multiple channels, e.g. SR830

Instruments host Signals, but do not need to retain references to all or any of its signals. Signals may belong to Instruments, and gains access to instrument state information by this reference.
Use closures to link together Signals that have to share same attributes (?)

### Concrete types
* SR830 implements GpibInstrument
	* SR830 Signals:
		* Ampl, Freq implement Output
		* X, Y, R, P, XY, and RP implement Input
	* attributes: time constant, etc.
* Keithley2400 implements GpibInstrument
	* Keithley2400 Signals: volt, curr, volt4w
	* Each channel has sweep rate, step size, etc.
	* Keithley2400 itself is abtract. Have subtypes for functions (voltage vs current vs 4WOhms)
* Yokogawa7651
	* channels: volt, curr, volt4w implement Output: Yoko only output does not input.
	* attributes:
* CryoCon32B
	* channels: Ta, Tb, L1, L2
* IPS120
	* channels: H V
	* attributes: sweep rate, etc.
* Signal Recovery 7270 implements SocketInstrument.
	* same channels as SR830.
* etc. etc.

## TODO

* docstrings (started on this)
* use the function! syntax when objects will mutate
* automatic data archival via HDF5 or JLD
* real-time plotting features: more than one plot; axis labels
* make channels parametric: numbers, strings, tuples, etc. this will make everything safe
* deal with the binary dependencies so Travis will work. Help! [![Build Status](https://travis-ci.org/menyoung/Measure.jl.svg?branch=master)](https://travis-ci.org/menyoung/Measure.jl)
