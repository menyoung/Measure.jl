### Trace: sweep and plot in real time. Save data into filesystem.

export trace, traces

using Gadfly

### should make new interactive window for current trace, then output
### final result into the interactive environment.
function trace(ch0::Output, ch1::Input, x_itr, tstep)
	data = zeros(length(x_itr))
	# figure()
	# line, = plot(x_itr,data)
	for (i,x) in enumerate(x_itr)
		source(ch0, x)
		sleep(tstep)
		data[i] = measure(ch1)
		# line.set_ydata(data)
		plot(x = x_itr, y = data)
	end
	data
end

function traces(ch0::Output, ch2::Array{Input,1}, x_itr, tstep)
	n = length(ch1)
	data = Array(Float64, length(x_itr), n)
	figure()
	for (i,x) in enumerate(x_itr)
		source(ch0,x)
		sleep(tstep)
		for ch in filter(x -> isa(x,BufferedInput), ch2)
			trigger(ch)
		end
		for (k,ch) in enumerate(ch2)
			subplot(n, 1, k)
			data[i,k] = isa(ch,BufferedInput)? fetch(ch) : measure(ch)
		end
	end
	data
end