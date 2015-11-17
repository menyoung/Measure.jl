### Lock-In measurement MathInput types, etc.
# RCB: current bias, resistance
# GCB: current bias, conductance
# GVB: current bias, conductance

RCB(input::SR830Input, output::SR830Output, biasR::Real, label::(String,String) = ("Resistance (I bias)","Ohm")) = MathInput(()->val(input)*biasR/val(output), label)
GCB(input::SR830Input, output::SR830Output, biasR::Real, label::(String,String) = ("Conductance (I bias)","S")) = MathInput(()->val(output)/biasR/val(input), label)
GVB(input::SR830Input, output::SR830Output, sensI::Real, div::Real, label::(String,String)
	= ("Conductance (V bias)","S")) = MathInput(()->val(input)*sensI/div/val(output), label)