### time.jl a fake output instrument for inputs over time
# sourcing 0 or negative time resets clock.
# sourcing positive value returns after waiting that much time.
# TODO: currently does not behave right.

export TimeOutput, TimeInput

type Timer <: Instrument
	t0::Float64
end

type TimeOutput <: Output
	instr::Timer
end

type TimeInput <: Input
	instr::Timer
end

TimeInput() = TimeInput(time())
TimeOutput() = TimeOutput(time())

function source(ch::TimeOutput, val::Real)
	if val < eps()
		ch.instr.t0 = time()
	else
		while val + ch.t0 > time()
			sleep(0.01)
		end
	end
end

measure(ch::TimeInput) = time() - ch.instr.t0