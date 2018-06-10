import PAPI

info("PAPI Inner Product Test")
info("Using flops")

@printf("%12s %12s %12s %12s %12s %12s\n", "n", "ops", "2n", "difference", "% error", "mflops")

for n = 500:500:5000
    a = rand(1,n)
    x = rand(n, 1)

    ops, mflops = @PAPI.flops begin
        c = a * x
    end

    @printf("%12d %12d %12d %12d %12.2f %12.2f\n",
            n, ops, 2*n, ops-2n, (1.0 - (2n / ops))*100, mflops)
end
