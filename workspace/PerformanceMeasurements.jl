@printf("REMEMBER TO RUN\n\nsudo sysctl -w kernel.perf_event_paranoid=0\n\n");

include("BFBCG.jl")

# BFBCGmodule.TestRuns()

using MatrixDepot

# MatrixDepot.update()

# matrixdepot("SNAP/web-Google", :get)

inputMatrix = matrixdepot("HB/bcsstk03", :r)

matrixSize = size(inputMatrix)[1]


# import PAPI

include("../PAPI.jl/src/PAPI.jl");

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

solution = zeros(matrixSize,2)
rng = MersenneTwister(1231)
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

function main()

    # Precompile functions so that we are also not
    # measuring compilation overhead
    # precompile(computation_add, ())
    # precompile(computation_mult,())

    precompile(calculation,())

    cs = PAPI.EventSet([PAPI.TOT_INS])

    info("There are $(PAPI.num_counters()) counters on this system")

    # Initialize the PAPI library and start counting
    # the events named in the events array.
    # This function implicitly stops and initializes
    # any counters running as a result of a previous call
    # to PAPI.start_counters()

    calculation()

    values = []

    for i = 1:10
        cs = PAPI.EventSet([PAPI.TOT_INS])
        PAPI.num_counters()
        info("Counters started")
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

    @printf("The total instructions executed for the calculation are %lld \n", mean(firstCounterValues));
    # @printf("The total cycles used are %lld \n", values[2] );
end

main()
