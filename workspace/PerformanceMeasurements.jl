# @printf("REMEMBER TO RUN\n\nsudo sysctl -w kernel.perf_event_paranoid=0\n\n");

include("BFBCG.jl")

# BFBCGmodule.TestRuns()

using MatrixDepot

# MatrixDepot.update()

# matrixdepot("SNAP/web-Google", :get)

include("../PAPI.jl/src/PAPI.jl");

#small
# matrixNames = ["HB/bcsstk01"]#,"HB/bcsstk03","Pajek/Journals","HB/bcsstk02","JGD_Trefethen/Trefethen_20b"];
#medium
# matrixNames = ["TKK/smt"];
#large
matrixNames = ["ND/nd24k"]; #"TKK/smt","Norris/fv3","ND/nd3k",


# import PAPI

# const THRESHOLD = 10000
#
# function computation_mult()
#     tmp = 1.0
#     for i=1:THRESHOLD
#         tmp *= i
#     end
#     return tmp
# end
#
# function computation_add()
#     tmp = 0
#     for i=1:THRESHOLD
#         tmp += 1
#     end
#     return tmp
# end


function main(matrixName::String)
    run(`ntfy send "$matrixName  started :rocket:"`)

    inputMatrix = matrixdepot(matrixName, :r)
    matrixSize = size(inputMatrix)[1]

    solution = zeros(matrixSize,2)
    rng = MersenneTwister(1231) # seed random number generator
    for i = 1 : matrixSize
        if(randn(rng)>0)
            solution[i,1] = randn(rng, Float64);
        else
            solution[i,2] = randn(rng, Float64);
        end
    end

    R = inputMatrix*solution

    M = eye(matrixSize)

    guess = ones(matrixSize,2) #rand(6,2)

    tol = 10^(-7.0);

    function calculation()
        BFBCGmodule.BFBCG(inputMatrix,guess,M,tol,9,R)
    end

    function measurement()

        # Precompile functions so that we are also not
        # measuring compilation overhead
        # precompile(computation_add, ())
        # precompile(computation_mult,())

        precompile(calculation,())

        info("There are $(PAPI.num_counters()) counters on this system")

        # Initialize the PAPI library and start counting
        # the events named in the events array.
        # This function implicitly stops and initializes
        # any counters running as a result of a previous call
        # to PAPI.start_counters()

        @elapsed calculation() #warmup / compilation of macro and function

        values = []

        for i = 1:10
            cs = PAPI.EventSet([PAPI.FP_INS])
            PAPI.num_counters()
            # info("Counters started")
            PAPI.start_counters(cs)

        # retval = computation_add()
        # sleep(8)

            calculation()
            push!(values, PAPI.read_counters!(cs))
            PAPI.stop_counters(cs)
        end
        # @printf("%d",retval);
        # Base.showarray(STDOUT,values,false)

        firstCounterValues = map(x->x[1],values);

        @printf("The total FP instructions executed for the calculation are %lld \n", mean(firstCounterValues));
        # @printf("The total cycles used are %lld \n", values[2] );

        matrixFileName = replace(matrixName,"/"=>"__")
        writedlm("measurements_s/INS__$(matrixFileName).txt",firstCounterValues,",")
        writedlm("measurements_s/MEAN_INS__$(matrixFileName).txt",mean(firstCounterValues),",")

        timevalues = []
        # Time 10 runs
        for i = 1:10
            push!(timevalues,@elapsed calculation())
        end

        writedlm("measurements_s/TIMES__$(matrixFileName).txt",timevalues,",")
        writedlm("measurements_s/MEAN_TIMES__$(matrixFileName).txt",mean(timevalues),",")

        writedlm("measurements_s/MEAN_FLOPS__$(matrixFileName).txt",mean(firstCounterValues)/mean(timevalues),",")
    end

    measurement()
    run(`ntfy send "$matrixName  finished :checkered_flag:"`)
end

function main_parallel(matrixName::String)

    inputMatrix = matrixdepot(matrixName, :r)
    matrixSize = size(inputMatrix)[1]

    totalThreads = Threads.nthreads()

    function generateSolution(matrixSize)
        solution = zeros(matrixSize,2)
        rng = MersenneTwister(1231)
        for i = 1 : matrixSize
            solution[i,1] = randn(rng, Float64);
        end
        for i = 1 : matrixSize
            solution[i,2] = randn(rng, Float64);
        end
        return solution
    end

    Rs = []
    for i = 1 : totalThreads
        push!(Rs, inputMatrix*generateSolution(matrixSize))
    end

    M = eye(matrixSize)

    guess = ones(matrixSize,2) #rand(6,2)

    tol = 10^(-7.0);

    function calculation()
        Threads.@threads for i = 1:totalThreads
            BFBCGmodule.BFBCG(inputMatrix,guess,M,tol,9,Rs[i])
        end
    end

    function measurement()

        # Precompile functions so that we are also not
        # measuring compilation overhead
        # precompile(computation_add, ())
        # precompile(computation_mult,())

        precompile(calculation,())

        info("There are $(PAPI.num_counters()) counters on this system")

        # Initialize the PAPI library and start counting
        # the events named in the events array.
        # This function implicitly stops and initializes
        # any counters running as a result of a previous call
        # to PAPI.start_counters()

        @elapsed calculation() #warmup / compilation of macro and function

        values = []

        info("starting perf counters")

        for i = 1:10
            cs = PAPI.EventSet([PAPI.FP_INS])
            PAPI.num_counters()
            # info("Counters started")
            PAPI.start_counters(cs)

        # retval = computation_add()
        # sleep(8)

            calculation()
            push!(values, PAPI.read_counters!(cs))
            PAPI.stop_counters(cs)
        end
        # @printf("%d",retval);
        # Base.showarray(STDOUT,values,false)

        firstCounterValues = map(x->x[1],values);

        @printf("The total FP instructions executed for the calculation are %lld \n", mean(firstCounterValues));
        # @printf("The total cycles used are %lld \n", values[2] );

        matrixFileName = replace(matrixName,"/"=>"__")
        writedlm("measurements_p/INS__$(matrixFileName).txt",firstCounterValues,",")
        writedlm("measurements_p/MEAN_INS__$(matrixFileName).txt",mean(firstCounterValues),",")

        timevalues = []
        info("starting timing")
        # Time 10 runs
        for i = 1:10
            push!(timevalues,@elapsed calculation())
        end

        writedlm("measurements_p/TIMES__$(matrixFileName).txt",timevalues,",")
        writedlm("measurements_p/MEAN_TIMES__$(matrixFileName).txt",mean(timevalues),",")

        writedlm("measurements_p/MEAN_FLOPS__$(matrixFileName).txt",mean(firstCounterValues)/mean(timevalues),",")
    end

    measurement()

end


for i = 1 : size(matrixNames)[1]
    try
        matrixdepot(matrixNames[i], :get)
        @printf("\n\n================\n\nDownloaded %s\n\n================\n\n", matrixNames[i]);
    end
    # main_parallel(matrixNames[i])
    main(matrixNames[i])
end
