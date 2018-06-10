import PAPI

const N = 2_000

@show LinAlg.peakflops(N)

function peakflops(n=2000)
    a = ones(Float64, 100,100)
    t = @elapsed a2 = a*a
    a = ones(Float64, n, n)
    res = @PAPI.flops a2 = a*a
    @assert a2[1,1] == n
    return res
end

flpops, mflops, rtime, ptime = peakflops(N)
println("flpops: $flpops, mflops: $mflops, rtime (s): $rtime, ptime (s): $ptime")
println("peakflops: $(2*Float64(N)^3 / rtime)")
