### Trace: sweep and plot in real time.
# 1. feed data to a "plotting server" by raw TCP socket
# 2. save data periodically into the filesystem
# the plotting server caches all the data that should be live-plotted
# the server: written in what language/framework? Could be Julia, Python, or Node.
# the D3.js rendering page receives the data from the plotting server by WebSockets

export trace, traces

# a producer function takes data: unnecessary in current framework
# function produce_datum(ch0::Output, ch1::Input, x_itr, tstep)
# 	for (i,x) in enumerate(x_itr)
# 		source(ch0, x)
# 		sleep(tstep)
# 		produce(i,x,measure(ch1))
# 	end
# end

function trace(ch0::Output, ch1::Input, x_itr, tstep, port)
	# start the plot server, take data and feed to server
	`julia PlotServer.jl`
	map(x_itr) do x
		source(ch0, x)
		sleep(tstep)
		measure(ch1)
		feed_data()
	end
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