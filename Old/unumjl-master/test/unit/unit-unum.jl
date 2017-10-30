#unit-unum.jl

#test that the Unum pseudo-constructor bifurcates the actual construction to
#"UnumSmall" and "UnumLarge" types
small_typetest = Unum{4,6}(z64, z64, z16, z16, z16)
large_typetest = Unum{4,7}(z64, [z64, z64], z16, z16, z16)

@test isa(small_typetest, Unum{4,6})
@test isa(small_typetest, Unums.UnumSmall{4,6})
@test isa(large_typetest, Unum{4,7})
@test isa(large_typetest, Unums.UnumLarge{4,7})

#test that passing through the Unum copy constructor is valid.
small_typetest_prime = Unum{4,6}(small_typetest)
large_typetest_prime = Unum{4,7}(large_typetest)
@test isa(small_typetest_prime, Unum{4,6})
@test isa(small_typetest_prime, Unums.UnumSmall{4,6})
@test isa(large_typetest_prime, Unum{4,7})
@test isa(large_typetest_prime, Unums.UnumLarge{4,7})

#test that passing strange data types fails.
@test_throws MethodError Unum{4,6}(z16, [z64, z64], z16, z16, z16)
@test_throws MethodError Unum{4,7}(z16, z64, z16, z16, z16)
@test_throws MethodError Unum{4,8}(z16, [z64, z64], z16, z16, z16)

#cascading tests on the general unum checking procedure.
@test_throws ArgumentError Unums.__general_unum_check(7, 0, z64, z16, z16)          #ESS too big.
@test_throws ArgumentError Unums.__general_unum_check(6, 12, z64, z16, z16)         #FSS too big.
@test_throws ArgumentError Unums.__general_unum_check(0, 0, z64, z16, o16)          #fsize too big
@test_throws ArgumentError Unums.__general_unum_check(0, 11, z64, z16, UInt16(2048)) #fsize too big
@test_throws ArgumentError Unums.__general_unum_check(0, 0, z64, o16, z16)          #esize too big
@test_throws ArgumentError Unums.__general_unum_check(6, 0, z64, UInt16(64), z16)   #esize too big
@test_throws ArgumentError Unums.__general_unum_check(0, 0, UInt64(2), z16, z16)    #exponent too big

#actual tests on constructors using the safe unum constructor.
#test that fsize error gets thrown.
@test_throws ArgumentError Unum{0,0}(z64, z64, z16, z16, o16)
#test that esize error gets thrown
@test_throws ArgumentError Unum{0,0}(z64, z64, z16, o16, z16)
#test that exponent error gets thrown
@test_throws ArgumentError Unum{0,0}(UInt64(2), z64, z16, z16, z16)
#test that the fraction error gets thrown
@test_throws ArgumentError Unum{0,0}(z64, [z64, z64], z16, z16, z16)
@test_throws ArgumentError Unum{0,8}(z64, z64, z16, z16, z16)

#make sure that the constructor doesn't trim fractions that aren't too long.
warlpiri_one = Unum{0,0}(z64, t64, z16, z16, z16)
@test warlpiri_one.fraction == t64
@test warlpiri_one.fsize == z16
@test warlpiri_one.flags == z16

#test that the constructor correctly trims fractions that are too long.
warlpiri_some = Unum{0,0}(z64, f64, z16, z16, z16)
@test warlpiri_some.fraction == t64
@test warlpiri_some.fsize == z16
@test warlpiri_some.flags & Unums.UNUM_UBIT_MASK == Unums.UNUM_UBIT_MASK

#test the same thing in a really big number.
bigunum_trim1 = Unum{4,7}(z64, [z64, t64], z16, z16, UInt16(63))
@test bigunum_trim1.fraction.a == [z64, z64]
@test bigunum_trim1.fsize == 63
@test bigunum_trim1.flags & Unums.UNUM_UBIT_MASK == Unums.UNUM_UBIT_MASK


