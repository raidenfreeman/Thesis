using PyPlot
using Distributions

###################
##  Create Data  ##
###################
n = 100
x = linspace(-3, 3, n)
y = linspace(-3,3,n)

xgrid = repmat(x',n,1)
ygrid = repmat(y,1,n)

z = zeros(n,n)

for i in 1:n
    for j in 1:n
        z[i:i,j:j] = pdf(MvNormal(eye(2)),[x[i];y[j]])
    end
end

############
##  Plot  ##
############
fig = figure("pyplot_surfaceplot",figsize=(20,10))
ax = fig[:add_subplot](1,1,1, projection = "3d")
ax[:plot_surface](xgrid, ygrid, z, rstride=2,edgecolors="k", cstride=2, cmap=ColorMap("gray"), alpha=0.8, linewidth=0.25)
xlabel("X")
ylabel("Y")
title("Surface Plot")
show()

# subplot(212)
# ax = fig[:add_subplot](2,1,2)
# cp = ax[:contour](xgrid, ygrid, z, colors="black", linewidth=2.0)
# ax[:clabel](cp, inline=1, fontsize=10)
# xlabel("X")
# ylabel("Y")
# title("Contour Plot")
# tight_layout()
# show()
