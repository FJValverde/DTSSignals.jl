# Author: FVA, all rights reserved
# version 0.0.1

# This file uses the representation for signals as DataFrames with two fields, Time and Value, e.g. see the create constructor below. 
# 
# TODO: Define an eval for x(n) to obtain a value. Define concrete syntax for it. 
using CairoMakie
import Base: *, +, conj

"""
    struct Signal
        n::Vector{Int}
        v::Vector{Complex}#vector of values
        fs::Float64#sampling frequency
    end

A type to encode signals, e.g. two co-indexed sequences of integer time indices 
[n] and values [v]. Note that these two sequences must have the same length, and
this is enforced by the constructor.

If we want to ground the signal in some sampling process, we can add
a sampling frequency [fs]. If ommitted, we leave undefined, so *cave canem*.
"""
mutable struct Signal
    n::Vector{Int}
    v::Vector{Complex}#vector of values
    fs::Union{Float64, Nothing}#sampling frequency
    """
    Signal(n,v; doTrim=true) → Signal
    
    An external constructor for signals with time index n and values v.
    We can try to create a sparser representation with doTrim=true
    Use example: 
    ```julia
    n = collect(-3:3);
    v = zeros(ComplexF64,length(n))#better than the next
    #v = Vector{Complex{Float64}}zeros(length(n)); 
    v[4] = 1.0#This is the value of a delta at n=-2, δ(n + 2)
    x = Signal(n,v)#the visualization is in term of the DataFrame by default, unless you define a show!.
    y = Signal(n,v; doTrim=false)
    @assert x != y#They are not the same signal, because of changes in representation. 
    ```
    """
    function Signal(n,v;fs=nothing, doTrim=true) 
        length(n) == length(v) || throw(ArgumentError("n and v must have the same length")) 
        if doTrim 
            n,v = trim(n,v)
        end
        new(n,v,fs)
    end
end 

#=
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
function Signal(n::Vector{Int64},  v::Vector{ComplexF64}; fs, doTrim=true)::Signal
#function signal(n::Vector{Int64},  v::Vector{Complex{Float64}}; doTrim=true)::Signal
    @assert length(n) == length(v)
    if doTrim 
        n,v = trim(n,v)
    end
    return Signal(n,v;fs=fs)
end
=#

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
x = Signal(n,v; doTrim = false)#The N=3 pulse
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
    if !full
        Axis(f[end,end]; ylabel="Real part")
        stem!(x.n,real(x.v))
    elseif polar
        Axis(f[end,end]; ylabel="|x|")
        stem!(x.n,abs.(x.v))
        Axis(f[end+1,end]; ylabel="θ(x)")
        stem!(x.n,angle.(x.v))
    else #full, !polar
        Axis(f[end,end]; ylabel="Re|x")
        stem!(x.n,real.(x.v))
        Axis(f[end+1,end]; ylabel="Im|x")
        stem!(x.n,imag.(x.v))
    end
end

import Base:isreal
"""
    isreal(x::Signal) → Bool

A predicate to check if a signal is real.
```julia
using Test
@test isreal(Signal([1,2,3],[1.0,2.0,3.0])) && isreal(δ(0))
@test !isreal(Signal([1,2,3],[1.0,2.0,3.0im]))
```
"""
function isreal(x::Signal)
    return isreal(x.v)
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
```julia
s = δ(0)
r = conj(s)
using Test
@test !isreal(s.v) || x == r#only true for real signals.
@test s == conj(r)## Always true since conj is an involution.
@test (π/4)s != conj((π/4)s)
```
"""
function conj(x::Signal)::Signal
    return(Signal(x.n, conj.(x.v); fs=x.fs))
end 

import Base:(==),real,imag,abs,angle,length
"""
    ==(x::Signal, y::Signal) → Bool

An equality predicate for signals. We test for equality of all content.
"""
function ==(x::Signal, y::Signal)
    #FVA: maybe equality on the value content is too demanding, and
    # it were better to check for approximate equality.
    return x.n == y.n && x.v == y.v && x.fs == y.fs
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
using Test
@test w == δ(0) + δ(5)
```
"""
function +(x::Signal, y::Signal)::Signal
    x.fs == y.fs || throw(ArgumentError("Signals must have the same sampling frequency"))
    xdict = Dict(zip(x.n, x.v))
    ydict = Dict(zip(y.n, y.v))
    merged = mergewith(+, xdict, ydict)
    # We need to sort the keys to have a consistent time index. 
    n = collect(keys(merged))
    v = collect(values(merged))
    return(Signal(n,v; fs=x.fs))
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
     return Signal(x.n .+ τ, x.v; fs=x.fs)
end

import Base:*
"""
    scale(α::Complex,x::signal) -> Signal α

A function to scale a signal x by a scalar α. Scalars can be ComplexF64, Float64 or even 
Note that the scalar outer product can be abbreviated to nothing so we can elide it. 
```julia
using Test
@test scale(Complex(2.0),δ(0)) == δ(0) + δ(0)
@test (2.0+0im)*δ(0) == δ(0) + δ(0)#Not yet defined.
@test 2δ(0) == δ(0) + δ(0) == 2.0δ(0) == (2.0+0.0im) * δ(0)
```
"""
function *(α::Complex, x::Signal)::Signal
   return Signal(x.n, x.v .* α; fs=x.fs)
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
xs = δ(0) + δ(4) + δ(5)
ys = δ(0) + 2δ(4) 
@test x * y == 4.0
```
"""
function *(x::Signal, y::Signal)::Complex
    x.fs == y.fs || throw(ArgumentError("Signals must have the same sampling frequency"))
    xdict = Dict(zip(x.n, conj.(x.v)))#Just do the conjugation here. 
    ydict = Dict(zip(y.n, y.v))
    acc(k,a) = (get(xdict,k,0.0+0.0im) * get(ydict,k,0.0+0.0im)) + a
    #common = intersect(x.Time, y.Time)#Only worry about possibly non-null values
    return(foldl(acc, intersect(x.n, y.n); init=0+0im))
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