using Plots
filepath = "./comparison/matlabdata.dat"
A = readdlm(filepath)
x = A[:,1]
y = A[:,2]
# display(plot(A[:,1],A[:,2]))
display(
  plot(x,
  y,
  size=(800,800),
  ticks=[n for n=-6:6],
  line = (:line,:solid, :arrow, 0.5, 4, :teal),
  xlabel = "x",
  ylabel = "x sin(x^2)",
  title="f(x) = x sin(x^2)",
  lw=3)
 )
png("./comparison/matlabdata")
