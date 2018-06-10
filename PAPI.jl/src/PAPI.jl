module PAPI

@static if is_apple()
     error("PAPI.jl currently only works on Linux")
end

@static if is_windows()
    error("PAPI.jl currently only works on Linux")
end

include("events.jl")
include("retcodes.jl")

immutable PAPIError{R} <: Exception
    msg::String
end
PAPIError(R::RetCode) = PAPIError{R}(errmsg(R))

function __init__()
    # init the library and make sure that some counters are available
    if num_counters() <= 0
        error("PAPI init error: No counters are available on the current system")
    end
    atexit() do
        ccall((:PAPI_shutdown, :libpapi), Void, ())
    end
end

type EventSet
    counters::Vector{Event}
    vals::Vector{Clonglong}

    EventSet(c::Vector{Event}) = begin
        cs = new(c, zeros(Clonglong, length(c)))
        return cs
    end
end

# a nonexistent hardware event used as a placeholder
const PAPI_NULL = Cint(-1)

immutable PAPIEventSet
    val::Cint
    PAPIEventSet() = new(PAPI_NULL)
end

# TODO Low Level API
function exists(evt::Event)
    evtset = Ref(PAPIEventSet())
    ret = RetCode(ccall((:PAPI_create_eventset, :libpapi), Cint,
                        (Ref{PAPIEventSet},), evtset))
    if ret != OK
        throw(PAPIError(ret))
    end
    ret = RetCode(ccall((:PAPI_query_event, :libpapi), Cint,
                        (Cuint,), evt))
    return ret == OK
end

function start(evts::Event...)
    nevts = length(evts)
    if nevts == 0
        throw(ArgumentError("one or more PAPI.Events required"))
    end
    ncounters = num_counters()
    if nevts > ncounters
        throw(ArgumentError("number of PAPI.Events must be ≤ PAPI.num_counters(), got $nevts"))
    end
    evtcodes = Array(Cuint, nevts)
    for i = 1:length(nevts)
        evtcodes[i] = Cuint(evts[i])
    end
    ret = RetCode(ccall((:PAPI_start_counters, :libpapi), Cint,
                        (Ptr{Cuint}, Cint), evtcodes, nevts))
    if ret != OK
        throw(PAPIError(ret))
    end
    return
end

#### High Level Interface ####

@doc """
""" ->
is_initialized() = Bool(ccall((:PAPI_is_initialized, :libpapi), Cint, ()))

@doc """
Get the number of hardware counters available on the system

`PAPI.num_counters()` returns the optimal length of the values array for high-level functions.
This value corresponds to the number of hardware counters supported by the current substrate.
`PAPI.num_counters()` initializes the PAPI library using `PAPI.library_init()` if necessary.
""" ->
num_counters() = Int(ccall((:PAPI_num_counters, :libpapi), Cint, ()))

@doc """
Add current counts to array and reset counters
""" ->
function accum_counters!(values::Vector{Clonglong})
    ret = RetCode(ccall((:PAPI_accum_counters, :libpapi), Cint,
                        (Ptr{Clonglong}, Cint), values, length(values)))
    if ret != OK
        throw(PAPIError(ret))
    end
end
accum_counters!(cs::EventSet) = (accum_counters!(cs.vals); copy(cs.vals))

@doc """
Get the number of components available on the system
""" ->
num_components() = Int(ccall((:PAPI_num_components, :libpapi), Cint, ()))

@doc """
""" ->
function read_counters!(values::Vector{Clonglong})
    ret = RetCode(ccall((:PAPI_read_counters, :libpapi), Cint,
                        (Ptr{Clonglong}, Cint), values, length(values)))
    if ret != OK
        throw(PAPIError(ret))
    end
end
read_counters!(cs::EventSet) = (read_counters!(cs.vals); copy(cs.vals))

