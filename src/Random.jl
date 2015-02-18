### random.jl a fake input channel that just reads random numbers.

export RandomInput

type RandomInput <: Input
	label::(String,String)
end

measure(ch::RandomInput) = rand()
function trigger(ch::RandomInput)
end
fetch(ch::RandomInput) = rand()