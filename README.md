# Measure.jl

Electron goes in, electron goes out; you can't explain that!

This is a basic library of types and methods that represent input and output signals of physical instruments, as well as relevant instrument states and operations to deal the signals. It also comes equipped with basic built-in `sweep`, etc. functions that represent typical operations in my physical science research laboratory (such as: sweep output signal 1 and record input signal 2; see Usage below), as well as some types corresponding to instruments that I use.

## Philosophy

* Each physically distinct category or construct should be its own concrete type.
* Multiple dispatch and abstract types to make re-usable codebase.

## Requirements

* VISA.jl: https://github.com/PainterQubits/VISA.jl
	* VISA (from National Instruments) drivers are needed; see VISA.jl instructions.
* Plotly, JSON, Requests (these you can `Pkg.add`)

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
A = [ones(vrange) vrange]
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
