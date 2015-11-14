# Measure.jl

[![Build Status](https://travis-ci.org/menyoung/Measure.jl.svg?branch=master)](https://travis-ci.org/menyoung/Measure.jl)

electron goes in, electron goes out; you can't explain that!

I was getting tired of using tables of function names in Igor Pro (which make the instrument calls) to be looked up by the sweep code.
This is a basic library of types and methods that represent instrument states and operations.
Also functions that represent typical operations in my lab (sweep instrument 1, take trace of instrument 2)

TODO
----

Use Raytheon VISA package
Igor interfaces? how?
Make channels parametric: numbers, strings, tuples, etc. this will make everything safe

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
	* other attributes that are physically tied throughout the instrument, i.e. lock-in constant
* GpibInstrument extends Instrument
	* in addition, GPIB specific stuff like board number and address!
	* basically wrap PyVISA's GpibInstrument class

#### Channels
* Channel
	* required internal attribute: label::Label
	* Label is tuple type of 'name' and 'unit'.
	* make parametric with data type of the value? Good for handling tuples...
	* expose "lazy" evaluation: val() function
	* channels can satisfy some of these traits below:
* Output
	* source, (optional) on/off
	* iterable! Just output those things one at a time!
* Input can be immutable?
	* measure
* BufferedInput extends Input
	* trigger
	* fetch
* BufferedOutput extends Output
	* load
	* fire
* VirtualOutput implements BufferedOutput
	* hooks to DependentOutput channels
	* 'load' to change value
	* 'fire' actually calls source on dependents
* DependentOutput implements Output
	* hook to Output channel: source the value!
	* pointers to VirtualOutput channels
	* user provides anonymous function that calcluates the output from closures (e.g. VirtualOutputs)
	* no nesting.
* PID extends Channel
	* setpt, on/off.
	* P, I, and D.
* MathInput implements Input
	* pointers, closures to Channels
	* user provides anonymous function that calculates.
	* use case: resistance bridge to measure temperature, Rcb and Gvb.
	* also, to save GPIB calls by using "SNAP" inputs then referring to those inputs

#### Arrays of things
* Array of Channels
	* way to implement special cases where one command controls multiple channels, e.g. SR830

Instruments host channels, channels may belong to instruments.
Use closures to link together channels that have to share same attributes (?)

### concrete types. Every field except value should be immutable?  
* SR830 implements GpibInstrument
	* SR830 channels:
		* V implements Output
		* X, Y, R, P, XY, and RP implement Input
		* Rcb Gvb, etc implement MathInput
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
