### Keithley 2400 concrete types and methods

export Keithely2400, Keithley2400Vb, Keithley2400Ib, Keithley24004W, Keithley2400Vsrc, Keithley2400Imeas
export source, measure, trigger, fetch

abstract Keithley2400 <: GpibInstrument

type Keithley2400Vb <: Keithley2400 # source voltage, measure current
	vi::PyObject 	# this is the GpibInstrument object!
	range::Float64 	# output range
	cmpl::Float64 	# compliance current
end

# constructor takes VISA resource manager and resource name. Other parameters are named not positional
function Keithley24000Vb(rm::PyObject, name::String; range = -1, cmpl = -1)
	vi = rm.get_instrument(name)
	vi[:write]("SOUR:FUNC VOLT")
	vi[:write]("SENS:FUNC CURR")
	vi[:write]("SENS:CURR:RANGE AUTO")
	if range < 0
		range = vi[:ask]("SOUR:VOLT:RANGE?")
	else
		if range > 210
			warn("Keithley 2400 $name range cannot be above 210V. Was given $range V. Setting it to max 210V.")
			range = 210
		end
		vi[:write]("SOUR:VOLT $range")
	end
	if cmpl < 0
		cmpl = vi[:ask]("SENS:CURR:PROT?")
	else
		max_cmpl = range > 20 ? 0.105 : 1.05
		if cmpl > max_cmpl
			warn("Keithley 2400 $name compliance cannot be above 105uA. Was given $cmpl A. Setting it to maximum for this range.")
			cmpl = max_cmpl
		end
		vi[:write]("SENS:CURR:PROT $cmpl")
	end
end

type Keithley2400Ib <: Keithley2400 # source current, measure voltage
	vi::PyObject 	# this is the GpibInstrument object!
	range::Float64
	cmpl::Float64
end

type Keithley24004W <: Keithley2400 # 4-wire ohms
	vi::PyObject 	# this is the GpibInstrument object!
	range::Float64
	cmpl::Float64
end

type Keithley2400Vsrc <: Output
	instr::Keithley2400Vb
	label::Label
	val::Float64
	step::Float64
	delay::Float64
end

function source(ch::Keithley2400Vsrc, val::Real)
	ch.val = val
	write(ch.instr, "SOUR:VOLT $val")
end

type Keithley2400Imeas <: BufferedInput
	instr::Keithley2400Vb
	label::Label
	val::Float64
end

function measure(ch::Keithley2400Imeas)
	ch.val = ask(ch.instr, "READ?")
end
trigger(ch::Keithley2400Imeas) = write(ch.instr, "INIT")
function fetch(ch::Keithley2400Imeas)
	ch.val = ask(ch.instr, "FETC?")
end
