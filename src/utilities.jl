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

#=
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
=#

"""
    sinusoid(A, f, φ, t) → Real

A function to generate a real sinusoid with its standard parameters:
- A: amplitude, dimensionless. 
- f: frequency in Hz. 
- φ: phase, in radians.
- t: time in seconds. 
Note that the sinusoid is generated with a cosine function.
"""
function sinusoid(A::Real, f::Real, φ::Real, t::Real)
    return A*cos(2π*f*t + φ)
end

"""
    ==(x::Union{T,Nothing}, y::Union{T,Nothing}) → Bool

A primitive to check for approximation in Union of some.
```julia
using Test
x::Union{Float64,Nothing} = nothing
y::Union{Float64,Nothing} = nothing
@test x == y
x::Union{Float64,Nothing} = 1e3
y::Union{Float64,Nothing} = 1e3
@test x == y
```
"""
function ==(x::Union{T,Nothing}, y::Union{T,Nothing}) where T
    isnothing(x) && isnothing(y) || x ≈ y
end

