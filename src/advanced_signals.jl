import Base: zero, length
#using DSP
import DSP:conv#using Convolution, so add this to the Project.

"""
    real(x::Signal) → Signal

A function to obtain the real part of a signal.
"""
function real(x::Signal)::Signal
    #return(0.5(x + conj(x)))
    return Signal(x.n, real(x.v), fs=x.fs)
end

"""
    imag(x::Signal) → Signal

A function to obtain the imaginary part of a signal.
"""
function imag(x::Signal)::Signal
    #return(0.5(x - conj(x)))
    return Signal(x.n, imag(x.v), fs=x.fs)
end


"""
    zero(Signal) → Signal 

The additive zero of signals. It is also the convolutive zero.
"""
zero(Signal) = Signal([],[])

"""
    length(x::Signal) → Integer

A primitive to observe the lenth of a signal
"""
length(x::Signal) = length(x.n)

"""
      convolve(x::Signal, y::Signal)::Signal

A primitive to convolve two signals.
Example:
```julia
x = δ(2)
y = δ(5)
@assert conv(x,y) == δ(7)
```
""" 
function conv(x::Signal, y::Signal)::Signal
      x.fs == y.fs || throw(ArgumentError("The signals must have the same sampling frequency."))
      lx = length(x); ly = length(y)
      if (lx == 0 || ly == 0)
            return zero(Signal)
      else
            n = (y.n[1] + x.n[1]) .+ collect(0:lx + ly - 2)
            return(
                  Signal(n,conv(x.v, y.v; algorithm=:direct), fs=x.fs)
                  )#will fail most properties
      end
end

"""
Another implementation, using matrix multiplication, unexported.
"""
function convolve2(x::Signal, y::Signal)::Signal
      x.fs == y.fs || throw(ArgumentError("The signals must have the same sampling frequency."))
     lx = length(x); ly = length(y)
      if (lx == 0 || ly == 0)
            return zero(Signal)
      else
            n = (y.Time[1] + x.Time[1]) .+ collect(0:lx + ly - 2)
            ln = length(n)
            signals = zeros(ComplexF64, ln, ly)
            for i in 1:ly
                  signals[(i-1) .+ (1:lx),i] = x.Value
            end
            return Signal(n, signals * y.v,fs=x.fs) 
      end
end

