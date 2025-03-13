using Test, DTSSignals

# Run test suite
println("Starting tests")
ti = time()

#=
@testset "DTSSignals option{T}" begin
    x::Option{Float64} = nothing
    y::Option{Float64} = nothing
    @test x == y
    x2::Option{Float64} = 1e3
    y2::Option{Float64} = 1e3
    @test x2 == y2
    @test x2 != y && x != y2
    @test Some(1.0) != Some(1.0 + 1e-10)
    @test Some(1.0) == Some(0.9999999999999999)
end
=#

@testset "DTSSignals creation test" begin
    n = collect(-3:3)
    v = zeros(ComplexF64,length(n))#better than the next
    #v = Vector{Complex{Float64}}zeros(length(n)); 
    v[4] = 1.0#This is the value of a delta at n=-2, δ(n + 2)
    x = Signal(n,v)#the visualization is in term of the DataFrame by default, unless you define a show!.
    y = Signal(n,v; doTrim=false)
    @test x != y#They are not the same 
end

@testset "DTSSignals special signals creation" begin
    @test shift(δ(0), 4) == δ(4)
    @test shift(δ(0), -4) == δ(-4)
    @test shift(δ(0), 0) == δ(0)    
end


@testset "DTSSignals utilities" begin
    @test scale(Complex(2.0),δ(0)) == δ(0) + δ(0)
    @test (2.0+0im)*δ(0) == δ(0) + δ(0)#Not yet defined.
    @test 2δ(0) == δ(0) + δ(0) == 2.0δ(0) == (2.0+0.0im) * δ(0) 
    @test isreal(Signal([1,2,3],[1.0,2.0,3.0])) && isreal(δ(0))
    @test !isreal(Signal([1,2,3],[1.0,2.0,3.0im]))
    for x in [δ(0), δ(1), δ(-1)]
        
    end
end

@testset "DTSSignals conjugation" begin
    s = δ(0)
    r = conj(s)
    @test !isreal(s) || s == r#only true for real signals.
    @test s == conj(r)## Always true since conj is an involution.
    @test (π/4)s != conj((π/4)s)        
end

@testset "Creating signals by sampling" begin
    for f in [t -> sinusoid(1.0, 1.0, 0.0, t), 
              t -> sinusoid(1.0, 1e3, π/2, t)]
        x = sample(f, 1.0, 10)
        @test length(x) == 10
        @test x.n  == collect(0:9)
        @test x.v ≈ f.(collect(0:9))
    end
end

ti = time() - ti
println("\nTest took total time of:")
println(round(ti/60, digits = 3), " minutes")

