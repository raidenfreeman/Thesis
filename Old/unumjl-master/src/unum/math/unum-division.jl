#unum-division.jl - currently uses the goldschmidt method, but will also
#implement other division algorithms.


doc"""
  `Unums.div(::Unum, ::Unum)` outputs a Unum OR Ubound corresponding to the quotient
  of two unums.  This is bound to the (\/) operation if options[:usegnum] is not
  set.  Note that in the case of degenerate unums, div may change the bit values
  of the individual unums, but the values will not be altered.
"""
@universal function udiv(a::Unum, b::Unum)
  #some basic test cases.
  (isnan(a) || isnan(b)) && return nan(U)
  #division by zero is always a NaN, for unums.  Why?  Because zero must be unsigned
  #in the unum spec, the signedness of the resulting infinity is undefined, and the
  #answer thus must be NaN.
  is_zero(b) && return nan(U)
  #division from zero is always zero.
  is_zero(a) && return zero(U)

  #figure out the result sign.
  result_sign = (a.flags $ b.flags) & UNUM_SIGN_MASK

  #division from inf is always inf, except inf/inf = NaN.
  if is_inf(a)
    is_inf(b) && return nan(U)
    return inf(U, result_sign)
  end

  #division by inf is always zero.
  is_inf(b) && return zero(U)
  #division by a unit value is always the same value, with a possible sign change.
  is_unit(b) && return coerce_sign!(copy(a), result_sign)

  resolve_degenerates!(a)
  resolve_degenerates!(b)

  if is_exact(a) && is_exact(b)
    div_exact(a, b, result_sign)
  else
    div_inexact(a, b, result_sign)
  end
end

__frac_bits(FSS::Int64) = max_fsize(FSS) + 1

global verbose_div = false
function set_verbose()
  global verbose_div = true
  nothing
end

@universal function div_exact(a::Unum, b::Unum, result_sign::UInt16)

  #first, calculate the exponents.
  _asubnormal = is_subnormal(a)
  _bsubnormal = is_subnormal(b)

  _aexp = decode_exp(a)
  _bexp = decode_exp(b)

  #solve the exponent.
  exponent = _aexp - _bexp

  exponent += _asubnormal * 1 - _bsubnormal * 1

  dividend = copy(a)
  _asubnormal && (exponent -= normalize!(dividend))
  zero_a = frac_ctz(dividend)

  #check if the divisor's fraction is all zero. (exact power of two)
  if is_all_zero(b.fraction)
    #check for subnormality.
    if exponent < min_exponent(ESS)
      dividend.esize = max_esize(ESS)
      dividend.exponent = z64

      right_shift = to16(min_exponent(ESS) - exponent)
      right_shift > (max_esize(ESS) + o16) && return sss(U, result_sign)

      frac_rsh_underflow_check!(dividend, right_shift)
      frac_set_bit!(dividend, right_shift)
    else
      (dividend.esize, dividend.exponent) = encode_exp(exponent)
    end
    coerce_sign!(dividend, result_sign)
    return dividend
  end

  (exponent > max_exponent(ESS)) && return mmr(U, result_sign)
  (exponent < min_exponent(ESS,FSS) - 1) && return sss(U, result_sign)

  #we're going to have to readjust so that the top part of the result is
  #between 0.5 and 1
  exponent -= 1

  divisor = copy(b)
  _bsubnormal && (exponent += normalize!(divisor))
  zero_b = frac_ctz(divisor)

  exponent += frac_div!(dividend, divisor)

  if FSS < 6
    dividend.fraction &= mask_top(FSS)
  end

  (dividend.esize, dividend.exponent) = encode_exp(exponent)
  dividend.fsize = max_fsize(FSS)
  #create a tentative result.
  make_exact!(dividend)
  #count zeros on the tail of the dividend.
  zero_r = frac_ctz(dividend)
  one_r  = frac_cto(dividend)

  if (zero_a == zero_r + zero_b - __frac_bits(FSS))
    exact_trim!(dividend)
  elseif (zero_a == one_r + zero_b - __frac_bits(FSS))
    next_unum!(dividend)
    exact_trim!(dividend)
  else
    make_ulp!(dividend)
  end

  exponent = decode_exp(dividend)

  exponent > max_exponent(ESS) && return mmr!(dividend, result_sign)

  if exponent < min_exponent(ESS)
    #in the case that we need to make this subnormal.
    right_shift = to16(min_exponent(ESS) - exponent)
    right_shift > (max_fsize(FSS) + o16) && return sss!(dividend, result_sign)
    frac_rsh_underflow_check!(dividend, right_shift)
    frac_set_bit!(dividend, right_shift)
    dividend.esize = max_esize(ESS)
    dividend.exponent = z64
  end

  coerce_sign!(dividend, result_sign)
  return dividend
end

