### PlotServer.jl: real-time plotting server
# receive data via raw TCP: only accept one client
# push data via WebSockets
# for each WS client, first push all current data.
# Then for each incoming data, push it to all clients at regular intervals.

import HttpServer
import WebSockets
using JSON

wsh = WebSockets.WebSocketHandler() do req,client
		msg = WebSockets.read(client)
		println(msg)
		for (i,x,y) in Task(() -> produce_datum(ch0, ch1, x_itr, tstep))
			data[i] = y
			WebSockets.write(client, json((x,y)))
        end
    end

server = HttpServer.Server(wsh)
try
	HttpServer.run(server,8080)
catch
	data
end