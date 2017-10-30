#unit-boundstesting.jl
#testing that the endpoint bounds from unums conforms to the mathematical
#expectation
UT = Unum{3,5}

import Unums: inner_exact!, inner_ulp!, outer_exact!, outer_ulp!

left_neginf =   Ubound(neg_inf(UT), UT(-1))
left_negmmr_b = Ubound(neg_mmr(UT), UT(-1))
left_negmmr_u = neg_mmr(UT)
left_exact =    Ubound(UT(-2), UT(-1))
left_ulp =      Ubound(inner_ulp!(UT(-2)), UT(-1))
left_posinf =   inf(UT)

right_neginf =   neg_inf(UT)
right_ulp =      Ubound(UT(1), inner_ulp!(UT(2)))
right_exact =    Ubound(UT(1), UT(2))
right_posmmr_u = mmr(UT)
right_posmmr_b = Ubound(UT(1), mmr(UT))
right_posinf =   Ubound(UT(1), inf(UT))

#testing special ubound addition (NB: p. 113, TEoE).
#TOP TABLE
#top row, left to right.
@test left_neginf + left_neginf   == Ubound(neg_inf(UT), UT(-2))                #[-∞, -1] + [-∞, -1]  == [-∞, -2]
@test left_neginf + left_negmmr_b == Ubound(neg_inf(UT), UT(-2))                #[-∞, -1] + (-∞, -1]  == [-∞, -2]
@test left_neginf + left_negmmr_u == Ubound(neg_inf(UT), neg_mmr(UT))           #[-∞, -1] + (-∞, nmr) == [-∞, nmr)
@test left_neginf + left_exact    == Ubound(neg_inf(UT), UT(-2))                #[-∞, -1] + [-2, -1]  == [-∞, -2]
@test left_neginf + left_ulp      == Ubound(neg_inf(UT), UT(-2))                #[-∞, -1] + (-2, -1]  == [-∞, -2]
@test isnan(left_neginf + left_posinf)                                          #[-∞, -1] + ∞  == NaN
#second row (ubound), left to right
@test left_negmmr_b + left_neginf   == Ubound(neg_inf(UT), UT(-2))              #(-∞, -1] + [-∞, -1]  == [-∞, -2]
@test left_negmmr_b + left_negmmr_b == Ubound(neg_mmr(UT), UT(-2))              #(-∞, -1] + (-∞, -1]  == (-∞, -2]
@test left_negmmr_b + left_negmmr_u == neg_mmr(UT)                              #(-∞, -1] + (-∞, nmr) == (-∞, nmr)
@test left_negmmr_b + left_exact    == Ubound(neg_mmr(UT), UT(-2))              #(-∞, -1] + [-2, -1]  == (-∞, -2]
@test left_negmmr_b + left_ulp      == Ubound(neg_mmr(UT), UT(-2))              #(-∞, -1] + (-2, -1]  == (-∞, -2]
@test left_negmmr_b + left_posinf   == pos_inf(UT)                              #(-∞, -1] + ∞  == ∞
#second row (unum), left to right
@test left_negmmr_u + left_neginf   == Ubound(neg_inf(UT), neg_mmr(UT))         #(-∞, nmr) + [-∞, -1]  == [-∞, nmr)
@test left_negmmr_u + left_negmmr_b == neg_mmr(UT)                              #(-∞, nmr) + (-∞, -1]  == (-∞, nmr)
@test left_negmmr_u + left_negmmr_u == neg_mmr(UT)                              #(-∞, nmr) + (-∞, nmr) == (-∞, nmr)
@test left_negmmr_u + left_exact    == neg_mmr(UT)                              #(-∞, nmr) + [-2, -1]  == (-∞, nmr)
@test left_negmmr_u + left_ulp      == neg_mmr(UT)                              #(-∞, nmr) + (-2, -1]  == (-∞, nmr)
@test left_negmmr_u + left_posinf   == pos_inf(UT)                              #(-∞, nmr) + ∞  == ∞
#third row, left to right
@test left_exact + left_neginf   == Ubound(neg_inf(UT), UT(-2))                 #[-2, -1] + [-∞, -1]  == [-∞, -2]
@test left_exact + left_negmmr_b == Ubound(neg_mmr(UT), UT(-2))                 #[-2, -1] + (-∞, -1]  == (-∞, -2]
@test left_exact + left_negmmr_u == neg_mmr(UT)                                 #[-2, -1] + (-∞, nmr) == (-∞, nmr)
@test left_exact + left_exact    == Ubound(UT(-4), UT(-2))                      #[-2, -1] + [-2, -1]  == [-4, -2]
@test left_exact + left_ulp      == Ubound(inner_ulp!(UT(-4)), UT(-2))          #[-2, -1] + (-2, -1]  == (-4, -2]
@test left_exact + left_posinf   == pos_inf(UT)                                 #[-2, -1] + ∞  == ∞
#fourth row, left to right
@test left_ulp + left_neginf   == Ubound(neg_inf(UT), UT(-2))                   #(-2, -1] + [-∞, -1]  == [-∞, -2]
@test left_ulp + left_negmmr_b == Ubound(neg_mmr(UT), UT(-2))                   #(-2, -1] + (-∞, -1]  == (-∞, -2]
@test left_ulp + left_negmmr_u == neg_mmr(UT)                                   #(-2, -1] + (-∞, nmr) == (-∞, nmr)
@test left_ulp + left_exact    == Ubound(inner_ulp!(UT(-4)), UT(-2))            #(-2, -1] + [-2, -1]  == (-4, -2]
@test left_ulp + left_ulp      == Ubound(inner_ulp!(UT(-4)), UT(-2))            #(-2, -1] + (-2, -1]  == (-4, -2]
@test left_ulp + left_posinf   == pos_inf(UT)                                   #(-2, -1] + ∞  == ∞
#fifth row, left to right
@test isnan(left_posinf + left_neginf)                                          #∞ + [-∞, -1]  == NaN
@test left_posinf + left_negmmr_b == pos_inf(UT)                                #∞ + (-∞, -1]  == ∞
@test left_posinf + left_negmmr_u == pos_inf(UT)                                #∞ + (-∞, nmr) == ∞
@test left_posinf + left_exact    == pos_inf(UT)                                #∞ + [-2, -1]  == ∞
@test left_posinf + left_ulp      == pos_inf(UT)                                #∞ + (-2, -1]  == ∞
@test left_posinf + left_posinf   == pos_inf(UT)                                #∞ + ∞  == ∞

