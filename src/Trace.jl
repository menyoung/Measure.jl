### Trace: sweep and plot in real time.
# 1. feed data to a "plotting server" by raw TCP socket
# this is achieved by printing a JSON.
# 2. save data periodically into the filesystem

import JSON
using Plotly, Requests

export streamer, tracer, traces

function openurl(url::AbstractString)
    @osx_only run(`open $url`)
    @windows_only run(`start $url`)
    @linux_only run(`xdg-open $url`)
end

function streamer(ch0::Output, ch1::Input, x_itr, tstep, token::ASCIIString)
	plt = Plotly.plot([Dict("x"=>Float64[], "y"=>Float64[],
		"type"=>"scatter", "mode"=>"lines",
		"stream"=>Dict("token"=>"mgd0qvicun","maxpoints"=>"$(9*length(x_itr))"));])
	openurl("$(plt["url"]).embed")
	str = Requests.post_streaming("http://stream.plot.ly/",
		headers=Dict("plotly-streamtoken"=>token,
			"Transfer-encoding"=>"chunked"), write_body=false)
	wave = map(x_itr) do x
		source(ch0, x)
		sleep(tstep)
		y = measure(ch1)
		write_chunked(str,"$(JSON.json(Dict('x'=>x,'y'=>y)))\n")
		y
	end
	wave
end

function tracer(ch0::Output, ch1::Input, x_itr, tstep, port)
	# start plot server, take data and print to plotter
	# `julia PlotServer.jl`
	plot = connect(port)
	wave = map(x_itr) do x
		source(ch0, x)
		sleep(tstep)
		y = measure(ch1)
		JSON.print(plot, (x,y))
		println(plot, "")
		# printf(plot, "%f %f\n", x, y)
		y
	end
	close(plot)
	wave
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
