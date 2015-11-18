using Measure
using Base.Test

Pkg.clone("https://github.com/menyoung/VISA.jl")
Pkg.clone("https://github.com/menyoung/Plotly.jl")
Pkg.build("VISA")
Pkg.build("Plotly")

# write your own tests here
@test 1 == 1