#BOTTOM TABLE
#top row, left to right.
@test right_neginf + right_neginf   == neg_inf(UT)                              #-∞ + -∞      == -∞
@test right_neginf + right_ulp      == neg_inf(UT)                              #-∞ + [1, 2)  == -∞
@test right_neginf + right_exact    == neg_inf(UT)                              #-∞ + [1, 2]  == -∞
@test right_neginf + right_posmmr_u == neg_inf(UT)                              #-∞ + (mr, ∞) == -∞
@test right_neginf + right_posmmr_b == neg_inf(UT)                              #-∞ + [1, ∞]  == -∞
@test isnan(right_neginf + right_posinf)                                        #-∞ + ∞       == NaN
#second row, left to right.
@test right_ulp + right_neginf   == neg_inf(UT)                                 #[1, 2) + -∞      == -∞
@test right_ulp + right_ulp      == Ubound(UT(2), inner_ulp!(UT(4)))            #[1, 2) + [1, 2)  == [2, 4)
@test right_ulp + right_exact    == Ubound(UT(2), inner_ulp!(UT(4)))            #[1, 2) + [1, 2]  == [2, 4)
@test right_ulp + right_posmmr_u == pos_mmr(UT)                                 #[1, 2) + (mr, ∞) == (mr, ∞)
@test right_ulp + right_posmmr_b == Ubound(UT(2), pos_mmr(UT))                  #[1, 2) + [1, ∞)  == [2, ∞)
@test right_ulp + right_posinf   == Ubound(UT(2), pos_inf(UT))                  #[1, 2) + [1 ,∞]  == [2, ∞]
#third row, left to right.
@test right_exact + right_neginf   == neg_inf(UT)                               #[1, 2] + -∞      == -∞
@test right_exact + right_ulp      == Ubound(UT(2), inner_ulp!(UT(4)))          #[1, 2] + [1, 2)  == [2, 4)
@test right_exact + right_exact    == Ubound(UT(2), UT(4))                      #[1, 2] + [1, 2]  == [2, 4]
@test right_exact + right_posmmr_u == pos_mmr(UT)                               #[1, 2] + (mr, ∞) == (mr, ∞)
@test right_exact + right_posmmr_b == Ubound(UT(2), pos_mmr(UT))                #[1, 2] + [1, ∞)  == [2, ∞)
@test right_exact + right_posinf   == Ubound(UT(2), pos_inf(UT))                #[1, 2] + [1 ,∞]  == [2, ∞]
#fourth row (unum), left to right.
@test right_posmmr_u + right_neginf   == neg_inf(UT)                            #(mr, ∞) + -∞      == -∞
@test right_posmmr_u + right_ulp      == pos_mmr(UT)                            #(mr, ∞) + [1, 2)  == (mr, ∞)
@test right_posmmr_u + right_exact    == pos_mmr(UT)                            #(mr, ∞) + [1, 2]  == (mr, ∞)
@test right_posmmr_u + right_posmmr_u == pos_mmr(UT)                            #(mr, ∞) + (mr, ∞) == (mr, ∞)
@test right_posmmr_u + right_posmmr_b == pos_mmr(UT)                            #(mr, ∞) + [1, ∞)  == (mr, ∞)
@test right_posmmr_u + right_posinf   == Ubound(pos_mmr(UT), pos_inf(UT))       #(mr, ∞) + [1 ,∞]  == (mr, ∞]
#fourth row (ubound), left to right.
@test right_posmmr_b + right_neginf   == neg_inf(UT)                            #[1, ∞) + -∞      == -∞
@test right_posmmr_b + right_ulp      == Ubound(UT(2), pos_mmr(UT))             #[1, ∞) + [1, 2)  == [2, ∞)
@test right_posmmr_b + right_exact    == Ubound(UT(2), pos_mmr(UT))             #[1, ∞) + [1, 2]  == [2, ∞)
@test right_posmmr_b + right_posmmr_u == pos_mmr(UT)                            #[1, ∞) + (mr, ∞) == (mr, ∞)
@test right_posmmr_b + right_posmmr_b == Ubound(UT(2), pos_mmr(UT))             #[1, ∞) + [1, ∞)  == [2, ∞)
@test right_posmmr_b + right_posinf   == Ubound(UT(2), pos_inf(UT))             #[1, ∞) + [1 ,∞]  == [2, ∞]
#fifth row, left to right.
@test isnan(right_posinf + right_neginf)                                        #[1, ∞] + -∞      == NaN
@test right_posinf + right_ulp      == Ubound(UT(2), pos_inf(UT))               #[1, ∞] + [1, 2)  == [2, ∞]
@test right_posinf + right_exact    == Ubound(UT(2), pos_inf(UT))               #[1, ∞] + [1, 2]  == [2, ∞]
@test right_posinf + right_posmmr_u == Ubound(pos_mmr(UT), pos_inf(UT))         #[1, ∞] + (mr, ∞) == (mr, ∞]
@test right_posinf + right_posmmr_b == Ubound(UT(2), pos_inf(UT))               #[1, ∞] + [1, ∞)  == [2, ∞]
@test right_posinf + right_posinf   == Ubound(UT(2), pos_inf(UT))               #[1, ∞] + [1, ∞]  == [2, ∞]

