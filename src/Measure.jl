### Measure.jl package
module Measure

# need to import base functions to extend with more methods
import Base.read, Base.write

# export viOpenDefaultRM
export Signal, Input, Output, BufferedInput, BufferedOutput, VirtualOutput, PID, Calculated
export Label, Instrument, VisaInstrument, GpibInstrument, SocketInstrument
export value, label, ask, read, write, addr, port, sock, version

using VISA

### Signal abstract type and subtypes
# required attributes:
# 	current value "value" and label "label"
# required functions:

abstract Signal

value(s::Signal) = s.value
label(s::Signal) = s.label

abstract Input <: Signal
abstract Output <: Signal
abstract BufferedInput <: Input
abstract BufferedOutput <: Output
abstract PID <: Signal

type Label
	name::String
	unit::String
end

### Instrument abstract type
# required attributes:
#		name: a string. the name.

abstract Instrument

name(instr::Instrument) = instr.name

### abstract types and methods for VISA instruments
# required attributes:
# 	vi: instrument handle of type ViSession

abstract VisaInstrument <: Instrument
abstract GpibInstrument <: VisaInstrument

read(instr::VisaInstrument) = parse(String(viRead(instr.vi)))
write(instr::VisaInstrument, msg::String) = viWrite(instr.vi,msg)

function ask(instr::Instrument, msg::String)
	write(instr,msg)
	read(instr)
end

### abstract types and methods for socket instruments

abstract SocketInstrument <: Instrument

# need IP address, port number, and stream object
addr(instr::SocketInstrument) = instr.addr
port(instr::SocketInstrument) = instr.port
sock(instr::SocketInstrument) = instr.sock

# utility functions
# converting to code that converts to a values for sensitivity/range/time constant/etc
# start from 0, increment to get smallest code that gives range at least as large as target.
# conv should be increasing function that takes code to real value
function get_code(conv, target, start = Int64(0))
	code = start
	while (target > conv(code))
		code += 1
	end
	code
end

version() = "5325"

# instrument drivers

include("Time.jl")
include("Random.jl")
include("Agilent34401a.jl")
include("Keithley2400.jl")
include("SR830.jl")
include("SR7270.jl")
include("Virtual.jl")

# user functions

include("Sweep.jl")
include("Trace.jl")
include("Master.jl")

end # module
