### SRS DS345 concrete types and methods. This is a temporary solution for use with Prologix GPIB-Ethernet.
export DS345, DS345Output, DS345Freq, DS345AC, DS345DC, source

type DS345 <: SocketInstrument
	addr::String # this is the Prologix IP address as a string
	gpib::Int # this is the gpib instrument address
	sock::IO # the IO stream object of the socket
	# res::Int # high reserve = 0 normal = 1 low noise = 2
	func::Int # the function 0=sine, 1=sq, 2=tri, 3=ramp, 4=noise, 5=arb
	# sens::Float64 # sensitivity in V
	# tc::Float64 # time constant in s
	param::Dict # dictionary of parameters (not required to use)
	# some possible parameters:
	# stat::String # the status byte as string, updated at every read
	# over::String # the overload byte as string, updated at every read
	name::String # the name. All instruments must be named.
end

function DS345sockread(sock::IO)
	flush(sock)
	msg = readavailable(sock)
	# instr.param["stat"] = bits(msg[end-1])
	# instr.param["over"] = bits(msg[end])
	parse(String(msg[1:search(msg,'\n')]))
	# there are three termination characters...
end

# constructor takes Prologix IP address and gpib address. Other parameters are named not positional
function DS345(addr::String, gpib::Int; func = -1, param::Dict = Dict(), name::String = "")
	sock = connect(addr, 1234)
	if func < 0
		write(sock,"FUNC?\n")
		func = DS345sockread(sock)
	elseif in(func, collect(0:5))
    write(sock,"FUNC $func\n")
  else
    warn("DS345 function 0=sine, 1=sq, 2=tri, 3=ramp, 4=noise, 5=arb; defaulting to 0.")
    write(sock,"FUNC 1\n")
  end
	SR7270(addr, gpib, sock, func, param, name == "" ? "SRS DS345 gpib-ethernet $gpib" : name)
end

function read(instr::DS345)
  flush(sock)
	msg = readavailable(instr.sock)
	# store the status and overload bit strings as strings
	# instr.param["stat"] = bits(msg[end-1])
	# instr.param["over"] = bits(msg[end])
	# while ((i = findfirst(msg,0)) > 0)
  #  deleteat!(msg,i:i+2)
	# end
	parse(String(msg[1:search(msg,'\n')]))
	# there are three termination characters...
end
function write(instr::DS345, msg::String)
  flush(instr.sock)
	write(instr.sock,string(msg,"\n"))
	flush(instr.sock)
end

abstract DS345Output <: Output

type DS345Freq <: DS345Output
	instr::DS345
	value::Float64
	label::Label
end

type DS345AC <: DS345Output
	instr::DS345
	value::Float64
	label::Label
end

type DS345DC <: DS345Output
	instr::DS345
	value::Float64
	label::Label
end

function DS345Freq(instr::DS345, value::Real, label::Label = Label("SRS DS345 Frequency","V"))
	if isnan(value)
		value = ask(instr, "FREQ?")
	else
		value = round(1000000.0*value)/1000000.0
		write(instr, "FREQ $value")
	end
	DS345Freq(instr,value,label)
end

function DS345AC(instr::DS345, value::Real, label::Label = Label("SRS DS345 AC amplitude","V"))
	if isnan(value)
		value = ask(instr, "AMPL?")
	else
		value = round(1000.0*value)/1000.0
		write(instr, "AMPL $value")
	end
	DS345Freq(instr,value,label)
end

function DS345DC(instr::DS345, value::Real, label::Label = Label("SRS DS345 DC offset","V"))
	if isnan(value)
		value = ask(instr, "OFFS?")
	else
		value = round(1000.0*value)/1000.0
		write(instr, "OFFS $value")
	end
	DS345Freq(instr,value,label)
end

source(ch::DS345Freq, value::Real) = write(ch.instr, "FREQ $value")
source(ch::DS345AC, value::Real) = write(ch.instr, "AMPL $value")
source(ch::DS345DC, value::Real) = write(ch.instr, "OFFS $value")
