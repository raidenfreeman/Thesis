using PAPI
using FactCheck

const JULIAEXE = joinpath(JULIA_HOME, Base.julia_exename())

facts("PAPI library") do
    context("initialized") do
        @fact PAPI.is_initialized() => true
    end
end

facts("PAPI counters") do
    @fact PAPI.num_counters() > 0 => true
end

facts("PAPI components") do
    @fact PAPI.num_components() > 0 => true
end

facts("PAPI examples") do
    exampledir = joinpath(dirname(@__FILE__), "../examples")
    for ex in readdir(exampledir)
        testfile = joinpath(exampledir, ex)
        @fact success(`$JULIAEXE $testfile`) => true
    end
end

println("This file is $(@__FILE__)")
