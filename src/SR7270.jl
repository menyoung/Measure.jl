### Signal Recovery 7270 concrete types and methods

export SR7270, SR7270Output, SR7270Ampl, SR7270Freq, SR7270DAC1
export SR7270Input, SR7270X2, SR7270Y2, SR7270XER, SR7270YER
export SR7270X, SR7270Y, SR7270R, SR7270P, SR7270XY, SR7270RP, SR7270A1, SR7270A2
export source, measure

mutable struct SR7270 <: SocketInstrument
	addr::String # this is the IP address as a string
	port::Int # this is the port number
	sock::IO # the IO stream object of the socket
	# res::Int # high reserve = 0 normal = 1 low noise = 2
	# mode::Int # IMODE: current or voltage lock-in?
	sens::Float64 # sensitivity in V
	tc::Float64 # time constant in s
	param::Dict # dictionary of parameters (not required to use)
	# some possible parameters:
	# stat::String # the status byte as string, updated at every read
	# over::String # the overload byte as string, updated at every read
	name::String # the name. All instruments must be named.
end

# converting back and forth between codes and values for sensitivity/range/time constant/etc
SR7270_sens_conv(sens_code::Int) = 10.0 ^ (div(sens_code,3)-9) * (1 + rem(sens_code,3)^2)
SR7270_tc_conv(tc_code::Int) = 10.0 ^ (div(tc_code,3)-5) * (1 + rem(tc_code,3)^2)

function SR7270sockread(sock::IO)
	flush(sock)
	msg = readavailable(sock)
	# instr.param["stat"] = bits(msg[end-1])
	# instr.param["over"] = bits(msg[end])
	parse(String(msg[1:search(msg,'\n')]))
	# there are three termination characters...
end

# constructor takes IP address and port number (default 50000). Other parameters are named not positional
function SR7270(addr::String, port::Int = 50000; sens = -1, tc = -1, param::Dict = Dict(), name::String = "")
	sock = connect(addr, port)
	if sens < 0
		write(sock,"SEN.\r\n\0") # TODO FIX THIS
		sens = SR7270sockread(sock)
	else
		if sens > 1
			warn("SR7270 $addr range cannot be above 1V. Was given $sens V. Setting it to 1V.")
			sens = 1
		end
		sens_code = get_code(SR7270_sens_conv, sens, 1)
		write(sock,"SEN $sens_code\r\n\0")
	end
	if tc < 0
		write(sock,"TC.\r\n\0") # TODO FIX THIS
		tc = SR7270sockread(sock)
	else
		if tc > 1E5
			warn("SR7270 $addr time constant cannot be above 100ks. Was given $tc s. Setting it to max 100ks.")
			tc = 1E5
		end
		tc_code = get_code(SR7270_tc_conv, tc)
		write(sock,"TC $tc_code\r\n\0")
	end
	SR7270(addr, port, sock, sens, tc, param, name == "" ? "Sig Rec 7270 $addr" : name)
end

function read(instr::SR7270)
	msg = readavailable(instr.sock)
	# store the status and overload bit strings as strings
	instr.param["stat"] = bits(msg[end-1])
	instr.param["over"] = bits(msg[end])
	while ((i = findfirst(msg,0)) > 0)
    deleteat!(msg,i:i+2)
	end
	parse(String(msg))
	# there are three termination characters...
end
function write(instr::SR7270, msg::String)
  flush(instr.sock)
	write(instr.sock,string(msg,"\r\n\0"))
	flush(instr.sock)
end

abstract type SR7270Output <: Output end

mutable struct SR7270Ampl <: SR7270Output
	instr::SR7270
	value::Float64
	label::Label
end

mutable struct SR7270Freq <: SR7270Output
	instr::SR7270
	value::Float64
	label::Label
end

mutable struct SR7270DAC1 <: SR7270Output
	instr::SR7270
	value::Float64
	label::Label
end

