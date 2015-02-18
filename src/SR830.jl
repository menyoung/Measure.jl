### SR830 concrete types and methods

export SR830, SR830Output, SR830Ampl, SR830Freq, SR830Input, SR830X, SR830Y, SR830R, SR830P, SR830XY, SR830RP, measure

type SR830 <: GpibInstrument
	vi::PyObject # this is the GpibInstrument object!
	sens::Float64 # sensitivity in V
	res::Int # high reserve = 0 normal = 1 low noise = 2
	tc::Float64 # time constant in s
	name::String
end

# converting back and forth between codes and values for sensitivity/range/time constant/etc
SR830_sens_conv(sens_code) = signif((10 ^ floor((sens_code + 1) / 3)) * ((sens_code % 3 == 0)? 2 : ((sens_code % 3 == 1)? 5 : 1)) * 1e-9, 2)
SR830_tc_conv(tc_code) = (10 ^ floor(tc_code/ 2) * ((tc_code % 2 == 1)? 3 : 1)) * 10e-6

# start from 0, increment to get smallest code that gives range at least as large as target.
function get_code(conv, target)
	code = 0
	while (target > conv(code))
		code += 1
	end
	code
end

# constructor takes VISA resource manager and resource rsrc. Other parameters are named not positional
function SR830(rm::PyObject, rsrc::String; sens = -1, res = -1, tc = -1, name::String = "")
	vi = rm.get_instrument(rsrc)
	# default parameters: -1 means read the current state and legislate here.
	if sens < 0
		sens_code = vi[:ask]("SENS?")
		sens = SR830_sens_conv(sens_code)
	else
		if sens > 1
			warn("SR830 $rsrc range cannot be above 1V. Was given $sens V. Setting it to 1V.")
			sens = 1
		end
		sens_code = get_code(SR830_sens_conv, sens)
		vi[:write]("SENS $sens_code")
	end
	if res < 0
		res = vi[:ask]("RMOD?")
	else
		if !(res in 0:2)
			warn("SR830 $rsrc reserve must be 0 1 or 2. Was given $res. Setting to normal (1).")
			res = 1
		end
		vi[:write]("RMOD $res")
	end
	if tc < 0
		tc_code = vi[:ask]("OFLT?")
		tc = SR830_tc_conv(tc_code)
	else
		if tc > 30000
			warn("SR830 $rsrc time constant cannot be above 30ks. Was given $tc s. Setting it to max 30ks.")
			tc = 30000
		end
		tc_code = get_code(SR830_tc_conv, sens)
		vi[:write]("OFLT $tc_code")
	end
	SR830(vi, sens, res, tc, name == "" ? rsrc : name)
end

abstract SR830Output <: Output

type SR830Ampl <: SR830Output
	instr::SR830
	label::(String,String)
	val::Float64
end

type SR830Freq <: SR830Output
	instr::SR830
	label::(String,String)
	val::Float64
end

function SR830Freq(instr::SR830, val::Real = NaN, label::(String,String) = ("Lockin Frequency","V"))
	if isnan(val)
		val = ask(instr, "SLVL?")
	else
		write(ch.instr, "SLVL $val")
	end
	SR830Ampl(instr,label,val)
end

function SR830Ampl(instr::SR830, val::Real = NaN, label::(String,String) = ("Lockin Reference Amplitude","V"))
	if isnan(val)
		val = ask(instr, "SLVL?")
	else
		write(ch.instr, "SLVL $val")
	end
	SR830Ampl(instr,label,val)
end

### ref voltage Output
# if 0 or negative then just read
function source(ch::SR830Ampl, val::Real)
	if val < eps()
		ch.val = ask(ch.instr, "FREQ?")
	else
		ch.val = val
		write(ch.instr, "FREQ $val")
	end
end

function source(ch::SR830Freq, val::Real)
	if val < eps()
		ch.val = ask(ch.instr, "FREQ?")
	else
		ch.val = val
		write(ch.instr, "FREQ $val")
	end
end

abstract SR830Input <: Input

type SR830X <: SR830Input
	instr::SR830
	label::(String,String)
	val::Float64
end

type SR830Y <: SR830Input
	instr::SR830
	label::(String,String)
	val::Float64
end

type SR830R <: SR830Input
	instr::SR830
	label::(String,String)
	val::Float64
end

type SR830P <: SR830Input
	instr::SR830
	label::(String,String)
	val::Float64
end

type SR830RP <: SR830Input
	instr::SR830
	label::(String,String)
	val::(Float64,Float64)
end

type SR830XY <: SR830Input
	instr::SR830
	label::(String,String)
	val::(Float64,Float64)
end

function measure(ch::SR830XY)
	ch.val = ask(ch.instr, "SNAP? 1,2")
end
function measure(ch::SR830RP)
	ch.val = ask(ch.instr, "SNAP? 3,4")
end

function measure(ch::SR830X)
	ch.val = ask(ch.instr, "OUTP? 1")
end
function measure(ch::SR830Y)
	ch.val = ask(ch.instr, "OUTP? 2")
end
function measure(ch::SR830R)
	ch.val = ask(ch.instr, "OUTP? 3")
end
function measure(ch::SR830P)
	ch.val = ask(ch.instr, "OUTP? 4")
end