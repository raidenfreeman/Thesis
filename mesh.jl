using Plots
pyplot(leg=false, ticks=nothing)
x = y = linspace(-5, 5, 40)
zs = zeros(0,40)

@gif for i in linspace(0, 2π, 100)
    f(x,y) = sin(x + 10sin(i)) + cos(y)

    # create a plot with 3 subplots and a custom layout
    l = @layout [a{0.7w} b; c{0.2h}]
    p = plot(x, y, f, st = [:surface, :contourf], layout=l)

    # add a tracking line
    fixed_x = zeros(40)
    z = map(f,fixed_x,y)
    plot!(p[1], fixed_x, y, z, line = (:black, 5, 0.2))
    vline!(p[2], [0], line = (:black, 5))

    # add to and show the tracked values over time
    zs = vcat(zs, z')
    plot!(p[3], zs, alpha = 0.2, palette = cgrad(:blues).colors)
end

display(p)