@doc """
Start counting hardware events

`PAPI.start_counters()` initializes the PAPI library (if necessary) and starts counting the events named in the events array.
This function implicitly stops and initializes any counters running as a result of a previous call to `PAPI.start_counters()`.
It is the user's responsibility to choose events that can be counted simultaneously by reading the vendor's documentation.
The number of events should be no larger than the value returned by `PAPI.num_counters()`.
""" ->
function start_counters(events::Vector{Event})
    ret = RetCode(ccall((:PAPI_start_counters, :libpapi), Cint,
                        (Ptr{Cint}, Cint), pointer(events), length(events)))
    if ret != OK
        throw(PAPIError(ret))
    end
end
start_counters(cs::EventSet) = start_counters(cs.counters)

@doc """
Stop counters and return current counts
""" ->
function stop_counters()
    ret = RetCode(ccall((:PAPI_stop_counters, :libpapi), Cint,
                        (Ptr{Cuint}, Cint), C_NULL, 0))
    if ret != OK
        throw(PAPIError(ret))
    end
end
function stop_counters(events::Vector{Event})
    ret = RetCode(ccall((:PAPI_stop_counters, :libpapi), Cint,
                        (Ptr{Cuint}, Cint), pointer(events), length(events)))
    if ret != OK
        throw(PAPIError(ret))
    end
end
stop_counters(cs::EventSet) = stop_counters(cs.counters)

const _rtime = Cfloat[0.0]
const _ptime = Cfloat[0.0]
const _flpx = Clonglong[0]
const _mflpx = Cfloat[0.0]

@doc """
Get Mflips/s (floating point instruction rate), real time and processor time
""" ->
function flips!(flpins, mflips, rtime, ptime)
    ret = RetCode(ccall((:PAPI_flips, :libpapi), Cint,
                        (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Clonglong}, Ptr{Cfloat}),
                        rtime, ptime, flpins, mflips))
    if ret != OK
        throw(PAPIError(ret))
    end
end

@doc """
Get Mflips/s (floating point instruction rate), real time and processor time
""" ->
function flips()
    flips!(_flpx, _mflpx, _rtime, _ptime)
    return (_flpx[1], _mflpx[1], _rtime[1], _ptime[1])
end

macro flips(blk)
    quote
        PAPI.flips()
        $(esc(blk))
        local res = PAPI.flips()
        PAPI.stop_counters([PAPI.FP_INS])
        ret
    end
end

@doc """
Get Mflop/s (floating point operand rate), real time and processor time
""" ->
function flops!(flpops, mflops, rtime, ptime)
    ret = RetCode(ccall((:PAPI_flops, :libpapi), Cint,
                        (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Clonglong}, Ptr{Cfloat}),
                        rtime, ptime, flpops, mflops))
    if ret != OK
        throw(PAPIError(ret))
    end
end

@doc """
Get Mflop/s (floating point operand rate), real time and processor time
""" ->
function flops()
    flops!(_flpx, _mflpx, _rtime, _ptime)
    return (_flpx[1], _mflpx[1], _rtime[1], _ptime[1])
end

macro flops(blk)
    quote
        PAPI.flops()
        $(esc(blk))
        local res = PAPI.flops()
        PAPI.stop_counters([PAPI.FP_OPS])
        res
    end
end

@doc """
Get instructions per cycle, real time and processor time
""" ->
function ipc(rtime, ptime, ins, ipc)
    ret = RetCode(ccall((:PAPI_ipc, :libpapi), Cint,
                        (Ptr{Void}, Ptr{Cfloat}, Ptr{Clonglong}, Ptr{Cfloat}),
                        rtime, ptime, ins, ipc))
    if ret != OK
        throw(PAPIError(ret))
    end
end

@doc """
Get events per cycle, real time and processor time
""" ->
function epc(event, rtime, ptime, ref, core, evt, epc)
    ret = RetCode(ccall((:PAPI_epc, :libpapi), Cint,
                        (Cint, Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Clonglong},
                         Ptr{Clonglong}, Ptr{Clonglong}, Ptr{Cfloat}),
                        event, rtime, ptime, ref, core, evt, epc))
    if ret != OK
        throw(PAPIError(ret))
    end
end

end # module