#testing special ubound multiplication (NB: p. 130, TEoE)
left_zero_exact = Ubound(UT(0), UT(1))
left_zero_ulp_b = Ubound(sss(UT), UT(1))
left_zero_ulp_u = sss(UT)
left_pos_exact  = Ubound(UT(1), UT(2))
left_pos_ulp    = Ubound(outer_ulp!(UT(1)), UT(2))

right_zero_exact = zero(UT)
#TOP TABLE
#top row, left to right.
@test left_zero_exact * left_zero_exact == Ubound(UT(0), UT(1))                 #[0, 1] * [0, 1]   == [0, 1]
@test left_zero_exact * left_zero_ulp_b == Ubound(UT(0), UT(1))                 #[0, 1] * (0, 1]   == [0, 1]
@test left_zero_exact * left_zero_ulp_u == Ubound(UT(0), sss(UT))               #[0, 1] * (0, ssn) == [0, ssn)
@test left_zero_exact * left_pos_exact  == Ubound(UT(0), UT(2))                 #[0, 1] * [1, 2]   == [0, 2]
@test left_zero_exact * left_pos_ulp    == Ubound(UT(0), UT(2))                 #[0, 1] * (1, 2]   == [0, 2]
@test isnan(left_zero_exact * left_posinf)                                      #[0, 1] * ∞        == NaN
#second row (ubound), left to right.
@test left_zero_ulp_b * left_zero_exact == Ubound(UT(0), UT(1))                 #(0, 1] * [0, 1]   == [0, 1]
@test left_zero_ulp_b * left_zero_ulp_b == Ubound(sss(UT), UT(1))               #(0, 1] * (0, 1]   == (0, 1]
@test left_zero_ulp_b * left_zero_ulp_u == sss(UT)                              #(0, 1] * (0, ssn) == (0, ssn)
@test left_zero_ulp_b * left_pos_exact  == Ubound(sss(UT), UT(2))               #(0, 1] * [1, 2]   == (0, 2]
@test left_zero_ulp_b * left_pos_ulp    == Ubound(sss(UT), UT(2))               #(0, 1] * (1, 2]   == (0, 2]
@test left_zero_ulp_b * left_posinf     == inf(UT)                              #(0, 1] * ∞        == ∞
#second row (unum), left to right.
ssn2 = Unum{3,5}(z64, z64, o16, 0x0007, 0x001e)
@test left_zero_ulp_u * left_zero_exact == Ubound(UT(0), sss(UT))               #(0, ssn) * [0, 1]   == [0, ssn)
@test left_zero_ulp_u * left_zero_ulp_b == sss(UT)                              #(0, ssn) * (0, 1]   == (0, ssn)
@test left_zero_ulp_u * left_zero_ulp_u == sss(UT)                              #(0, ssn) * (0, ssn) == (0, ssn)
@test left_zero_ulp_u * left_pos_exact  == ssn2                                 #(0, ssn) * [1, 2]   == (0, 2*ssn)
@test left_zero_ulp_u * left_pos_ulp    == ssn2                                 #(0, ssn) * (1, 2]   == (0, 2*ssn)
@test left_zero_ulp_u * left_posinf     == inf(UT)                              #(0, ssn) * ∞        == ∞
#third row, left to right.
@test left_pos_exact * left_zero_exact == Ubound(UT(0), UT(2))                  #[1, 2] * [0, 1]   == [0, 2]
@test left_pos_exact * left_zero_ulp_b == Ubound(sss(UT), UT(2))                #[1, 2] * (0, 1]   == (0, 2]
@test left_pos_exact * left_zero_ulp_u == ssn2                                  #[1, 2] * (0, ssn) == (0, 2 * ssn)
@test left_pos_exact * left_pos_exact  == Ubound(UT(1), UT(4))                  #[1, 2] * [1, 2]   == [1, 4]
@test left_pos_exact * left_pos_ulp    == Ubound(outer_ulp!(UT(1)), UT(4))      #[1, 2] * (1, 2]   == (1, 4]
@test left_pos_exact * left_posinf     == inf(UT)                               #[1, 2] * ∞        == ∞
#fourth row, left to right.
@test left_pos_ulp * left_zero_exact == Ubound(UT(0), UT(2))                    #(1, 2] * [0, 1]   == [0, 2]
@test left_pos_ulp * left_zero_ulp_b == Ubound(sss(UT), UT(2))                  #(1, 2] * (0, 1]   == (0, 2]
@test left_pos_ulp * left_zero_ulp_u == ssn2                                    #(1, 2] * (0, ssn) == (0, 2* ssn)
@test left_pos_ulp * left_pos_exact  == Ubound(outer_ulp!(UT(1)), UT(4))        #(1, 2] * [1, 2]   == (1, 4]
@test left_pos_ulp * left_pos_ulp    == Ubound(outer_ulp!(UT(1)), UT(4))        #(1, 2] * (1, 2]   == (1, 4]
@test left_pos_ulp * left_posinf     == inf(UT)                                 #(1, 2] * ∞        == ∞
#fifth row, left to right.
@test isequal(left_posinf * left_zero_exact, UT(NaN))                           # ∞ * [0, 1]   == NaN
@test left_posinf * left_zero_ulp_b == inf(UT)                                  # ∞ * (0, 1]   == ∞
@test left_posinf * left_zero_ulp_u == inf(UT)                                  # ∞ * (0, ssn) == ∞
@test left_posinf * left_pos_exact  == inf(UT)                                  # ∞ * [1, 2]   == ∞
@test left_posinf * left_pos_ulp    == inf(UT)                                  # ∞ * (1, 2]   == ∞
@test left_posinf * left_posinf     == inf(UT)                                  # ∞ * ∞        == ∞

