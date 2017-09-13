### Agilent 34401A concrete types and methods

export Agilent34401a, Agilent34401aVDC, measure, trigget, fetch

mutable struct Agilent34401a <: GpibInstrument
	vi::ViSession 	# this is the GpibInstrument object!
	filter::Int 	# filter speed
	range::Float64 	# 0 for autorange
	imp::Bool 		# input impedance is 10M (0) or high (1)
	tc::Int 		# integration time in PLCs
	name::AbstractString
end

mutable struct Agilent34401aVDC <: BufferedInput
	instr::Agilent34401a
	label::Label
	value::Float64
end

function measure(s::Agilent34401aVDC)
	s.value = ask(s.instr, "MEAS:VOLT:DC?")
end
trigger(s::Agilent34401aVDC) = write(s.instr, "INIT")
function fetch(s::Agilent34401aVDC)
	s.value = ask(s.instr, "FETC?")
end
