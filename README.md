# Measure.jl

Electron goes in, electron goes out; you can't explain that!
<!-- I was getting tired of using tables of function names in Igor Pro (which make the instrument calls) to be looked up by the sweep code. -->
This is a basic library of types and methods that represent input and output signals of physical instruments, as well as relevant instrument states and operations to deal the signals. It also comes equipped with basic built-in `sweep`, etc. functions that represent typical operations in my physical science research laboratory (such as: sweep output signal 1 and record input signal 2; see Usage below).

## Philosophy

* Each physically distinct category should be its own concrete type.
* Multiple dispatch and abstract types to make re-usable codebase.

## Requirements

* VISA.jl: https://github.com/PainterQubits/VISA.jl
	* VISA (from National Instruments) drivers are needed; see VISA.jl instructions.
* Plotly, JSON, Requests (these you can `Pkg.add`)

## Architecture

### Instrument abstract types
* Instrument
	* methods read, write, and ask
	* name is the only required attribute
	* other attributes that are physically tied to the whole instrument, i.e. lock-in constant
* VisaInstrument extends Instrument
	* "vi" attribute is the ViSession ID onto which standard VISA operations are applied
* GpibInstrument extends VisaInstrument
	* in addition, GPIB specific stuff like board number and address
* SocketInstrument extends Instrument
	* IP address, port number, and socket object (a stream)

### Signal abstract types (cannot use the word "Channel" any more)
* Signal
	* required internal attribute: label::Label
	* Label is tuple type of 'name' and 'unit'.
	* must expose "lazy" evaluation: value() function or .value attribute
	* channels can satisfy some of these traits below:
* Output extends Signal
	* source, (optional) on/off
<!--	* iterable! Just output those things one at a time!-->
* Input extends Signal (can be immutable?)
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
* PID extends Signal
	* setpt, on/off.
	* P, I, and D.
* MathInput implements Input
	* pointers, closures to Signal objects
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

* docstrings
* Automatic data archival via HDF5 or JLD
* Real-time plotting features: more than one plot; axis labels
* Make channels parametric: numbers, strings, tuples, etc. this will make everything safe
* I'm not sure how to deal with the binary dependencies so Travis will work. Help! [![Build Status](https://travis-ci.org/menyoung/Measure.jl.svg?branch=master)](https://travis-ci.org/menyoung/Measure.jl)

## Usage

On Keithley 2400 (on GPIB address 25), sweep output voltage from -1 to 1 and record the current. Then do a line fit to find the resistance.
```julia
import VISA
using Measure
rm = VISA.viOpenDefaultRM()
ktest = Keithley2400Vb(rm,"GPIB0::25::INSTR")
volt = Keithley2400Vsrc(ktest)
curr = Keithley2400Imeas(ktest)
vrange = -1:0.001:1
wave = sweep(volt, curr, vrange, 0);
A = [ones(length(vrange)) vrange]
coeff = A \ wave
1 / coeff[2]
```

```
9.963939467124887e6
```
The resistance is 9.964 MOhms.

Below example is for using Signal Recovery 7270 (connected by ethernet cable; it has a fixed IP address and communicates through a particular port as defined by its manufacturer) to obtain impedance spectra as a function of frequency for a set of amplitude outputs.

```julia
using Measure
lia = SR7270("169.254.072.070",50000)
chX = SR7270X(lia, 0, Label("in-phase signal","V"))
chY = SR7270Y(lia, 0, Label("out-phase signal","V"))
chA = SR7270Ampl(lia, NaN, Label("Amplitude", "V"))
chF = SR7270Freq(lia, NaN, Label("Frequency", "Hz"))
f1 = exp(1.02:0.02:12.2)
a1 = [0.1,1,0.3,0.1]
data1 = Array{Float64}(length(f1),2,length(a1));
for (i,a) in enumerate(a1)
    source(chA,a)
    data1[:,:,i] = sweeps(chF,[chX,chY],f1,5)
end
```

### MathInput
This example shows off the power of abstraction.
```julia
import Measure
M = Measure
rand1,rand2 = M.RandomInput(),M.RandomInput()
rand3 = M.MathInput(() -> M.measure(rand1) + M.measure(rand2) * im)
rand4 = M.MathInput(() -> M.measure(rand1) + M.value(rand2) * im)
println(M.measure(rand3))
println(M.measure(rand4))
println(M.fetch(rand4))
```
```
0.24662886425743902 + 0.9834606761176372im
0.6832433647882843 + 0.9834606761176372im
0.6832433647882843 + 0.9834606761176372im
```

### Real time plotting

The tracer function
```julia
tracer(volt, curr, vrange, 0.1, 2014)
```
opens up a new browser webpage.
The live plotting works by spawning a "data server"
child process (`PlotServer.jl` started by a system call).
This server listens on a data port that accepts
(x,y) pairs as JSON and caches it.
Another port is the plotter port; it serves to HTTP clients
a static D3.js powered webpage, and serves the data
to any WebSockets client.
The static D3.js script is the WebSockets client
which obtains data; then it plots in real time.
By using only the bare minimum of D3.js required,
it's quite fast.

The job of the main process function, `tracer` is
to set the output signals, read input signals,
retain the data as well as write it to the plotter's
data port.
The last argument is the data port number to use.
Currently only works when measuring just one input signal.

<!--
### Streamer (uses Plotly)
```julia
import Measure
const M = Measure
...
wave = M.stream(volt, curr, vrange, 0.5, "streamingapitokenhere");
```
opens a new plot (need Plotly.jl set up on your computer)
-->
