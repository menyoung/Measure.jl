### time.jl a fake output instrument for inputs over time
# sourcing 0 or negative time resets clock.
# sourcing positive value returns 

export TimeChannel

type TimeChannel <: Output
	t0::Float64
end

TimeChannel() = TimeChannel(time())

function source(ch::TimeChannel, val::Real)
	if val < eps()
		ch.t0 = time()
	else
		while val + ch.t0 > time()
			sleep(0.01)
		end
	end
end