### Virtual.jl a virtual and depent outputs, math operations on inputs

export VirtualOutput, DependentOutput, MathInput
export source, load, fire, measure

type DependentOutput <: Output
	ch::Output
	f::Function
	val::Float64
	label::(String,String)
end

DependentOutput(ch::Output, f::Function, label::(String,String) = ("Unnamed Dependent","")) = DependentOutput(ch, f, f(), label)

function source(ch::DependentOutput, val::Real)
	ch.val = ch.f()
	source(ch.ch, ch.val)
end

type VirtualOutput <: BufferedOutput
	ch0::Array{DependentOutput,1}
	val0::Float64 # val is always the 'real' value, so val0 is for loading a buffer to fire.
	val::Float64
	label::(String,String)
end

VirtualOutput(ch::Array{DependentOutput,1}, val, label::(String,String) = ("Unnamed Virtual","")) = VirtualOutput(ch, val, val, label)

function source(ch::VirtualOutput, val::Real)
	ch.val0 = val
	ch.val = val
	map(ch.ch0) do ch1
		source(ch1, ch.val)
	end
end

function load(ch::VirtualOutput, val::Real)
	ch.val0 = val
end

function fire(ch::VirtualOutput)
	ch.val = val0
	map(ch.ch0) do ch1
		source(ch1, ch.val)
	end
end

type MathInput <: Input
	f::Function
	val::Float64
	label::(String,String)
end

MathInput(f::Function, label::(String,String) = ("Unnamed Math","")) = MathInput(f, f(), label)

function measure(ch::MathInput)
	ch.val = ch.f()
end
