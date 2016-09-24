### Signal Recovery 7270 concrete types and methods

export SR7270, SR7270Output, SR7270Ampl, SR7270Freq, SR7270Input, SR7270X, SR7270Y, SR7270R, SR7270P, SR7270XY, SR7270RP, source, measure

type SR7270 <: SocketInstrument
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
		write(sock,"SEN.")
		sens = SR7270sockread(sock)
	else
		if sens > 1
			warn("SR7270 $addr range cannot be above 1V. Was given $sens V. Setting it to 1V.")
			sens = 1
		end
		sens_code = get_code(SR7270_sens_conv, sens, 1)
		write(sock,"SEN $sens_code")
	end
	if tc < 0
		write(sock,"TC.")
		tc = SR7270sockread(sock)
	else
		if tc > 1E5
			warn("SR830 $addr time constant cannot be above 100ks. Was given $tc s. Setting it to max 100ks.")
			tc = 1E5
		end
		tc_code = get_code(SR830_tc_conv, tc)
		viWrite(vi,"TC $tc_code")
	end
	SR7270(addr, port, sock, sens, tc, param, name == "" ? "Sig Rec 7270 $addr" : name)
end

function read(instr::SR7270)
	flush(instr.sock)
	msg = readavailable(instr.sock)
	# store the status and overload bit strings as strings
	instr.param["stat"] = bits(msg[end-1])
	instr.param["over"] = bits(msg[end])
	parse(String(msg[1:findfirst(msg,'\0')-1]))
	# there are three termination characters...
end
write(instr::SR7270, msg::String) = write(instr.sock,msg)

abstract SR7270Output <: Output

type SR7270Ampl <: SR7270Output
	instr::SR7270
	val::Float64
	label::Label
end

type SR7270Freq <: SR7270Output
	instr::SR7270
	val::Float64
	label::Label
end

function SR7270Ampl(instr::SR7270, val::Real, label::Label = Label("Sig Rec 7270 Osc Ampl","V"))
	write(instr, "OA. $val")
	SR7270Ampl(instr,val,label)
end

function SR830Freq(instr::SR830, val::Real = NaN, label::Label = Label("Sig Rec 7270 Osc Freq","Hz"))
	if isnan(val)
		val = ask(instr, "FRQ.")
	else
		write(ch.instr, "OF. $val")
	end
	SR830Freq(instr,val,label)
end

### ref voltage Output
source(ch::SR7270Ampl, val::Real) = write(ch.instr, "OA. $val")
source(ch::SR7270Freq, val::Real) = write(ch.instr, "OF. $val")

# if 0 or negative then just read
function source(ch::SR7270Freq, val::Real)
	if val < eps()
		ch.val = ask(ch.instr, "FRQ.")
	else
		ch.val = val
		write(ch.instr, "OF. $val")
	end
end

abstract SR7270Input <: Input

type SR7270X <: SR7270Input
	instr::SR7270
	val::Float64
	label::Label
end

type SR7270Y <: SR7270Input
	instr::SR7270
	val::Float64
	label::Label
end

type SR7270R <: SR7270Input
	instr::SR7270
	val::Float64
	label::Label
end

type SR7270P <: SR7270Input
	instr::SR7270
	val::Float64
	label::Label
end

type SR7270RP <: SR7270Input
	instr::SR7270
	val::Tuple{Float64,Float64}
	label::Label
end

type SR7270XY <: SR7270Input
	instr::SR7270
	val::Tuple{Float64,Float64}
	label::Label
end

function measure(ch::SR7270XY)
	ch.val = ask(ch.instr, "XY.")
end
function measure(ch::SR7270RP)
	ch.val = ask(ch.instr, "MP.")
end

function measure(ch::SR7270X)
	ch.val = ask(ch.instr, "X.")
end
function measure(ch::SR7270Y)
	ch.val = ask(ch.instr, "Y.")
end
function measure(ch::SR7270R)
	ch.val = ask(ch.instr, "MAG.")
end
function measure(ch::SR7270P)
	ch.val = ask(ch.instr, "PHA")
end
