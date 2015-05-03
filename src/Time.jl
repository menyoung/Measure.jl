### time.jl a fake output instrument for inputs over time
# sourcing 0 or negative time resets clock.
# sourcing positive value returns when that many seconds passed since reset

export Timer, TimeOutput, TimeInput
export source, measure

type Timer <: Instrument
	t0::Float64
	name::String
end

Timer() = Timer(time(), "Timer")

type TimeOutput <: Output
	instr::Timer
end

function source(ch::TimeOutput, val::Real)
	if val < eps()
		ch.instr.t0 = time()
	else
		while val + ch.instr.t0 > time()
			sleep(0.01)
		end
	end
end
val(ch::TimeOutput) = time() - ch.instr.t0
label(ch::TimeOutput) = "Output Timer"

type TimeInput <: Input
	instr::Timer
end

measure(ch::TimeInput) = time() - ch.instr.t0
val(ch::TimeInput) = time() - ch.instr.t0
label(ch::TimeOutput) = "Timer Reading"