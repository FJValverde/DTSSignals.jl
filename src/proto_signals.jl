# Author: FVA, all rights reserved
# version 0.0.1

# This file uses the representation for signals as DataFrames with two fields, Time and Value, e.g. see the create constructor below. 
# 
# TODO: Define an eval for x(n) to obtain a value. Define concrete syntax for it. 
using DataFrames, CairoMakie
import Base: *, +, conj

"""
    Signal = DataFrame

A type to encode signals, e.g. two co-indexed sequences of time indices and values. 
"""
const Signal = DataFrame()
# This is not a good implementation to make public, since there is no way to check
# for the semantics of the type. 
# Creating signals should only be done by means of the constructors belows. 

"""
    trim(t, v) → (trimmedt,trimmedv)

A function to trim away the zeros of a value vector 
on the left and the right, and co-indexed time scale.
This allows some sparsity in the representation of signals with
a finite number of non-zero values. 

Use example: 
```julia
n = collect(-3:3);
v = Vector{Float64}zeros(length(t)); 
v[2] = 1.0;#This is the value of a delta at n=-2, δ(n + 2)
(trimmedt, trimmedv) = trim(n,v)
```
"""
function trim(t::Vector{}, v::Vector{})#precondition both have the same length
    @assert length(t) == length(v)#fail otherwise.
    s = findfirst(!isequal(0.0), v)#note that 0.0 == 0.0 + 0.0im, so this works for complex numbers.
    e = findlast(!isequal(0.0), v)
    # If we haven't found the left and right:
    # - create a zero vector, since the orignal values were empty.
    # Otherwise.
    # - restrict the times and values to the same ranges. 
    return (isnothing(s) ? (Vector{Integer}(),zeros(0)) : (t[s:e], v[s:e]))
end

"""
    issignal(x) → Bool

A predicate to detect a signal
```julia
z = DataFrame(;Time=[], Value=[])#The zero signal.
@assert issignal(z)
@assert !issignal(DataFrame(;Time=[]))
```
"""
function issignal(x::Signal)::Bool#we demand that it be a DataFrame by the signature
    any("Time" .== names(x)) && # Check sequentially so that before we access Time and Value we know they are there. 
        any("Value" .== names(x)) &&
        length(x.Time) == length(x.Value)
end

"""
    Signal(n,v; doTrim=true) → Signal
    
An external constructor for signals with time index n and values v.
We can try to create a sparser representation with doTrim=true
Use example: 
```julia
n = collect(-3:3);
v = ComplexF64.(zeros(length(n)))
v = zeros(ComplexF64,length(n))#better than the next
#v = Vector{Complex{Float64}}zeros(length(n)); 
v[4] = 1.0#This is the value of a delta at n=-2, δ(n + 2)
x = Signal(n,v)#the visualization is in term of the DataFrame by default, unless you define a show!.
y = Signal(n,v; doTrim=false)
@assert x != y#They are not the same signal, because of changes in representation. 
```
"""
function Signal(n::Vector{Int64},  v::Vector{ComplexF64}; doTrim=true)::Signal
#function signal(n::Vector{Int64},  v::Vector{Complex{Float64}}; doTrim=true)::Signal
    @assert length(n) == length(v)
    if doTrim 
        n,v = trim(n,v)
    end
    return Signal(;Time = n, Value = v)
end

"""
    visualise!(x::signal)

A primitive to visualise a DT signal as a stem plot:
- The default is to visualize the real component
- If "full" visualization is requested the default is polar
- For real vs. imaginary part use full=true, polar=false
```julia
n = collect(-3:3)
v = Complex.([0.0, 0.0, 1.0, 1.0, 1.0, 0.0, 0.0])
#v = map(Complex, [0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0])
x = signal(n,v; doTrim = false)#The N=3 pulse
f = Figure()
#Axis(f[1,1])
visualise!(x)
Axis(f[end+1,1])
visualise!(x;full=true)
Axis(f[end+1,1])
visualise!(x;full=true,polar=false)
f
```
"""
function visualise!(x::Signal; full=false, polar=true)
    @assert issignal(x)
    if !full
        Axis(f[end,end]; ylabel="Real part")
        stem!(x.Time,real(x.Value))
    elseif polar
        Axis(f[end,end]; ylabel="|x|")
        stem!(x.Time,abs.(x.Value))
        Axis(f[end+1,end]; ylabel="θ(x)")
        stem!(x.Time,angle.(x.Value))
    else #full, !polar
        Axis(f[end,end]; ylabel="Re|x")
        stem!(x.Time,real.(x.Value))
        Axis(f[end+1,end]; ylabel="Im|x")
        stem!(x.Time,imag.(x.Value))
    end
