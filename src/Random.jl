### random.jl a fake input channel that just reads random numbers.

export RandomInput

type RandomInput <: Input
	label::(String,String)
end

RandomInput() = RandomInput("Random Channel")

val(ch::RandomInput) = rand()
measure(ch::RandomInput) = rand()
trigger(ch::RandomInput) = nothing
fetch(ch::RandomInput) = rand()