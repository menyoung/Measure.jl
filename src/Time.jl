### time.jl a fake output instrument for inputs over time
# sourcing 0 or negative time resets clock.
# sourcing positive value returns when that many seconds passed since reset

export Timing, TimeOutput, TimeInput
export source, measure

mutable struct Timing <: Instrument
	t0::Float64
	name::String
end

Timing() = Timing(time(), "Timing")

struct TimeOutput <: Output
	instr::Timing
end

function source(s::TimeOutput, value::Real)
	if value < eps()
		s.instr.t0 = time()
	else
		while value + s.instr.t0 > time()
			sleep(0.001)
		end
	end
end
value(s::TimeOutput) = time() - s.instr.t0
label(s::TimeOutput) = "Output Timing"

struct TimeInput <: Input
	instr::Timing
end

measure(s::TimeInput) = time() - s.instr.t0
value(s::TimeInput) = time() - s.instr.t0
label(s::TimeInput) = "Timing Reading"
