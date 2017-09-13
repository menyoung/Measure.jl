### Lakeshore 331 Temperature Controller concrete types and methods

mutable struct LS331 <: GpibInstrument
	vi::ViSession 	# this is the GpibInstrument object!
	name::String
end

mutable struct LS331Temp{T} <: Input
	instr::LS331
	value::Float64
	label::Label
end

function measure(s::LS331Temp{:A})
	s.value = ask(s.instr, "KRDG? A")
end

function measure(s::LS331Temp{:B})
	s.value = ask(s.instr, "KRDG? B")
end
