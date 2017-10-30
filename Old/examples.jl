function f(n::Number)
  for i = 0:1000000000
    n = n+1
  end
  n
end

@time f(3)

@time f(3)
