### PlotServer.jl: real-time plotting server
# receive data via raw TCP: only accept one client
# push data via WebSockets
# for each WS client, first push all current data.
# Then for each incoming data, push it to all clients at regular intervals.