end

"""
    δ(τ::Integer) → Signal

A function to generate a delta signal at a shift of τ.

Example:
```julia
δ(5)
```
"""
function δ(τ::Integer)::Signal
    return Signal([τ], [1.0+0im])
end

import Base:conj
"""
    conj(x::Signal) → Signal

A function to generate the conjugate of a signal.
"""
function conj(x::Signal)::Signal
    @assert issignal(x)
    return(Signal(x.Time, conj.(x.Value)))
end 

# TO use the syntax of common operators they have to be imported from Package Base
import Base:+
"""
    add(x::Signal, y::Signal) → Signal
    x + y -> signal

A function to add two signals.

Example: 
```julia
x = δ(0) 
y = δ(5)
w = x + y
x = add(δ(4), w)
@assert w == δ(0) + δ(5)
```
"""
function +(x::Signal, y::Signal)::Signal
    @assert issignal(x) && issignal(y)
    xdict = Dict(zip(x.Time, x.Value))
    ydict = Dict(zip(y.Time, y.Value))
    merged = mergewith(+, xdict, ydict)
    return(Signal(collect(keys(merged)), collect(values(merged))))
end
#= function +(x::Signal, y::Signal)
    @assert issignal(x) && issignal(y)
    allTimes = union(x.Time, y.Time)
    minn, maxn = extrema(allTimes)
    #maxn = maximum(allTimes)#We have a new time domain 
    #minn = minimum(allTimes)
    n = collect(minn:maxn)
    indices = collect(1:length(n))#coindexed
    v = zeros(ComplexF64, length(n))
    v[x.Time] .+= x.Value
    v[y.Time] .+= y.Value
    return Signal(n,v)
end =#
# Maybe the next does not need to be reexported.
add(x::Signal, y::Signal) = x + y
#= for (n,v) in zip(x.Time, x.Value)
    print(n,"  ", v)
end
 =#

"""
    shift(x::signal, τ::Integer ) -> signal

A function to implement a time displacement (positive delay).

Example:
```julia
@assert shift(δ(0), 4) == δ(4)
```
"""
function shift(x::Signal, τ::Integer)
    @assert issignal(x)
    return Signal(x.Time .+ τ, x.Value)
end

import Base:*
"""
    scale( α::Complex,x::signal) -> Signal α

A function to scale a signal x by a scalar α. Scalars can be ComplexF64, Float64 or even 
Note that the scalar outer product can be abbreviated to nothing so we can elide it. 
```julia
@assert scale(δ(0), Complex(2.0)) == add(δ(0), δ(0))
@assert (2.0+0im)*δ(0) == δ(0) + δ(0)#Not yet defined.
@assert 2δ(0) == δ(0) + δ(0) == 2.0δ(0) == (2.0+0.0im) * δ(0)
```
"""
function *(α::Complex, x::Signal)
    @assert issignal(x)
    return Signal(x.Time, x.Value .* α)
end
# This is just a promotion of scalar float64 to ComplexF64, The same can be done on integers.
*(α::Real, x::Signal) = ComplexF64(α) * x
*(α::Integer, x::Signal) = ComplexF64(α) * x
#The following looks a little bit coarse after what Julia can do, but hey!
scale(α::ComplexF64, x::Signal) = α * x

"""
    *(x::Signal, y::Signal) → Complex

Dot-product of two signal. In the spirit of 
extending the product.
```julia
x = add(δ(0), add(δ(4), δ(5)))
y = δ(0) + 2δ(4) 
@assert x * y == 4.0
```
"""
function *(x::Signal, y::Signal)::Complex
    @assert issignal(x) && issignal(y)
    xdict = Dict(zip(x.Time, conj.(x.Value)))#Just do the conjugation here. 
    ydict = Dict(zip(y.Time, y.Value))
    acc(k,a) = (get(xdict,k,0.0+0.0im) * get(ydict,k,0.0+0.0im)) + a
    #common = intersect(x.Time, y.Time)#Only worry about possibly non-null values
    return(foldl(acc, intersect(x.Time, y.Time); init=0+0im))
    #return reduce(+, conj(x.Value[common]) .* y.Value[common]; init=0+0im)
end

#= 
function *(x::Signal, y::Signal)::Complex
    @assert issignal(x) && issignal(y)
    xdict = 
    common = intersect(x.Time, y.Time)#Only worry about possibly non-null values
    return reduce(+, conj(x.Value[common]) .* y.Value[common]; init=0+0im)
end
 =#