function SR7270DAC1(instr::SR7270, value::Real, label::Label = Label("Sig Rec 7270 DAC1 output","V"))
	ask(instr, "DAC. 1 $value")
	SR7270DAC1(instr,value,label)
end

function SR7270Ampl(instr::SR7270, value::Real, label::Label = Label("Sig Rec 7270 Osc Ampl","V"))
	ask(instr, "OA. $value")
	SR7270Ampl(instr,value,label)
end

function SR7270Freq(instr::SR7270, value::Real = NaN, label::Label = Label("Sig Rec 7270 Osc Freq","Hz"))
	if isnan(value)
		value = ask(instr, "FRQ.")
	else
		value = round(1000.0*value)/1000.0
		ask(instr, "OF. $value")
	end
	SR7270Freq(instr,value,label)
end

source(s::SR7270DAC1, value::Real) = ask(s.instr, "DAC. 1 $(round(1000.0*value)/1000.0)")
### ref voltage Output
source(s::SR7270Ampl, value::Real) = ask(s.instr, "OA. $value")
# source(s::SR7270Freq, value::Real) = write(s.instr, "OF. $value")
# frequency: if 0 or negative then just read
function source(s::SR7270Freq, value::Real)
	if value < eps()
		s.value = ask(s.instr, "FRQ.")
	else
		s.value = round(1000.0*value)/1000.0
		ask(s.instr, "OF. $(s.value)")
	end
end

abstract type SR7270Input <: Input end

mutable struct SR7270X <: SR7270Input
	instr::SR7270
	value::Float64
	label::Label
end

mutable struct SR7270Y <: SR7270Input
	instr::SR7270
	value::Float64
	label::Label
end

mutable struct SR7270R <: SR7270Input
	instr::SR7270
	value::Float64
	label::Label
end

mutable struct SR7270P <: SR7270Input
	instr::SR7270
	value::Float64
	label::Label
end

mutable struct SR7270RP <: SR7270Input
	instr::SR7270
	value::Tuple{Float64,Float64}
	label::Label
end

mutable struct SR7270XER <: SR7270Input
	instr::SR7270
	value::Float64
	label::Label
end

mutable struct SR7270YER <: SR7270Input
	instr::SR7270
	value::Float64
	label::Label
end

mutable struct SR7270XY <: SR7270Input
	instr::SR7270
	value::Tuple{Float64,Float64}
	label::Label
end

mutable struct SR7270X2 <: SR7270Input
	instr::SR7270
	value::Float64
	label::Label
end

mutable struct SR7270Y2 <: SR7270Input
	instr::SR7270
	value::Float64
	label::Label
end

mutable struct SR7270A1 <: SR7270Input
	instr::SR7270
	value::Float64
	label::Label
end

mutable struct SR7270A2 <: SR7270Input
	instr::SR7270
	value::Float64
	label::Label
end

function measure(s::SR7270XY)
	s.value = eval(ask(s.instr, "XY."))
end
function measure(s::SR7270RP)
	s.value = eval(ask(s.instr, "MP."))
end
function measure(s::SR7270XER)
	s.value = ask(s.instr, "XER") # integer output!
end
function measure(s::SR7270YER)
	s.value = ask(s.instr, "YER") # integer output!
end
function measure(s::SR7270X)
	s.value = ask(s.instr, "X.") # TODO FIX THIS
end
function measure(s::SR7270Y)
	s.value = ask(s.instr, "Y.") # TODO FIX THIS
end
function measure(s::SR7270R)
	s.value = ask(s.instr, "MAG.")
end
function measure(s::SR7270P)
	s.value = ask(s.instr, "PHA.")
end

function measure(s::SR7270X2)
	s.value = ask(s.instr, "X2.")
end
function measure(s::SR7270Y2)
	s.value = ask(s.instr, "Y2.")
end

function measure(s::SR7270A1)
	s.value = ask(s.instr, "ADC1.")
end
function measure(s::SR7270A2)
	s.value = ask(s.instr, "ADC2.")
end
