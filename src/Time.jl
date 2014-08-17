### time.jl a fake output instrument for inputs over time

type TimeChannel
	t0::Float
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