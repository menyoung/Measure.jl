module Measure

export Channel, Input, Output, BufferedInput, BufferedOutput, VirtualOutput, PID, Calculated, Label, Instrument, GpibInstrument
export ask, read, write

using PyCall
@pyimport visa

### Channel abstract type and subtypes
# required attributes:
# 	current value, label and unit?
# required functions:

abstract Channel

abstract Input <: Channel
abstract Output <: Channel
abstract BufferedInput <: Input
abstract BufferedOutput <: Output
abstract VirtualOutput <: Output
abstract PID <: Channel
abstract Calculated <: Input

type Label
	name::String
	unit::String
end

### Instrument abstract type
# required attributes:
# 	vi: a PyVISA.Instrument object
# required functions:

abstract Instrument
abstract GpibInstrument <: Instrument

ask(ins::Instrument, msg::ASCIIString) = ins.vi[:ask](msg)
read(ins::Instrument) = ins.vi[:read]()
write(ins::Instrument, msg::ASCIIString) = ins.vi[:write](msg)

# instrument drivers

include("Random.jl")
include("Time.jl")
include("Agilent34401a.jl")
include("Keithley2400.jl")
include("SR830.jl")

# utility functions

include("Sweep.jl")
include("Trace.jl")

end # module
