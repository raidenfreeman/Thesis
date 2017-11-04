using PyPlot

function setupA(N)
    I = speye(N)
    s = vcat(squeeze(-1*ones(Int64,1,N-1),1),
            squeeze(2*ones(Int64,1,N),1),
            squeeze(-1*ones(Int64,1,N-1),1))
    i = vcat([n for n=2:N],[n for n=1:N],[n for n=1:N-1])
    j = vcat([n for n=1:N-1],[n for n=1:N],[n for n=2:N])
    T = sparse(i,j,s)
    return kron(I,T) + kron(T,I)
end

ndgrid(v::AbstractVector) = copy(v)

function ndgrid(v1::AbstractVector{T}, v2::AbstractVector{T}) where T
    m, n = length(v1), length(v2)
    v1 = reshape(v1, m, 1)
    v2 = reshape(v2, 1, n)
    (repmat(v1, 1, n), repmat(v2, m, 1))
end

function ndgrid_fill(a, v, s, snext)
    for j = 1:length(a)
        a[j] = v[div(rem(j-1, snext), s)+1]
    end
end

function ndgrid(vs::AbstractVector{T}...) where T
    n = length(vs)
    sz = map(length, vs)
    out = ntuple(i->Array{T}(sz), n)
    s = 1
    for i=1:n
        a = out[i]::Array
        v = vs[i]
        snext = s*size(a,i)
        ndgrid_fill(a, v, s, snext)
        s = snext
    end
    out
end

function driver_ge(N)
    h = 1 / (N+1);
    x = [h : h : 1-h;]
    y = x;
    X, Y = ndgrid(x,y)
    F = (-2*pi^2) * (cos.(2*pi*X).*(sin.(pi*Y)).^2 + (sin.(pi*X)).^2.*cos.(2*pi*Y))
    b = h^2 * F[:]
    X, Y , E = calculation(N,b,x ,y)

    fig = figure("pyplot_surfaceplot",figsize=(20,10))
    ax = fig[:add_subplot](1,1,1, projection = "3d")
    ax[:plot_surface](X, Y, E, rstride=2,edgecolors="k", cstride=2, cmap=ColorMap("gray"), alpha=0.8, linewidth=0.25)
    xlabel("X")
    ylabel("Y")
    title("Surface Plot")
    io = open(string("meshPlot_",N,".png"),"w");
    show(io, "image/png", fig)
    close(io)
end


function calculation(N, b, x, y)
    A = setupA(N)
    u = A \ b
    Uint = reshape(u, (N,N)) # N.B.: Uint has only solutions on interior points
    x = vcat([0], x, [1])
    y = vcat([0], y, [1])
    X, Y = ndgrid(x,y)
    U = zeros(size(X))
    U[2:end-1,2:end-1] = Uint
    Utrue = (sin.(pi*X)).^2 .* (sin.(pi*Y)).^2
    E = U - Utrue
    return X, Y, E
end
