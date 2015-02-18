### Virtual.jl a virtual and depent outputs, math operations on inputs
#

type VirtualOutput <: BufferedOutput
	ch0::Set{DependentOutput}
	lab::label
	val::Float64
end

function VirtualOutput(label::Label = Label("Unnamed Virtual",""))
	lab = label
end

function source(ch::VirtualOutput, val::Real)
	ch.val = val
	ch.ch.source(ch.val)
end

type DependentOutput <: Output
	ch::Output
	lab::Label
	val::Float64
	f::Function
end

function DependentOutput(chan::Output, func::Function, label::Label = Label("Unnamed Dependent",""))
	ch = chan
	lab = label
	f = func
	val = func()
end

function source(ch::DependentOutput, val::Real)
	ch.val = ch.f()
	ch.ch.source(ch.val)
end

type MathInput <: Input
	lab::Label
	val::Float64
	f::Function
end

function MathInput(func::Function, label::Label = Label("Unnamed Math",""))
	lab = label
	f = func
	val = func()
end

function measure(ch::MathInput)
	ch.val = ch.f()
	ch.ch.source(ch.val)
end