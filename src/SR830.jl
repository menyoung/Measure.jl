### SR830 concrete types and methods

export SR830, SR830Output, SR830Ampl, SR830Freq, SR830Input, SR830X, SR830Y, SR830R, SR830P, SR830XY, SR830RP, source, measure

struct SR830 <: GpibInstrument
	vi::ViSession # this is the GpibInstrument object!
	sens::Float64 # sensitivity in V
	res::Int # high reserve = 0 normal = 1 low noise = 2
	tc::Float64 # time constant in s
	name::AbstractString
end

# converting back and forth between codes and values for sensitivity/range/time constant/etc
SR830_sens_conv(sens_code) = signif((10 ^ floor((sens_code + 1) / 3)) * ((sens_code % 3 == 0)? 2 : ((sens_code % 3 == 1)? 5 : 1)) * 1e-9, 2)
SR830_tc_conv(tc_code) = (10 ^ floor(tc_code/ 2) * ((tc_code % 2 == 1)? 3 : 1)) * 10e-6

# constructor takes VISA resource manager and resource rsrc. Other parameters are named not positional
function SR830(rm::ViSession, rsrc::String; sens = -1, res = -1, tc = -1, name::AbstractString = "")
	vi = viOpen(rm, rsrc)
	# default parameters: -1 means read the current state and legislate here.
	if sens < 0
		viWrite(vi,"SENS?")
		sens_code = parse(String(viRead(vi)))
		sens = SR830_sens_conv(sens_code)
	else
		if sens > 1
			warn("SR830 $rsrc range cannot be above 1V. Was given $sens V. Setting it to 1V.")
			sens = 1
		end
		sens_code = get_code(SR830_sens_conv, sens)
		viWrite(vi,"SENS $sens_code")
	end
	if res < 0
		viWrite(vi,"RMOD?")
		res = parse(String(viRead(vi)))
	else
		if !(res in 0:2)
			warn("SR830 $rsrc reserve must be 0 1 or 2. Was given $res. Setting to normal (1).")
			res = 1
		end
		viWrite(vi,"RMOD $res")
	end
	if tc < 0
		viWrite(vi,"OFLT?")
		tc_code = parse(String(viRead(vi)))
		tc = SR830_tc_conv(tc_code)
	else
		if tc > 30000
			warn("SR830 $rsrc time constant cannot be above 30ks. Was given $tc s. Setting it to max 30ks.")
			tc = 30000
		end
		tc_code = get_code(SR830_tc_conv, tc)
		viWrite(vi,"OFLT $tc_code")
	end
	SR830(vi, sens, res, tc, name == "" ? "SR830 $rsrc" : name)
end

abstract SR830Output <: Output

struct SR830Ampl <: SR830Output
	instr::SR830
	value::Float64
	label::Label
end

struct SR830Freq <: SR830Output
	instr::SR830
	value::Float64
	label::Label
end

function SR830Ampl(instr::SR830, value::Real = NaN, label::Label = Label("Lockin Output Amplitude","V"))
	if isnan(value)
		value = ask(instr, "SLVL?")
	else
		write(ch.instr, "SLVL $value")
	end
	SR830Ampl(instr,value,label)
end

function SR830Freq(instr::SR830, value::Real = NaN, label::Label = Label("Lockin Output Frequency","Hz"))
	if isnan(value)
		value = ask(instr, "FREQ?")
	else
		write(ch.instr, "FREQ $value")
	end
	SR830Freq(instr,value,label)
end

### ref voltage Output
# if 0 or negative then just read
function source(ch::SR830Ampl, value::Real)
	if value < eps()
		ch.value = ask(ch.instr, "SLVL?")
	else
		ch.value = value
		write(ch.instr, "SLVL $value")
	end
end

function source(ch::SR830Freq, value::Real)
	if value < eps()
		ch.value = ask(ch.instr, "FREQ?")
	else
		ch.value = value
		write(ch.instr, "FREQ $value")
	end
end

## types for DAC output 1

mutable struct SR830DAC{T} <: SR830Output
	instr::SR830
	value::Float64
	label::Label
end

function SR830DAC(instr::SR830, chnum, value::Real, label::Label = Label("SR830 DAC output","V"))
	write(instr, "AUXV $chnum $(round(1000.0*value)/1000.0)")
	SR830DAC{chnum}(instr,value,label)
end

source(ch::SR830DAC{1}, value::Real) = ask(ch.instr, "AUXV 1 $(round(1000.0*value)/1000.0)")
source(ch::SR830DAC{2}, value::Real) = ask(ch.instr, "AUXV 2 $(round(1000.0*value)/1000.0)")
source(ch::SR830DAC{3}, value::Real) = ask(ch.instr, "AUXV 3 $(round(1000.0*value)/1000.0)")
source(ch::SR830DAC{4}, value::Real) = ask(ch.instr, "AUXV 4 $(round(1000.0*value)/1000.0)")

abstract SR830Input <: Input

type SR830X <: SR830Input
	instr::SR830
	value::Float64
	label::Label
end

type SR830Y <: SR830Input
	instr::SR830
	value::Float64
	label::Label
end

type SR830R <: SR830Input
	instr::SR830
	value::Float64
	label::Label
end

type SR830P <: SR830Input
	instr::SR830
	value::Float64
	label::Label
end

type SR830RP <: SR830Input
	instr::SR830
	value::Tuple{Float64,Float64}
	label::Label
end

type SR830XY <: SR830Input
	instr::SR830
	value::Tuple{Float64,Float64}
	label::Label
end

function measure(ch::SR830XY)
	ch.value = ask(ch.instr, "SNAP? 1,2")
end
function measure(ch::SR830RP)
	ch.value = ask(ch.instr, "SNAP? 3,4")
end

function measure(ch::SR830X)
	ch.value = ask(ch.instr, "OUTP? 1")
end
function measure(ch::SR830Y)
	ch.value = ask(ch.instr, "OUTP? 2")
end
function measure(ch::SR830R)
	ch.value = ask(ch.instr, "OUTP? 3")
end
function measure(ch::SR830P)
	ch.value = ask(ch.instr, "OUTP? 4")
end
