# Measure

[![Build Status](https://travis-ci.org/menyoung/Measure.jl.svg?branch=master)](https://travis-ci.org/menyoung/Measure.jl)

Measure
=======

electron goes in, electron goes out; you can't explain that!

I was getting tired of using tables of function names in Igor Pro (which make the instrument calls) to be looked up by the sweep code.
This is a basic library of types and methods that represent instrument states and operations.
Also functions that represent typical operations in my lab (sweep instrument 1, take trace of instrument 2)

TODO
----

Factor out python ?
Make channels parametric: numbers, strings, tuples, etc.
release to public eye.

Philosophy
----------

Each physically distinct category should be its own concrete type.
Multiple dispatch and abstract types should help make re-usable codebase.

Requirements
------------

* PyCall.jl
* PyVISA in your Python
* VISA DLL (e.g. from National Instruments) for your PyVISA

Architecture
------------

### abstract types
plus what idea those types encode, i.e, attributes and methods

#### Instruments
* Instrument
	* standard VISA operations, wrap PyVISA VISA class, basically
* GpibInstrument extends Instrument
	* in addition, GPIB specific stuff like board number and address!
	* basically wrap PyVISA's GpibInstrument class

#### Channels
* Channel
	* current value, label and unit?
	* make parametric with data type of the value? Good for handling tuples...
	* channels can satisfy some of these traits below:
* Output
	* source, on/off
	* iterable! Just output those things one at a time!
* Input can be immutable?
	* measure
* BufferedInput extends Input
	* trigger
	* fetch
* BufferedOutput extends Output
	* load
	* fire
* VirtualOutput extends Output
	* hooks to DependentOutput channels
* DependentOutput extends Output
	* pointers to VirtualOutput channels
	* user provides anonymous function that calcluates the output from other outputs
	* (check for circular dependencies?! for now explicit depth levels)
* PID extends Channel
	* setpt, on/off.
	* P, I, and D.
* Calculated extends Input
	* pointers to Channels
	* user provides anonymous function that calculates.
	* use case: resistance bridge to measure temperature, Rcb and Gvb.

#### Arrays of things
* Array of Channels
	* way to implement special cases where one command controls multiple channels, e.g. SR830

Instruments host channels, channels may belong to instruments.
Use closures to link together channels that have to share same attributes.

### concrete types. Every field except value should be immutable?  
* SR830 implements GpibInstrument
	* SR830 channels:
		* V implements Output
		* X Y R Th implement Input
		* Rcb Gvb implement Calculated
	* attributes: time constant, etc.
* Keithley2400 implements GpibInstrument
	* Keithley2400Channels: volt, curr, volt4w
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
* etc. etc.