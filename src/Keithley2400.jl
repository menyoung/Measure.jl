### Keithley 2400 concrete types and methods

export Keithely2400, Keithley2400Vb, Keithley2400Ib, Keithley24004W, Keithley2400Vsrc, Keithley2400Imeas
export source, measure, trigger, fetch

abstract Keithley2400 <: GpibInstrument

type Keithley2400Vb <: Keithley2400 # source voltage, measure current
	vi::ViSession 	# this is the GpibInstrument object!
	range::Float64 	# output range
	cmpl::Float64 	# compliance current
	name::String
end

# constructor takes VISA resource manager and resource rsrc. Other parameters are named not positional
function Keithley2400Vb(rm::ViSession, rsrc::String; range = -1, cmpl = -1, name::String = "")
	vi = viOpen(rm, rsrc)
	viClear(vi)
	viWrite(vi,"SOUR:FUNC VOLT")
	viWrite(vi,"SENS:FUNC \"CURR\"")
	viWrite(vi,"FORM:ELEM CURR")
	viWrite(vi,"SENS:CURR:RANGE:AUTO 1")
	viWrite(vi,"OUTP ON")
	if range < 0
		viWrite(vi,"SOUR:VOLT:RANGE?")
		range = parse(bytestring(viRead(vi)))
	else
		if range > 210
			warn("Keithley 2400 $rsrc range cannot be above 210V. Was given $range V. Setting it to max 210V.")
			range = 210
		end
		viWrite(vi,"SOUR:VOLT $range")
	end
	if cmpl < 0
		viWrite(vi,"SENS:CURR:PROT?")
		cmpl = parse(bytestring(viRead(vi)))
	else
		max_cmpl = range > 20 ? 0.105 : 1.05
		if cmpl > max_cmpl
			warn("Keithley 2400 $rsrc compliance cannot be above 105uA. Was given $cmpl A. Setting it to maximum for this range.")
			cmpl = max_cmpl
		end
		viWrite(vi,"SENS:CURR:PROT $cmpl")
	end
	Keithley2400Vb(vi, range, cmpl, name == "" ? rsrc : name)
end

type Keithley2400Ib <: Keithley2400 # source current, measure voltage
	vi::ViSession 	# this is the GpibInstrument object!
	range::Float64
	cmpl::Float64
end

type Keithley24004W <: Keithley2400 # 4-wire ohms
	vi::ViSession 	# this is the GpibInstrument object!
	range::Float64
	cmpl::Float64
end

type Keithley2400Vsrc <: Output
	instr::Keithley2400Vb
	label::Label
	value::Float64
	step::Float64
	delay::Float64
end

function Keithley2400Vsrc(instr::Keithley2400Vb, value::Real = NaN, step::Real = NaN, delay::Real = NaN, label::Label = Label("Unnamed Keithley","V"))
	Keithley2400Vsrc(
		instr,
		label,
		isnan(value) ? ask(instr, "SOUR:VOLT?") : value,
		isnan(step) ? 0.001 : step,
		isnan(delay) ? 0 : delay)
end

function source(ch::Keithley2400Vsrc, value::Real)
	timer = Timing()
	timeOut = TimeOutput(timer)
	timeIn = TimeInput(timer)
	time = 0.0
	while (abs(value - ch.value) > ch.step)
		time += ch.delay
		source(timeOut, time)
		ch.value += (value > ch.value) ? ch.step : -ch.step
		write(ch.instr, "SOUR:VOLT $(ch.value)")
	end
	time += ch.delay
	source(timeOut, time)
	ch.value = value
	write(ch.instr, "SOUR:VOLT $(ch.value)")
end

type Keithley2400Imeas <: BufferedInput
	instr::Keithley2400Vb
	label::Label
	value::Float64
end

function Keithley2400Imeas(instr::Keithley2400Vb, label::Label = Label("Unnamed Keithley","A"))
	Keithley2400Imeas(
		instr,
		label,
		ask(instr, "READ?"))
end

function measure(ch::Keithley2400Imeas)
	ch.value = ask(ch.instr, "READ?")
end
trigger(ch::Keithley2400Imeas) = write(ch.instr, "INIT")
function fetch(ch::Keithley2400Imeas)
	ch.value = ask(ch.instr, "FETC?")
end
