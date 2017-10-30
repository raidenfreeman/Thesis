#testing the sbit state of the Gnum.
set_onesided!{ESS,FSS}(x::Gnum{ESS,FSS}) = (x.scratchpad.flags |= GNUM_ONESIDED_MASK; x)
set_twosided!{ESS,FSS}(x::Gnum{ESS,FSS}) = (x.scratchpad.flags &= ~GNUM_ONESIDED_MASK; x)
is_onesided{ESS,FSS}(x::Gnum{ESS,FSS}) = ((x.scratchpad.flags & GNUM_ONESIDED_MASK != 0) || (is_nan(x)))
is_twosided{ESS,FSS}(x::Gnum{ESS,FSS}) = ((x.scratchpad.flags & GNUM_ONESIDED_MASK == 0) && (!is_nan(x)))

#the ignore_side utility is used for operations that do identity checks before
#proceeding with calculations, and flags that a side has already been checked
#and should not be altered.  the `should_calculate` directive runs this downstream
@generated function ignore_side!{ESS,FSS,side}(x::Gnum{ESS,FSS}, ::Type{Val{side}})
  :(x.$side.flags |= GNUM_IGNORE_SIDE_MASK; nothing)
end
function ignore_both_sides!{ESS,FSS}(x::Gnum{ESS,FSS})
  x.lower.flags |= GNUM_IGNORE_SIDE_MASK
  x.upper.flags |= GNUM_IGNORE_SIDE_MASK
  nothing
end
function clear_ignore_sides!{ESS,FSS}(x::Gnum{ESS,FSS})
  x.lower.flags &= ~GNUM_IGNORE_SIDE_MASK
  x.upper.flags &= ~GNUM_IGNORE_SIDE_MASK
  nothing
end
#reports on whether or not the side referred to should be calculated.
@generated function should_calculate{ESS,FSS,side}(x::Gnum{ESS,FSS}, ::Type{Val{side}})
  if (side == :lower)
    :((x.lower.flags & GNUM_IGNORE_SIDE_MASK) == 0)
  else
    :(is_twosided(x) && ((x.upper.flags & GNUM_IGNORE_SIDE_MASK) == 0))
  end
end

function put_unum!{ESS,FSS}(src::Unum{ESS,FSS}, dest::Gnum{ESS,FSS})
  #puts a unum into the gnum, assuming it is going to be a single-sided unum.
  copy_unum!(src, dest.lower)
  set_flags!(dest, LOWER_UNUM)
  set_onesided!(dest)
  nothing
end

function get_unum!{ESS,FSS}(src::Gnum{ESS,FSS}, dest::Unum{ESS,FSS})
  #puts a unum into the gnum, assuming it already is a single-sided unum.
  (is_twosided(src) && !is_nan(src)) && throw(ArgumentError("Error: Gnum represents a Ubound"))
  is_nan(src) && return nan(Unum{ESS,FSS})
  force_from_flags!(src, dest, LOWER_UNUM) || copy_unum!(src.lower, dest)
  nothing
end

@generated function put_unum!{ESS,FSS,side}(src::Unum{ESS,FSS}, dest::Gnum{ESS,FSS}, ::Type{Val{side}})
  #sets the unum value on either side of the Gnum (or possibly the scratchpad.)
  quote
    copy_unum!(src, dest.$side)
    set_g_flags!(dest.$side)
    nothing
  end
end

@generated function get_unum!{ESS,FSS,side}(src::Gnum{ESS,FSS}, dest::Unum{ESS,FSS}, ::Type{Val{side}})
  #retrieves the unum value from either side of the Gnum (or possibly the scratchpad.)
  quote
    force_from_flags!(src, dest, Val{$side}) || copy_unum!(src.$side, dest);
    nothing
  end
end

function put_ubound!{ESS,FSS}(src::Ubound{ESS,FSS}, dest::Gnum{ESS,FSS})
  #fills the Gnum data from a source Ubound.
  copy_unum!(src.lower, dest.lower)
  copy_unum!(src.upper, dest.upper)
  set_flags!(dest)
  nothing
