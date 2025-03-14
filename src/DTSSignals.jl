"""
    DTSSignals (version 0.0.2) --- An in-house module for signals processing in DTS.

    Author: FVA, all rights reserved 

"""
module DTSSignals

#using Reexport
#@reexport using DataFrames, CairoMakie

import Base: *, +, conj, (==), real, imag, abs, angle, length

export
    ## Main type and operations for signals.
    Signal,#A type and constructor for signals.
    *, #dot product of signals, scalar product with a signal (inline)
    +, # addition of signals (inline)
    ∘, # \circ, hadamard (entrywise) product of signals

    conj, #signal conjugate
    shift, # a function to shift a signal. 
    conv, ⊛, #\circledast convolution of signals 
    # Primitive signals
    zero, #A zero signal
    δ, # A primitive to generate a delta (unit for convolution)
    # Other observers for signals
    ==, 
    real,#A function to extract the real part of a signal 
    imag,#A function to extract the imaginary part of a signal
    abs,#A function to extract the absolute value of a signal
    angle,#A function to extract the angle of a signal
    length, # The length of a signal
    visualize!, #a function to visualize signals. 
    isreal, #A predicate to check if a signal is real
    sample,
    # Utilities for signals
    sinusoid, # A primitive to generate a sinusoid in continuous time. 
    trim # A function to trim zeros out of pairs of time indices and value sequences 
 
include("utilities.jl")
include("proto_signals.jl")
include("advanced_signals.jl")

end# Module Signals