doc"""
  `Unums.frac_div!(dividend::Unum, divisor::Unum)` performs the binomial
  goldschmidt division algorithm.  Algorithm is as follows:

  For X/Y, where X in [1,2) and Y in (0.5, 1]:  pick Z s.t. Y = 1 - Z.  Observe:

  * (1 - Z)(1 + Z)     == (1 - Z^2)
  * (1 - Z^2)(1 + Z^2) == (1 - Z^4)
  * (1 - Z^4)(1 + Z^4) == (1 - Z^8), etc, so:

  (1 - Z)(1 + Z)(1 + Z^2)(1 + Z^4) -> 1 + Z^2N -> 1 as N -> ∞

  ∴ X(1 + Z)(1 + Z^2)(1 + Z^4) -> (X / Y) as N -> ∞.
"""
@universal function frac_div!(dividend::Unum, divisor::Unum)
  d_result = prep_result!(dividend)
  #first prepare the divisor.
  d_multiple = prep_multiple!(divisor)
  #replace the fraction of "divisor" with the actual value of Z, not considering
  #the normal fraction invisible one.

  carry = frac_dmul!(d_result, d_multiple)
  #because frac_mul expects the presence of the "invisible one", we don't need
  #to supply it.

  traversals = 0  #how many times have we traversed a boundary?

  for idx = 1:(FSS)

    verbose_div && println(d_result)

    (carry != o64) && begin
      d_result = frac_rsh!(d_result, 0x0001)
      traversals = 1
    end

    #square the fraction part of the result.
    d_multiple = frac_sqr!(d_multiple)
    #multply the dividend to be that expected result.

    carry = frac_dmul!(d_result, d_multiple)
  end

  finalize_result!(dividend, d_result)

  return traversals  #report whether or not the exponent was altered.
end

type i128shell
  a::UInt128
end

frac_rsh!(x::i128shell, sh::UInt16) = (x.a >>= sh; x)

function frac_sqr!{ESS,FSS}(a::UnumSmall{ESS,FSS})
  a.fraction = i64mul_simple(a.fraction, a.fraction)
  return a
end
function frac_sqr!(number::UInt128)
  top_word = (number >> 64)
  bottom_word = (number & 0x0000_0000_0000_0000_FFFF_FFFF_FFFF_FFFF)
  result = top_word * bottom_word
  result >>= 63                      #63 because there's a *2 in there.
  result += top_word * top_word
end
frac_sqr!{ESS,FSS}(multiplier::UnumLarge{ESS,FSS}) = (frac_mul!(multiplier, multiplier.fraction, Val{__cell_length(FSS) + __xtras(FSS)}, Val{false}); multiplier)

frac_dmul!{ESS,FSS}(dividend::UnumSmall{ESS,FSS}, multiplier::UnumSmall{ESS,FSS}) = frac_mul!(dividend, multiplier.fraction)
frac_dmul!{ESS,FSS}(dividend::UnumLarge{ESS,FSS}, multiplier::UnumLarge{ESS,FSS}) = frac_mul!(dividend, multiplier.fraction, Val{__cell_length(FSS) + __xtras(FSS)}, Val{true})
function frac_dmul!(dividend::i128shell, multiplier::UInt128)
  carry = o64
  top_d = (dividend.a >> 64)
  top_m = (multiplier >> 64)
  result::UInt128 = top_d * (multiplier & 0x0000_0000_0000_0000_FFFF_FFFF_FFFF_FFFF)
  old_result = result
  result += top_m * (dividend.a & 0x0000_0000_0000_0000_FFFF_FFFF_FFFF_FFFF)

  if (old_result > result)
    result >>= 64
    result += 0x0000_0000_0000_0001_0000_0000_0000_0000
  else
    result >>= 64
  end

  old_result = result
  result += top_d * top_m
  carry += (result < old_result) * o64

  old_result = result
  result += dividend.a
  carry += (result < old_result) * o64

  old_result = result
  result += multiplier
  carry += (result < old_result) * o64

  dividend.a = result
  return carry
end

prep_result!{ESS,FSS}(a::UnumSmall{ESS,FSS}) = a
prep_result!{ESS}(a::UnumSmall{ESS,6}) = i128shell(UInt128(a.fraction) << 64)
function prep_result!{ESS,FSS}(a::UnumLarge{ESS,FSS})
  for idx = 1:__xtras(FSS)
    push!(a.fraction.a, z64)
  end
  return a
end

__xtras(FSS) = 4#__cell_length(FSS) >> 1

prep_multiple!{ESS,FSS}(a::UnumSmall{ESS,FSS}) = (a.fraction = (z64 - ((a.fraction >> 1) | t64)); a)
function prep_multiple!{ESS}(a::UnumSmall{ESS, 6})
  lbit = ((a.fraction & o64) != z64)
  return (UInt128((lbit * f64) - ((a.fraction >> 1) | t64)) << 64) | (lbit * t64)
