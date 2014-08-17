### random.jl a fake input instrument that just reads random numbers.

type RandomInput
end

RandomInput <: Input

function measure(ch::RandomInput)
	return rand()
end