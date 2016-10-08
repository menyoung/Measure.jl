### random.jl a fake input channel that just reads random numbers.

export RandomInput

type RandomInput <: Input
	value::Float64
	label::Label
end

RandomInput() = RandomInput(rand(),Label("Random Signal","au"))

measure(ch::RandomInput) = ch.value = rand()
trigger(ch::RandomInput) = ch.value = rand()
fetch(ch::RandomInput) = ch.value
