### PlotServer.jl: real-time plotting server
# receive data via raw TCP: only accept one client
# is dumb, i.e, feeds all strings received directly to the display client
# push data via WebSockets
# for each WS client, first push all current data.
# Then for each incoming data, push it to all clients at regular intervals.
# the plotting server caches all the data from its start
# the server: written in what language/framework? Could be Julia, Python, or Node.
# the D3.js rendering page receives the data from the plotting server by WebSockets

using HttpServer
using WebSockets
using JSON

# port numbers. TODO: get as command line arguments.

const tcport = 2014
const httport = 8080

# start listener on tcport

println("Start Live Plot Server")

# N = 0 # the number of data points so far
data = Array(String, 0)

listener = listen(tcport)
@async begin
	sock = accept(listener)
	for datum in eachline(sock)
		# print(datum)
		push!(data, datum)
	end
end

@printf("TCP listening on port %d\n", tcport)

# make WebSockets handlers

wsh = WebSocketHandler() do req,client
		println("display connected")
		i = 1 # to each client, serve data starting from the beginning
		while true
			if i > length(data)
				sleep(0.01)
				continue
			end
        	write(client, data[i])
        	i += 1
        end
    end
		# msg = WebSockets.read(client)
		# println(msg)
		# for (i,x,y) in Task(() -> produce_datum(ch0, ch1, x_itr, tstep))
		# 	data[i] = y
		# 	WebSockets.write(client, json((x,y)))
  #       end
  #   end

# start http server

server = Server(wsh)
run(server, httport)