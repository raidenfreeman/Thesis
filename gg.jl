using Plots
pyplot()
# plotly()
x = 1:10; y = rand(10) # These are the plotting data
display(plot(x,y,xticks=x,yticks=y,line = (:line,:solid, :arrow, 0.5, 4, :red),xlabel = "my label",title="f(x) = x sin(x^2)",lw=3,marker=([:circle :d],4,0.8,stroke(3,:gray))))
