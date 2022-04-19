include("../src/Cat.jl")

sum = ((x,y) -> x+y) : (Int → Int → Int)
sum(1,2)

sum = (x->Either(Float64,x)) ↑ sum
sum(1,2)
sum(1,2.)

sum = Maybe ↑ sum : (x,y) -> x===nothing || y===nothing ? nothing : x+y
sum(1,2)
sum(1,2.)
sum(1,nothing)

mul = ((x,y,z,k) -> x*y*z*k) : (Float64 → Int → Float64 → Float64 → Float64)
mul(1.,2,3.,4.)

mul = Maybe ↑ mul : (x,y,z,k) -> x===nothing || y===nothing || z===nothing || k === nothing ? nothing : x*y*z*k
mul(1.,2,3.,4.)
mul(1.,nothing,3.,4.)
