import PAPI

function slow_code()
    tmp = 1.1
    for i=1:200_000_000
        tmp = (tmp+100)/i
    end
    return tmp
end

function main()
    precompile(slow_code, ())

    flpops, mflops, real_time, proc_time  = @PAPI.flops slow_code()

    @printf("Real_time: %f Proc_time: %f Total flpops: %lld MFLOPS: %f\n",
             real_time, proc_time, flpops, mflops)
end

main()