#test the unum_easy constructor
easy_warlpiri_two = unum(Unum{0,0}, 1, z64, z16)
@test easy_warlpiri_two.exponent == o64
@test easy_warlpiri_two.fraction == z64
@test easy_warlpiri_two.fsize == z16
@test easy_warlpiri_two.flags == z16

@devmode_on begin
  #test to see that these unsafe constructors fail.
  @test_throws ArgumentError Unums.UnumSmall{0,0}(      z64, z64, z16, z16, o16)
  @test_throws ArgumentError Unums.UnumSmall{0,0}(      z64, z64, z16, o16, z16)
  @test_throws ArgumentError Unums.UnumSmall{0,0}(UInt64(2), z64, z16, z16, o16)
  #we can even create an unsafe type
  @test_throws ArgumentError Unums.UnumSmall{4,8}(z64, z64, z16, z16, z16)

  #repeat the test in a high unum environment.
  @test_throws ArgumentError Unums.UnumLarge{4,8}(      z64, Unums.ArrayNum{8}([z64, z64, z64, z64]), z16, z16, UInt16(256))
  @test_throws ArgumentError Unums.UnumLarge{4,8}(      z64, Unums.ArrayNum{8}([z64, z64, z64, z64]), z16, UInt16(16), z16)
  @test_throws ArgumentError Unums.UnumLarge{4,8}(UInt64(2), Unums.ArrayNum{8}([z64, z64, z64, z64]), z16, z16, z16)
end

@devmode_off begin
  #unsafe unums can be created using the unsafe constructor.
  unsafe_fsize = Unums.UnumSmall{0,0}(z64, z64, z16, z16, o16)
  @test unsafe_fsize.fsize == o16
  unsafe_esize = Unums.UnumSmall{0,0}(z64, z64, z16, o16, z16)
  @test unsafe_esize.esize == o16
  unsafe_exponent = Unums.UnumSmall{0,0}(UInt64(2), z64, z16, o16, z16)
  @test unsafe_exponent.exponent == UInt64(2)
  #we can even create an unsafe type
  unsafe_type = Unums.UnumSmall{4,8}(z64, z64, z16, z16, z16)

  #then show that these trigger TypeErrors when passed through the safe constructor
  @test_throws ArgumentError unum(unsafe_fsize)
  @test_throws ArgumentError unum(unsafe_esize)
  @test_throws ArgumentError unum(unsafe_exponent)
  @test_throws MethodError unum(unsafe_type)

  #repeat the test in a high unum environment.
  unsafe_fsize = Unums.UnumLarge{4,8}(z64, Unums.ArrayNum{8}([z64, z64, z64, z64]), z16, z16, UInt16(256))
  @test unsafe_fsize.fsize == UInt16(256)
  unsafe_esize = Unums.UnumLarge{4,8}(z64, Unums.ArrayNum{8}([z64, z64, z64, z64]), z16, UInt16(16), z16)
  @test unsafe_esize.esize == UInt16(16)
  unsafe_fraction = Unums.UnumLarge{4,8}(z64, Unums.ArrayNum{8}([z64, z64]), z16, z16, z16)
  @test unsafe_fraction.fraction.a == [z64, z64]
  unsafe_exponent = Unums.UnumLarge{4,8}(UInt64(2), Unums.ArrayNum{8}([z64, z64, z64, z64]), z16, z16, z16)
  @test unsafe_exponent.exponent == UInt16(2)
  unsafe_type = Unums.UnumLarge{0,0}(z64, Unums.ArrayNum{0}([z64, z64, z64, z64]), z16, z16, z16)

  @test_throws ArgumentError unum(unsafe_fsize)
  @test_throws ArgumentError unum(unsafe_esize)
  @test_throws MethodError   unum(unsafe_fraction)
  @test_throws ArgumentError unum(unsafe_exponent)
  @test_throws MethodError   unum(unsafe_type)
end
