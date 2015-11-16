### Measure.jl package
# need to include the VISA submodule

module Measure

export viOpenDefaultRM
export Channel, Input, Output, BufferedInput, BufferedOutput, VirtualOutput, PID, Calculated, Label, Instrument, GpibInstrument
# export ask, read, write

using VISA
#using PyCall
#@pyimport visa

### Channel abstract type and subtypes
# required attributes:
# 	current value "val" and label "label"
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
# 	vi: instrument handle of type ViSession
# required functions:

abstract Instrument
abstract GpibInstrument <: Instrument

name(instr::Instrument) = instr.name

read(instr::Instrument) = viRead(instr.vi)
write(instr::Instrument, msg::ASCIIString) = viWrite(instr.vi,msg)

function ask(instr::Instrument, msg::ASCIIString)
	write(instr,msg)
	read(instr)
end

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

include("Master.jl")

end # module
