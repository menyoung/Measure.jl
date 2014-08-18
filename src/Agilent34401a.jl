### Agilent 34401A concrete types and methods

export Agilent34401a, Agilent34401aVDC, measure, trigget, fetch

type Agilent34401a <: GpibInstrument
	vi::PyObject 	# this is the GpibInstrument object!
	filter::Int 	# filter speed
	range::Float64 	# 0 for autorange
	imp::Bool 		# input impedance is 10M (0) or high (1)
	tc::Int32 		# integration time in PLCs
end

type Agilent34401aVDC <: BufferedInput
	instr::Agilent34401a
	label::Label
	val::Float64
end

function measure(ch::Agilent34401aVDC) 
	ch.val = ask(ch.instr, "MEAS:VOLT:DC?")
end
trigger(ch::Agilent34401aVDC) = write(ch.instr, "INIT")
function fetch(ch::Agilent34401aVDC)
	ch.val = ask(ch.instr, "FETC?")
end