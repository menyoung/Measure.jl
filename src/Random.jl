### random.jl a fake input instrument that just reads random numbers.

export RandomInput

type RandomInput <: Input
end

function measure(ch::RandomInput)
	return rand()
end