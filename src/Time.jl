### time.jl a fake output instrument for inputs over time
# sourcing 0 or negative time resets clock.
# sourcing positive value returns when that many seconds passed since reset

export Timing, TimeOutput, TimeInput
export source, measure

type Timing <: Instrument
	t0::Float64
	name::String
end

Timing() = Timing(time(), "Timing")

type TimeOutput <: Output
	instr::Timing
end

function source(ch::TimeOutput, value::Real)
	if value < eps()
		ch.instr.t0 = time()
	else
		while value + ch.instr.t0 > time()
			sleep(0.001)
		end
	end
end
value(ch::TimeOutput) = time() - ch.instr.t0
label(ch::TimeOutput) = "Output Timing"

type TimeInput <: Input
	instr::Timing
end

measure(ch::TimeInput) = time() - ch.instr.t0
value(ch::TimeInput) = time() - ch.instr.t0
label(ch::TimeInput) = "Timing Reading"