#BOTTOM TABLE
#top row, left to right.
@test right_zero_exact * right_zero_exact == zero(UT)                           # 0 * 0        == 0
@test right_zero_exact * right_ulp        == zero(UT)                           # 0 * [1, 2)   == 0
@test right_zero_exact * right_exact      == zero(UT)                           # 0 * [1, 2]   == 0
@test right_zero_exact * right_posmmr_u   == zero(UT)                           # 0 * (mr, ∞)  == 0
@test right_zero_exact * right_posmmr_b   == zero(UT)                           # 0 * [1, ∞)   == 0
@test isequal(right_zero_exact * right_posinf, UT(NaN))                         # 0 * [1, ∞]   == NaN
#second row, left to right.
@test right_ulp * right_zero_exact == zero(UT)                                  #[1, 2) * 0        == 0
@test right_ulp * right_ulp        == Ubound(UT(1), inner_ulp!(UT(4)))          #[1, 2) * [1, 2)   == [1, 4)
@test right_ulp * right_exact      == Ubound(UT(1), inner_ulp!(UT(4)))          #[1, 2) * [1, 2]   == [1, 4)
@test right_ulp * right_posmmr_u   == mmr(UT)                                   #[1, 2) * (mr, ∞)  == (mr, ∞)
@test right_ulp * right_posmmr_b   == right_posmmr_b                            #[1, 2) * [1, ∞)   == [1, ∞)
@test right_ulp * right_posinf     == right_posinf                              #[1, 2) * [1, ∞]   == [1, ∞]
#third row, left to right.
@test right_exact * right_zero_exact == zero(UT)                                #[1, 2] * 0        == 0
@test right_exact * right_ulp        == Ubound(UT(1), inner_ulp!(UT(4)))        #[1, 2] * [1, 2)   == [1, 4)
@test right_exact * right_exact      == Ubound(UT(1), UT(4))                    #[1, 2] * [1, 2]   == [1, 4]
@test right_exact * right_posmmr_u   == mmr(UT)                                 #[1, 2] * (mr, ∞)  == (mr, ∞)
@test right_exact * right_posmmr_b   == right_posmmr_b                          #[1, 2] * [1, ∞)   == [1, ∞)
@test right_exact * right_posinf     == right_posinf                            #[1, 2] * [1, ∞]   == [1, ∞]
#fourth row (unum), left to right.
@test right_posmmr_u * right_zero_exact == zero(UT)                             #(mr, ∞) * 0        == 0
@test right_posmmr_u * right_ulp        == mmr(UT)                              #(mr, ∞) * [1, 2)   == (mr, ∞)
@test right_posmmr_u * right_exact      == mmr(UT)                              #(mr, ∞) * [1, 2]   == (mr, ∞)
@test right_posmmr_u * right_posmmr_u   == mmr(UT)                              #(mr, ∞) * (mr, ∞)  == (mr, ∞)
@test right_posmmr_u * right_posmmr_b   == mmr(UT)                              #(mr, ∞) * [1, ∞)   == (mr, ∞)
@test right_posmmr_u * right_posinf     == Ubound(mmr(UT), inf(UT))             #(mr, ∞) * [1, ∞]   == (mr, ∞]
#fourth row (ubound), left to right.
@test right_posmmr_b * right_zero_exact == zero(UT)                             #[1, ∞) * 0        == 0
@test right_posmmr_b * right_ulp        == right_posmmr_b                       #[1, ∞) * [1, 2)   == [1, ∞)
@test right_posmmr_b * right_exact      == right_posmmr_b                       #[1, ∞) * [1, 2]   == [1, ∞)
@test right_posmmr_b * right_posmmr_u   == mmr(UT)                              #[1, ∞) * (mr, ∞)  == (mr, ∞)
@test right_posmmr_b * right_posmmr_b   == right_posmmr_b                       #[1, ∞) * [1, ∞)   == [1, ∞)
@test right_posmmr_b * right_posinf     == Ubound(UT(1), inf(UT))               #[1, ∞) * [1, ∞]   == [1, ∞]
#fifth row, left to right.
@test isequal(right_posinf * right_zero_exact, UT(NaN))                         #[1, ∞] * 0        == NaN
@test right_posinf * right_ulp        == right_posinf                           #[1, ∞] * [1, 2)   == [1, ∞]
@test right_posinf * right_exact      == right_posinf                           #[1, ∞] * [1, 2]   == [1, ∞]
@test right_posinf * right_posmmr_u   == Ubound(mmr(UT), inf(UT))               #[1, ∞] * (mr, ∞)  == (mr, ∞]
@test right_posinf * right_posmmr_b   == right_posinf                           #[1, ∞] * [1, ∞)   == [1, ∞]
@test right_posinf * right_posinf     == right_posinf                           #[1, ∞] * [1, ∞]   == [1, ∞]


