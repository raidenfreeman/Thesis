using Plots
filepath = "./comparison/matlabdata.dat"
A = readdlm(filepath)
display(plot(A[:,1],A[:,2]))
png("./comparison/matlabdata")
