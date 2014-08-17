### Agilent 34401A concrete types and methods

export Agilent34401a

type Agilent34401a
	vi::PyObject 	# this is the GpibInstrument object!
	filter::Int 	# filter speed
	range::Float 	# 0 for autorange
	imp::Bool 		# input impedance is 10M (0) or high (1)
	tc::Int 		# integration time in PLCs
end

Agilent34401a <: GpibInstrument

type Agilent34401aVDC
	instr::Agilent34401a
	label::Label
	val::Float
end

Agilent34401aVDC <: BufferedInput

function measure(ch::Agilent34401aVDC) 
	ch.val = ask(ch.instr, "MEAS:VOLT:DC?")
end
trigger(ch::Agilent34401aVDC) = write(ch.instr, "INIT")
function fetch(ch::Agilent34401aVDC)
	ch.val = ask(ch.instr, "FETC?")
end