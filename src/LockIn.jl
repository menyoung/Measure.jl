### Lock-In measurement MathInput types, etc.
# RCB: current bias, resistance
# GCB: current bias, conductance
# GVB: current bias, conductance

RCB(input::SR830Input, output::SR830Output, biasR::Real, label::Label
	= Label("Resistance (I bias)","Ohm")) = MathInput(()->value(input)*biasR/value(output), label)
GCB(input::SR830Input, output::SR830Output, biasR::Real, label::Label
	= Label("Conductance (I bias)","S")) = MathInput(()->value(output)/biasR/value(input), label)
GVB(input::SR830Input, output::SR830Output, sensI::Real, div::Real, label::Label
	= Label("Conductance (V bias)","S")) = MathInput(()->value(input)*sensI/div/value(output), label)
