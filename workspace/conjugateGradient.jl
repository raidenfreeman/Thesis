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

function Ax(u)
    N = sqrt(length(u));
    U = reshape(u, (N,N));
    V = 4 * U; # V_{ij} = 4 u_{ij} initialized
    V[:,2:end ] = V[:,2:end ] - U[:,1:end-1]; # V_{ij} -= u_{ij-1} accumulated
    V[2:end ,:] = V[2:end ,:] - U[1:end-1,:]; # V_{ij} -= u_{i-1j} accumulated
    V[1:end-1,:] = V[1:end-1,:] - U[2:end ,:]; # V_{ij} -= u_{i+1j} accumulated
    V[:,1:end-1] = V[:,1:end-1] - U[:,2:end ]; # V_{ij} -= u_{ij+1} accumulated
    V[:];
end

function driver_cg(N)
    h = 1 / (N+1);
    x = [h:h:1-h;];
    y = x;
    X, Y = ndgrid(x,y);
    F = (-2*pi^2) * (cos.(2*pi*X).*(sin.(pi*Y)).^2 + (sin.(pi*X)).^2.*cos.(2*pi*Y));
    b = h^2 * F[:];
    tic;
    u = zeros(N^2,1);
    cg!(u,A,b;tol=1.0e-6,maxiter =9999);
    Uint = reshape(u, (N, N));

    timesec = toc;
    # # append boundary to x, y, and to U:

    x = vcat([0], x, [1])
    y = vcat([0], y, [1])
    X, Y = ndgrid(x,y);
    U = zeros(size(X));
    U[2:end-1,2:end-1] = Uint;


    # plot numerical solution:
    # figure;
    # H = mesh(X,Y,U);
    # xlabel("x");
    # ylabel("y");
    # zlabel("u");
    # compute and plot numerical error:

    Utrue = (sin.(pi*X)).^2 .* (sin.(pi*Y)).^2;
    E = U - Utrue;

    # figure;
    # H = mesh(X,Y,E);
    # xlabel("x");
    # ylabel("y");
    # zlabel("u-u_h");
    # compute L^inf norm of error and print:

    enorminf = maximum(abs(E(:)));
    printf("N = %5d, tol = %10.1e, maxit = %d\n", N, tol, maxit);
    printf("h = %24.16e\n", h);
    printf("h^2 = %24.16e\n", h^2);
    printf("enorminf = %24.16e\n", enorminf);
    printf("C = enorminf / h^2 = %24.16e\n", (enorminf/h^2));
    printf("wall clock time = %10.2f seconds\n", timesec);
end
