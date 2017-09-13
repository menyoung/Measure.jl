### Random.jl a fake input channel that just reads random numbers.

export RandomInput

mutable struct RandomInput{T} <: Input where T <: Any
	value::T
	label::Label
end

RandomInput() = RandomInput{Float64}(rand(),Label("Random Signal","au"))

function measure(s::RandomInput{T}) where T <: Real
	s.value = rand()
end

function trigger(s::RandomInput{T}) where T <: Real
	s.value = rand()
end

fetch(s::RandomInput{T}) where {T<:Any} = value(s)
