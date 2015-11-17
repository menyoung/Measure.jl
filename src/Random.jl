### random.jl a fake input channel that just reads random numbers.

export RandomInput

type RandomInput <: Input
	label::Label
end

RandomInput() = RandomInput(Label("Random Channel","au"))

val(ch::RandomInput) = rand()
measure(ch::RandomInput) = rand()
trigger(ch::RandomInput) = nothing
fetch(ch::RandomInput) = rand()
