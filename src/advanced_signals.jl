import Base: real,imag, zero, length
#using DSP
import DSP:conv#using Convolution, so add this to the Project.

"""
    real(x::Signal) → Signal

A function to obtain the real part of a signal.
"""
function real(x::Signal)::Signal
    @assert issignal(x)
    return(0.5(x + conj(x)))
end

"""
    imag(x::Signal) → Signal

A function to obtain the imaginary part of a signal.
"""
function real(x::Signal)::Signal
    @assert issignal(x)
    return(0.5(x - conj(x)))
end


"""
    zero(Signal) → Signal 

The additive zero of signals. It is also the convolutive zero.
"""
zero(Signal) = DataFrame(Time=[], Value=[])

"""
    lengty(x::Signal)::Integer

A primitive to observe the lenth of a signal
"""
function length(x::Signal)
    @assert issignal(x)
    return(length(x.Time))
end

"""
      convolve(x::Signal, y::Signal)::Signal

A primitive to convolve two signals.
Example:
```julia
x = δ(2)
y = δ(5)
@assert convolve(x,y) == δ(7)
```
""" 
function convolve(x::Signal, y::Signal)::Signal
      @assert issignal(x) && issignal(y)
      lx = length(x); ly = length(y)
      if (lx == 0 || ly == 0)
            return zero(Signal)
      else
            #lastTime = x.Time[end]
            n = (y.Time[1] + x.Time[1]) .+ collect(0:lx + ly - 2)
            return(
                  Signal(n, 
                   conv(x.Value, y.Value; algorithm=:direct)
                  )
            )#will fail most properties
      end
end

"""
Another implementation, using matrix multiplication, unexported.
"""
function convolve2(x::Signal, y::Signal)::Signal
      @assert issignal(x) && issignal(y)
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
            return( Signal(n, signals * y.Value) )
      end
end

