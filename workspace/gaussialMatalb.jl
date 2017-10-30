function setupA(N)
    I = speye(N)
    s = [-1*ones(1,N-1) 2*ones(1,N) -1*ones(1,N-1)]'
    i = [2:N 1:N 1:N-1]'
    j = [1:N-1 1:N 2:N ]'
    T = sparse(i,j,s)
    return kron(I,T) + kron(T,I)
end

function driver_ge(N)
    h = 1 / (N+1)
    x = [h : h : 1-h]
    y = x
    [X, Y] = ndgrid(x,y)
    F = (-2*pi^2) * (cos(2*pi*X).*(sin(pi*Y)).^2 + (sin(pi*X)).^2.*cos(2*pi*Y))
    b = h^2 * F(:)

    @elapsed calculation(N,b)
end

function calculation(N, b)
    A = setupA(N)
    u = A \ b
    Uint = reshape(u, [N N]) % N.B.: Uint has only solutions on interior points
    # timesec = toc
    # append boundary to x, y, and to U:
    x = [0 x 1]
    y = [0 y 1]
    [X, Y] = ndgrid(x,y)
    U = zeros(size(X))
    U(2:end-1,2:end-1) = Uint
    # plot numerical solution:
    figure
    H = mesh(X,Y,U) # for Matlab and Octave
    xlabel("x")
    ylabel("y")
    zlabel("u")
    # compute and plot numerical error:
    Utrue = (sin(pi*X)).^2 .* (sin(pi*Y)).^2
    E = U - Utrue
    figure
    H = mesh(X,Y,E) # for Matlab and Octave
    #plot3(X,Y,E) # for FreeMat
    # xlabel("x")
    # ylabel("y")
    # zlabel("u-u_h")
    # compute L^inf norm of error and print:
    enorminf = max(abs(E(:)))
    # fprintf("N = %5d\n", N)
    # fprintf("h = %24.16e\n", h)
    # fprintf("h^2 = %24.16e\n", h^2)
    # fprintf("enorminf = %24.16e\n", enorminf)
    # fprintf("C = enorminf / h^2 = %24.16e\n", (enorminf/h^2))
    # fprintf("wall clock time = %10.2f seconds\n", timesec)
end
