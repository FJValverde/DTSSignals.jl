using Reexport
@reexport module SampledSpectra
"""
    SampledSpectra --- A module for sampled spectra

This module provides a representation for the sampled spectrum of a signal.
The sampled spectrum is represented as a vector of complex numbers, where the
index of the vector corresponds to the frequency index and the value to the
complex amplitude of the signal at that frequency. The frequency sampling interval 
can also be provided. If missing it is set to one. 

The module provides a type `SampledSpectrum` to represent the sampled spectrum
and a function `visualise!` to visualise the spectrum as a stem plot.

The module also provides a function `length` to get the length of the spectrum.
"""

import Base: *, +, conj, (==), real, imag, abs, angle, length
import ..DTSSignals: Signal

export 
    SampledSpectrum, 
    length,
    visualise!,
    DFT, #A function to compute the DFT of a signal
    DFT_matrix_theory,# A function to compute the DFT matrix using the theory on factor frequency.
    DFT_matrix_fft#A function to compute the DFT matrix using FFTW

using CairoMakie
using LinearAlgebra, FFTW


"""
    SampledSpectrum(n::Vector{Int}, v::Vector{Complex}; Δω=1.0) -> SampledSpectrum

A representation for the sampled spectrum of a signal. 

# Arguments
- `n::Vector{Int}`: The frequency indices
- `v::Vector{Complex}`: The values of the spectrum
- `Δω::Float64`: The sampling frequency interval
"""
struct SampledSpectrum
    n::Vector{Int}
    v::Vector{Complex}#vector of values
    Δω::Float64#sampling frequency interval
    function SampledSpectrum(n,v; Δω=1.0) 
        length(n) == length(v) || throw(ArgumentError("n and v must have the same length")) 
        new(n,v,Δω)
    end
end

"""
    length(x::SampledSpectrum) -> Int

An observer for the length of a spectrum.
"""
length(x::SampledSpectrum) = length(x.v)


"""
    visualise!(x::SampledSpectrum) -> Nothing

A primitive to visualise a DT signal as a stem plot:
- The default is to visualize the real component
- If "full" visualization is requested the default is polar
- For real vs. imaginary part use full=true, polar=false
```julia
using CairoMakie
n = collect(-3:3)
v = Complex.([0.0, 0.0, 1.0, 1.0, 1.0, 0.0, 0.0])
#v = map(Complex, [0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0])
x = SampledSpectrum(n,v)#The N=3 pulse
f = Figure()
#Axis(f[1,1])
visualise!(x)
Axis(f[end+1,1])
visualise!(x;full=true)
Axis(f[end+1,1])
visualise!(x;full=true,polar=false)
```
"""
function visualise!(x::SampledSpectrum; full=false, polar=true)
    if !full
        Axis(f[end,end]; ylabel="Real part")
        stem!(x.n,real(x.v))
    elseif polar
        Axis(f[end,end]; ylabel="|X|")
        stem!(x.n,abs.(x.v))
        Axis(f[end+1,end]; ylabel="θ(X)")
        stem!(x.v,angle.(x.v))
    else #full, !polar
        Axis(f[end,end]; ylabel="Re|X")
        stem!(x.n,real.(x.v))
        Axis(f[end+1,end]; ylabel="Im|X")
        stem!(x.n,imag.(x.v))
    end
end

#A recipe based on FFTW from 
#https://discourse.julialang.org/t/discrete-fourier-transform-dft-matrix-and-inverse/119952/8
"""
    DFT_matrix_fft(N::Number) -> Matrix{Complex}

BUilding the DFT matrix using the FFTW library.
"""
DFT_matrix_fft(N) = stack(fft.(eachcol(I(N))))

"""
    DFT_matrix_theory(N::Number) -> Matrix{Complex}
BUilding the DFT matrix using the theory on factor frequency.
```julia
N = 4
m1 = DFT_matrix_theory(N)
m2 = DFT_matrix_fft(N)
@assert m1 ≈ m2
```
"""
function DFT_matrix_theory(N::Number)
   w_n = exp(-2*im*π/N)
   return([w_n^((k-1)*(n-1)) for k in 1:N, n in 1:N])
 end

"""
    DFT(x::signal) -> SampledSpectrum

A function to work out the DFT of a signal. 

# Arguments
- `x::Signal`: The signal whose DFT is to be computed.
- 
"""
function DFT(x::Signal)
    N = length(x)
    n = collect(0:N-1)
    v = [sum(x.*exp.(-im*2π*n*k/N)) for k in n]
    Δω = 2pi/(x.fs*N)#this is 2pi/T where T is the total time of the signal.
    SampledSpectrum(n,v, Δω=Δω)  
end

"""
    IDFT(x::SampledSpectrum) -> Signal

A function to work out the IDFT of a spectrum.
"""
function IDFT(x::SampledSpectrum)
    N = length(x)
    n = collect(0:N-1)
    v = [sum(x.*exp.(im*2π*n*k/N)) for k in n]
    Ts = 1/(x.Δω*N)# This is the sampling interval.
    Signal(n,v, fs=1/Ts) 
end

end#module SampledSpectra