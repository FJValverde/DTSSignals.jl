using Test, DTSSignals

# Run test suite
println("Starting tests")
ti = time()

@testset "DTSSignals test" begin
    @test 1 == 1
end

ti = time() - ti
println("\nTest took total time of:")
println(round(ti/60, digits = 3), " minutes")

