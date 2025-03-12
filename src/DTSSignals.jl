"""
    DTSSignals (version 0.0.2) --- An in-house module for signals processing in DTS.

    Author: FVA, all rights reserved 

"""
module DTSSignals

using Reexport
#@reexport using DataFrames, CairoMakie

export Signal, 
    *, #dot product of signals, scalar product with a signal (inline)
    +, # addition of signals (inline)
    conj, #signal conjugate
    shift, # a function to shift a signal. 
    δ, # A primitive to generate a delta
    trim, # the function to trim values and time domains. 
    visualize!, #a function to visualize signals 
    issignal, #A predicate to check if something is a signal.
#export 
    real, 
    imag, 
    zero, 
    length, 
    convolve

include("proto_signals.jl")
include("advanced_signals.jl")

end# Module Signals