end
function prep_multiple!{ESS,FSS}(a::UnumLarge{ESS,FSS})
  @inbounds begin
    lbit = ((a.fraction[__cell_length(FSS)] & o64))
    frac_rsh!(a, 0x0001)
    a.fraction[1] |= t64
    invert!(a.fraction)
  end

  @inbounds a.fraction[__cell_length(FSS)] -= (lbit * o64)
  #now go through and invert every cell.

  #TODO:  Decide on this question (not now!)
  #hack-ey.  Should we be doing this or checking to see if we have the right size??
  push!(a.fraction.a, lbit * t64)
  for idx = 2:__xtras(FSS)
    push!(a.fraction.a, z64)
  end
  return a
end

finalize_result!{ESS,FSS}(a::UnumSmall{ESS,FSS}, b::UnumSmall{ESS,FSS}) = nothing
finalize_result!{ESS}(a::UnumSmall{ESS,6}, b::i128shell) = (a.fraction = top_part(b.a))
function finalize_result!{ESS,FSS}(a::UnumLarge{ESS,FSS}, b::UnumLarge{ESS,FSS})
  for idx = 1:__xtras(FSS)
    pop!(a.fraction.a)
  end
end

@universal function div_inexact(a::Unum, b::Unum, result_sign::UInt16)

  is_inf_ulp(a) && (return inf_ulp_div(a, b, result_sign))
  is_zero_ulp(a) && (return zero_ulp_div(a, b, result_sign))

  is_inf_ulp(b) && (return inf_ulp_div_right(a, b, result_sign))
  is_zero_ulp(b) && (return zero_ulp_div_right(a, b, result_sign))

  #calculate the tops and the bottoms of both ulps.
  outer_bound_dividend = is_exact(a) ? a : outer_exact(a)
  outer_bound_divisor = is_exact(b) ? b : outer_exact(b)

  #calculate the inner and outer bounds of the result.
  inner = div_exact(a, outer_bound_divisor, result_sign)
  outer = div_exact(outer_bound_dividend, b, result_sign)

  #just in case we found an exact number here, make it not so.
  is_exact(inner) && outer_ulp!(inner)
  is_exact(outer) && inner_ulp!(outer)

  return (result_sign != z16) ? resolve_as_utype!(outer, inner) : resolve_as_utype!(inner, outer)
end

@universal function inf_ulp_div(inf_ulp::Unum, b::Unum, result_sign::UInt16)
  (decode_exp(b) < 0) && return mmr(U, result_sign)
  is_inf_ulp(b) && return allsignedreals(result_sign, U)

  outer_bound_b = is_exact(b) ? b : outer_exact(b)
  inner_bound_u = inner_exact(inf_ulp)

  result_inner = div_exact(inner_bound_u, outer_bound_b, result_sign)

  is_exact(result_inner) && outer_ulp!(result_inner)

  return (result_sign != z16) ? resolve_as_utype!(neg_mmr(U), result_inner) : resolve_as_utype!(result_inner, mmr(U))
end

@universal function zero_ulp_div(zero_ulp::Unum, b::Unum, result_sign::UInt16)

  is_zero_ulp(b) && return allsignedreals(result_sign, U)

  _ulp_exact = outer_exact(zero_ulp)
  _arg_exact = is_exact(b) ? b : outer_exact(b)

  res_exp = decode_exp(_ulp_exact) + 1 * is_subnormal(_ulp_exact) - decode_exp(_arg_exact) - 1 * is_subnormal(_arg_exact)
  (res_exp < min_exponent(ESS, FSS)) && return sss(U, result_sign)

  result_outer = div_exact(_ulp_exact, _arg_exact, result_sign)

  is_exact(result_outer) && inner_ulp!(result_outer)

  return (result_sign != z16) ? resolve_as_utype!(result_outer, neg_sss(U)) : resolve_as_utype!(sss(U), result_outer)
end

@universal function inf_ulp_div_right(a::Unum, inf_ulp::Unum, result_sign::UInt16)

 _arg_exact = is_exact(a) ? a : outer_exact(a)
 _ulp_exact = inner_exact(inf_ulp)

 #no need to check inf/inf because that's covered by the right hand side function.

 outer_bound = div_exact(_arg_exact, _ulp_exact, result_sign)
 is_exact(outer_bound) && inner_ulp!(outer_bound)

 return (result_sign != z16) ? resolve_as_utype!(outer_bound, neg_sss(U)) : resolve_as_utype!(sss(U), outer_bound)
end

@universal function zero_ulp_div_right(a::Unum, zero_ulp::Unum, result_sign::UInt16)
  _arg_exact = is_exact(a) ? a : inner_exact(a)
  _ulp_exact = outer_exact(zero_ulp)

  inner_bound = div_exact(_arg_exact, _ulp_exact, result_sign)

  is_exact(inner_bound) && outer_ulp!(inner_bound)

  return (result_sign != z16) ? resolve_as_utype!(neg_mmr(U), inner_bound) : resolve_as_utype!(inner_bound, mmr(U))
end

#import the Base divide operation and bind it to the udiv and udiv! functions
import Base./
@bind_operation(/, udiv)
