### Virtual.jl a virtual and depent outputs, math operations on inputs
#

export VirtualOutput, DependentOutput, MathInput
export source, load, fire, measure

type DependentOutput <: Output
	ch::Output
	val::Float64
	f::Function
	label::(String,String)
end

DependentOutput(ch::Output, f::Function, label::(String,String) = ("Unnamed Dependent",""))
	= DependentOutput(ch, f, f(), label)
val(ch::DependentOutput) = ch.val

function source(ch::DependentOutput, val::Real)
	ch.val = ch.f()
	ch.ch.source(ch.val)
end

type VirtualOutput <: BufferedOutput
	ch::Array{DependentOutput,1}
	val::Float64
	label::(String,String)
end

VirtualOutput(ch::Array{DependentOutput,1}, val, label::(String,String) = ("Unnamed Virtual",""))
	= VirtualOutput(ch, label, val)
val(ch::VirtualOutput) = ch.val

function source(ch::VirtualOutput, val::Real)
	ch.val = val
	ch.ch.source(ch.val)
end

function load(ch::VirtualOutput, val::Real)
	ch.val = val
end

function fire(ch::VirtualOutput)
	ch.ch.source(ch.val)
end

type MathInput <: Input
	label::(String,String)
	val::Float64
	f::Function
end

MathInput(f::Function, label::(String,String) = ("Unnamed Math","")) = MathInput(label, f(), f)
val(ch::MathInput) = ch.val

function measure(ch::MathInput)
	ch.val = ch.f()
end