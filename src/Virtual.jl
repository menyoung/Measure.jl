### Virtual.jl a virtual and depent outputs, math operations on inputs

export VirtualOutput, DependentOutput, MathInput
export source, load, fire, measure

mutable struct DependentOutput <: Output
	s::Output
	f::Function
	value::Float64
	label::Label
end

DependentOutput(s::Output, f::Function, label::Label = Label("Unnamed Dependent","")) = DependentOutput(s, f, f(), label)

function source(s::DependentOutput, value::Real)
	s.value = s.f()
	source(s.s, s.value)
end

mutable struct VirtualOutput <: BufferedOutput
	s0::Array{DependentOutput,1}
	value0::Float64 # value is always the 'real' value, so value0 is for loading a buffer to fire.
	value::Float64
	label::Label
end

VirtualOutput(s::Array{DependentOutput,1}, value, label::Label = Label("Unnamed Virtual","")) = VirtualOutput(s, value, value, label)

function source(s::VirtualOutput, value::Real)
	s.value0 = value
	s.value = value
	map(s.s0) do s1
		source(s1, s.value)
	end
end

function load(s::VirtualOutput, value::Real)
	s.value0 = value
end

function fire(s::VirtualOutput)
	s.value = value0
	map(s.s0) do s1
		source(s1, s.value)
	end
end

"""
$(TYPEDEF)
$(FIELDS)
"""
mutable struct MathInput <: Input
	f::Function
	value
	label::Label
end

MathInput(f::Function, label::Label = Label("Unnamed Math","")) = MathInput(f, f(), label)

"$(SIGNATURES) calls the anonymous function `f()` by which the MathInput is constructed,
and also stores the the return value as `.value`"
measure(s::MathInput) = s.value = s.f()
fetch(s::MathInput) = s.value
