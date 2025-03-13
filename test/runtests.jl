using Test, DTSSignals

# Run test suite
println("Starting tests")
ti = time()

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
end

ti = time() - ti
println("\nTest took total time of:")
println(round(ti/60, digits = 3), " minutes")