#testing special ubound division (NB: p. 138, TEoE)
#NB:  Why is dividing by zero always NaN except in the closed-bounds case?
#because without adjacent values, the signedness of the resulting infinity is not
#clear.

#special case:
@test isequal(left_zero_exact / left_zero_exact, UT(NaN))                       #[0, 1] / [0, 1]  == NaN
#if you want ops to throw infinities, do it by intercepting your function (eg pow(x, [even int]))
#CHART ONE
#top row.
@test isequal(left_zero_exact / right_zero_exact, UT(NaN))                      #[0, 1] / 0       == NaN
@test left_zero_exact / right_ulp            == Ubound(UT(0), UT(1))            #[0, 1] / [1, 2)  == [0, 1]
@test left_zero_exact / right_exact          == Ubound(UT(0), UT(1))            #[0, 1] / [1, 2]  == [0, 1]
@test left_zero_exact / right_posmmr_b       == Ubound(UT(0), UT(1))            #[0, 1] / [1, ∞)  == [0, 1]
@test left_zero_exact / right_posinf         == Ubound(UT(0), UT(1))            #[0, 1] / [1, ∞]  == [0, 1]
################################################################################
#second row
@test isequal(left_zero_ulp_b / right_zero_exact, UT(NaN))                      #(0, 1] / 0       == NaN
@test left_zero_ulp_b / right_ulp            == Ubound(sss(UT), UT(1))          #(0, 1] / [1, 2)  == (0, 1]
@test left_zero_ulp_b / right_exact          == Ubound(sss(UT), UT(1))          #(0, 1] / [1, 2]  == (0, 1]
@test left_zero_ulp_b / right_posmmr_b       == Ubound(sss(UT), UT(1))          #(0, 1] / [1, ∞)  == (0, 1]
@test left_zero_ulp_b / right_posinf         == Ubound(UT(0), UT(1))            #(0, 1] / [1, ∞]  == [0, 1]
################################################################################
#third row
@test isequal(left_pos_exact / right_zero_exact, UT(NaN))                       #[1, 2] / 0       == NaN
@test left_pos_exact / right_ulp         == Ubound(outer_ulp!(UT(0.5)), UT(2))  #[1, 2] / [1, 2)  == (0.5, 2]
@test left_pos_exact / right_exact       == Ubound(UT(0.5), UT(2))              #[1, 2] / [1, 2]  == [0.5, 2]
@test left_pos_exact / right_posmmr_b    == Ubound(sss(UT), UT(2))              #[1, 2] / [1, ∞)  == (0, 2]
@test left_pos_exact / right_posinf      == Ubound(UT(0), UT(2))                #[1, 2] / [1, ∞]  == [0, 2]
################################################################################
#fourth row
@test isequal(left_pos_ulp / right_zero_exact, UT(NaN))                         #(1, 2] / 0       == NaN
@test left_pos_ulp / right_ulp            == Ubound(outer_ulp!(UT(0.5)), UT(2)) #(1, 2] / [1, 2)  == (0.5, 2]
@test left_pos_ulp / right_exact          == Ubound(outer_ulp!(UT(0.5)), UT(2)) #(1, 2] / [1, 2]  == (0.5, 2]
@test left_pos_ulp / right_posmmr_b       == Ubound(sss(UT), UT(2))             #(1, 2] / [1, ∞)  == (0, 2]
@test left_pos_ulp / right_posinf         == Ubound(UT(0), UT(2))               #(1, 2] / [1, ∞]  == [0, 2]
################################################################################
#fifith row
@test isequal(left_posinf / right_zero_exact, UT(NaN))                          # ∞ / 0       == NaN
@test left_posinf / right_ulp            == inf(UT)                             # ∞ / [1, 2)  == ∞
@test left_posinf / right_exact          == inf(UT)                             # ∞ / [1, 2]  == ∞
@test left_posinf / right_posmmr_b       == inf(UT)                             # ∞ / [1, ∞)  == ∞
@test isequal(left_posinf / right_posinf, nan(UT))                              # ∞ / [1, ∞]  == NaN
#CHART TWO is covered by chart one.
