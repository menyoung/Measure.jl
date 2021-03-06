### Trace: sweep and plot in real time.
# 1. feed data to a "plotting server" by raw TCP socket
# this is achieved by printing a JSON.
# 2. save data periodically into the filesystem

import JSON
# using Plotly, Requests

export stream, tracer, traces

function openurl(url::String)
    if is_apple()
      run(`open $url`)
    elseif is_windows()
      run(`start $url`)
    else
      run(`xdg-open $url`)
    end
end

# function stream(ch0::Output, ch1::Input, x_itr, tstep, token::String)
# 	plt = Plotly.plot(
#     [Dict("x"=>Float64[], "y"=>Float64[],
# 		  "type"=>"scatter", "mode"=>"lines",
# 		    "stream"=>Dict("token"=>"mgd0qvicun","maxpoints"=>"$(9*length(x_itr))"));],
#     Dict(
#       "layout"=>Dict("title"=>"testing",
#         "xaxis"=>Dict("title"=>"$(label(ch0).name) ($(label(ch0).unit))"),
#         "yaxis"=>Dict("title"=>"$(label(ch1).name) ($(label(ch1).unit))"))
#       )
#     )
# 	openurl("$(plt["url"]).embed")
# 	str = Requests.post_streaming("http://stream.plot.ly/",
# 		headers=Dict("plotly-streamtoken"=>token,
# 			"Transfer-encoding"=>"chunked"), write_body=false)
# 	wave = map(x_itr) do x
# 		source(ch0, x)
# 		sleep(tstep)
# 		y = measure(ch1)
# 		write_chunked(str,"$(JSON.json(Dict('x'=>x,'y'=>y)))\n")
# 		y
# 	end
# 	wave
# end

function tracer(ch0::Output, ch1::Input, x_itr, tstep, port)
	# start plot server, take data and print to plotter
  server = Pkg.dir("Measure","src","PlotServer.jl")
  httport = 8080
  p = spawn(`julia $server $port $httport`)
  finalizer(p, kill)
  sleep(2)
	plot = connect(port)
  openurl("http://localhost:$httport")
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
  kill(p)
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
