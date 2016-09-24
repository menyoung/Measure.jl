### abstract types and methods for socket instruments

abstract SocketInstrument <: Instrument

# need IP address
addr(instr::SocketInstrument) = instr.addr
# need port number
port(instr::SocketInstrument) = instr.port
# stream object of the socket
sock(instr::SocketInstrument) = instr.sock
