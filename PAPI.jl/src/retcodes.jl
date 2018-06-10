# Return codes adapted from papi.h
@enum(RetCode,
      OK = 0,
      EINVAL = -1,      # Invalid argument
      ENOMEM = -2,      # Insufficient memory
      ESYS   = -3,      # A System C library call failed
      ECMP   = -4,      # Not supported by component
      ECLOST = -5,      # Access to the counters was lost or interrupted
      EBUG   = -6,      # Internal error, please send mail to the developers
      ENOEVNT = -7,     # Event does not exist
      ECNFLCT = -8,     # Event exists, but cannot be counted due to counter resource limitations
      ENOTRUN = -9,     # EventSet is currently not running
      EISRUN  = -10,    # EventSet is currently counting
      ENOEVST = -11,    # No such EventSet Available
      ENOTPRESET = -12, # Event in argument is not a valid preset
      ENOCNTR = -13,    # Hardware does not support performance counters
      EMISC = -14,      # Unknown error code
      EPERM = -15,      # Permission level does not permit operation
      ENOINIT = -16,    # PAPI hasn't been initialized yet
      ENOCMP = -17,     # Component Index isn't set
      ENOSUPP = -18,    # Not supported
      ENOIMPL = -19,    # Not implemented
      EBUF = -20,       # Buffer size exceeded
      EINVAL_DOM = -21, # EventSet domain is not supported for the operation
      EATTR = -22,      # Invalid or missing event attributes
      ECOUNT = -23,     # Too many events or attributes */attributes
      ECOMBO =  -24,    # Bad combination of  features
)

const errmsg = let msgs = Dict{RetCode,String}(
        OK => "OK",
        EINVAL => "Invalid argument",
        ENOMEM => "Insufficient memory",
        ESYS => "A System C library call failed",
        ECMP => "Not supported by component",
        ECLOST => "Access to the counters was lost or interrupted",
        EBUG => "Internal error, please send mail to the developers",
        ENOEVNT => "Event does not exist",
        ECNFLCT => "Event exists, but cannot be counted due to counter resource limitations",
        ENOTRUN => "EventSet is currently not running",
        EISRUN => "EventSet is currently counting",
        ENOEVST => "No such EventSet Available",
        ENOTPRESET => "Event in argument is not a valid preset",
        ENOCNTR => "Hardware does not support performance counters",
        EMISC => "Unknown error code",
        EPERM => "Permission level does not permit operation",
        ENOINIT => "PAPI hasn't been initialized yet",
        ENOCMP => "Component Index isn't set",
        ENOSUPP => "Not supported",
        ENOIMPL => "Not implemented",
        EBUF => "Buffer size exceeded",
        EINVAL_DOM => "EventSet domain is not supported for the operation",
        EATTR => "Invalid or missing event attributes",
        ECOUNT => "Too many events or attributes",
        ECOMBO => "Bad combination of  features"
    )
    errmsg(r::RetCode) = msgs[r]
end