end

function get_ubound!{ESS,FSS}(src::Gnum{ESS,FSS}, dest::Ubound{ESS,FSS})
  #fills the Ubound data from a source Gnum.
  (is_nan(src) || is_onesided(src)) && throw(ArgumentError("Error:  Gnum represents a Unum"))
  #be sure to check if one of the flags is thrown before copying, otherwise
  #undefined results may occur.
  force_from_flags!(src, dest.lower, LOWER_UNUM) || copy_unum!(src.lower, dest.lower)
  force_from_flags!(src, dest.upper, UPPER_UNUM) || copy_unum!(src.upper, dest.upper)
  nothing
end

doc"""
`set_g_flags!(v::Unum{ESS,FSS})` sets the flags on any given unum to the appropriate
g-layer flag scheme.
"""
function set_g_flags!{ESS,FSS}(v::Unum{ESS,FSS})
  #clear the mask, keeping only flags and scratchpad values.
  is_inf(v) &&  (v.flags |= GNUM_INF_MASK; return)
  is_mmr(v) &&  (v.flags |= GNUM_MMR_MASK; return)
  is_sss(v) &&  (v.flags |= GNUM_SSS_MASK; return)
  is_zero(v) && (v.flags |= GNUM_ZERO_MASK; return)
  v.flags &= GNUM_SFLAGS_MASK | UNUM_FLAG_MASK
end

doc"""
  `set_flags!(::Gnum{ESS,FSS}, ::Type{Val{side}})` sets flags on one side of the
  gnum by examining the value.
"""
@generated function set_flags!{ESS,FSS,side}(v::Gnum{ESS,FSS}, ::Type{Val{side}})
  quote
    is_nan(v.$side) && (v.scratchpad.flags |= GNUM_NAN_MASK; return)
    #clear the mask, keeping only flags and scratchpad values.
    v.$side.flags &= GNUM_SFLAGS_MASK | UNUM_FLAG_MASK
    set_g_flags!(v.$side)
  end
end

function clear_gflags!{ESS,FSS}(target::Unum{ESS,FSS})
  target.flags &= ~(GNUM_FLAG_MASK)
end

function copy_unum_with_gflags!{ESS,FSS}(src::Unum{ESS,FSS}, dest::Unum{ESS,FSS})
  gflags = src.flags & GNUM_FLAG_MASK
  copy_unum!(src, dest)
  dest.flags |= gflags
end

function additive_inverse!{ESS,FSS}(target::Gnum{ESS,FSS})
  #lazy eval on this process.
  is_nan(target) && return
  
  if is_twosided(target)
    #swap the order of lower/upper via a buffer intermediate.
    copy_unum_with_gflags!(target.lower, target.buffer)
    copy_unum_with_gflags!(target.upper, target.lower)
    copy_unum_with_gflags!(target.buffer, target.upper)
    #next swap the parities on lower and upper
    target.upper.flags $= UNUM_SIGN_MASK
  end
  target.lower.flags $= UNUM_SIGN_MASK
end

doc"""
  `emit_data(::Gnum{ESS,FSS})` takes the contents of a gnum and decides if it's
  represents a solo unum or a ubound.  It then allocates the appropriate type and
  emits that as a result.
"""
function emit_data{ESS,FSS}(src::Gnum{ESS,FSS})
  #be ready to release a utype as a result.
  res::Utype
  #check to see if we're a NaN
  (is_nan(src)) && return nan(Unum{ESS,FSS})
  #check to see if we're a single unum
  if (is_onesided(src))
    #prepare the result by allocating.
    res = zero(Unum{ESS,FSS})
    #put the value in the allocated space.
    get_unum!(src, res)
    res
  else
    #this time, we know it's a ubound.
    #prepare the result by allocating.
    res = Ubound{ESS,FSS}()
    #put the value in the allocated space.
    get_ubound!(src, res)
    (res.lower == res.upper) ? res.lower : res
  end
end
