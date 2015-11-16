### Measure.jl package
# need to include the VISA submodule

using Instruments

module Measure

export Channel, Input, Output, BufferedInput, BufferedOutput, VirtualOutput, PID, Calculated, Label, Instrument, GpibInstrument
# export ask, read, write

using PyCall
@pyimport visa

### Channel abstract type and subtypes
# required attributes:
# 	current value "val" and label "lab" ?
# required functions:

abstract Channel

val(ch::Channel) = ch.val
label(ch::Channel) = ch.label

abstract Input <: Channel
abstract Output <: Channel
abstract BufferedInput <: Input
abstract BufferedOutput <: Output
abstract PID <: Channel

type Label
	name::String
	unit::String
end

### Instrument abstract type
# required attributes:
#		name: a string. the name.
# 	vi: a PyVISA.Instrument object
# required functions:

abstract Instrument
abstract GpibInstrument <: Instrument

name(instr::Instrument) = instr.name

read(instr::GpibInstrument) = instr.vi[:read]()
ask(instr::GpibInstrument, msg::ASCIIString) = instr.vi[:ask](msg)
write(instr::GpibInstrument, msg::ASCIIString) = instr.vi[:write](msg)

# instrument drivers

include("Time.jl")
include("Random.jl")
include("Agilent34401a.jl")
include("Keithley2400.jl")
include("SR830.jl")
include("Virtual.jl")

# utility functions

include("Sweep.jl")
include("Trace.jl")

end # module
