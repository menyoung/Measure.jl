### Virtual.jl a virtual and depent outputs, math operations on inputs

export VirtualOutput, DependentOutput, MathInput
export source, load, fire, measure

type DependentOutput <: Output
	ch::Output
	f::Function
	value::Float64
	label::Label
end

DependentOutput(ch::Output, f::Function, label::Label = Label("Unnamed Dependent","")) = DependentOutput(ch, f, f(), label)

function source(ch::DependentOutput, value::Real)
	ch.value = ch.f()
	source(ch.ch, ch.value)
end

type VirtualOutput <: BufferedOutput
	ch0::Array{DependentOutput,1}
	value0::Float64 # value is always the 'real' value, so value0 is for loading a buffer to fire.
	value::Float64
	label::Label
end

VirtualOutput(ch::Array{DependentOutput,1}, value, label::Label = Label("Unnamed Virtual","")) = VirtualOutput(ch, value, value, label)

function source(ch::VirtualOutput, value::Real)
	ch.value0 = value
	ch.value = value
	map(ch.ch0) do ch1
		source(ch1, ch.value)
	end
end

function load(ch::VirtualOutput, value::Real)
	ch.value0 = value
end

function fire(ch::VirtualOutput)
	ch.value = value0
	map(ch.ch0) do ch1
		source(ch1, ch.value)
	end
end

type MathInput <: Input
	f::Function
	value
	label::Label
end

MathInput(f::Function, label::Label = Label("Unnamed Math","")) = MathInput(f, f(), label)

measure(ch::MathInput) = ch.value = ch.f()
fetch(ch::MathInput) = ch.value
