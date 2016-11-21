"Measure.jl module and package"
module Measure

# need to import base functions to extend with more methods
import Base.read, Base.write

# export viOpenDefaultRM
export Signal, Input, Output, BufferedInput, BufferedOutput, VirtualOutput, PID, Calculated
export Label, Instrument, VisaInstrument, GpibInstrument, SocketInstrument
export value, label, ask, read, write, addr, port, sock, version

using VISA, DocStringExtensions

"""
$(TYPEDEF)
Concrete types must either have .value and .label attributes,
or supply its own value(s) and label(s) evaluation methods.
"""
abstract Signal

"$(SIGNATURES) returns `s.value` whch amounts to lazy evaluation
(no instrument calls) of Signal s"
value(s::Signal) = s.value
"$(SIGNATURES) returns `s.label` of Label type, for Signal s"
label(s::Signal) = s.label

abstract Input <: Signal
abstract Output <: Signal
abstract BufferedInput <: Input
abstract BufferedOutput <: Output
abstract PID <: Signal

"""
$(TYPEDEF)
$(FIELDS)
"""
type Label
	name::String
	unit::String
end

"""
$(TYPEDEF)
Concrete types must either have `.name` attribute,
or supply its own name method.
"""
abstract Instrument
"$(SIGNATURES) returns `instr.name`"
name(instr::Instrument) = instr.name

### abstract types and methods for VISA instruments
# required attributes:
# 	vi: instrument handle of type ViSession

"""
$(TYPEDEF) Concrete types must have `.vi` attribute,
which is the ViSession object (the "handle") obtained from resource manager.
"""
abstract VisaInstrument <: Instrument
"""
$(TYPEDEF) Concrete types must have `.vi` attribute,
which is the ViSession object (the "handle") obtained from resource manager.
"""
abstract GpibInstrument <: VisaInstrument

read(instr::VisaInstrument) = parse(String(viRead(instr.vi)))
write(instr::VisaInstrument, msg::String) = viWrite(instr.vi,msg)

function ask(instr::Instrument, msg::String)
	write(instr,msg)
	read(instr)
end

"""
$(TYPEDEF) Concrete types must have attributes: address `.addr`,
port number `.port`, and socket IO stream object `.sock`.
"""
abstract SocketInstrument <: Instrument

# need IP address, port number, and stream object
addr(instr::SocketInstrument) = instr.addr
port(instr::SocketInstrument) = instr.port
sock(instr::SocketInstrument) = instr.sock

# utility functions
"""
$(SIGNATURES)
Given `conv` which is a function that converts an integer code to
a parameter value, `get_code` inverts that relation to obtain
the appropriate the integer code.
Necessary for setting lock-in amplifier sensitivity/range/time constant/etc.;
it starts from `start` (default 0), increment to get smallest code that gives range at least as large as target.
`conv` should be increasing function that takes the code to the real parameter value.
"""
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
