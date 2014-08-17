### time.jl a fake output instrument for inputs over time
# sourcing 0 or negative time resets clock.
# sourcing positive value returns 

export TimeChannel

type TimeChannel
	t0::Float64
end

TimeChannel() = TimeChannel(time())

TimeChannel <: Output

function source(ch::TimeChannel, val::Float)
	if val < eps()
		ch.t0 = time()
	else
		while val + time() > ch.t0
		end
	end
end