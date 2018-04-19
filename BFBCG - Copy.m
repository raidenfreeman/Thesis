function result = BFBCG(A, Xcurrent, gg, tol, maxit, Rcurrent)
    # initialization
    #Rcurrent = B - A*Xcurrent;
    Zcurrent = gg;
    Pcurrent = orth(Zcurrent);
    fprintf("\nRANK:\t%d",rank(Rcurrent,tol))
    fprintf("\nNORM column1:\t%1.8f",norm(Rcurrent(:,1)))
    fprintf("\nNORM column2:\t%1.8f\n=============",norm(Rcurrent(:,2)))

    Xnext = ones(size(Xcurrent))
    # iterative method
    for i = 0:maxit
        Q = A*Pcurrent;
        acurrent =  (Pcurrent' * Q)\(Pcurrent'*Rcurrent);
        Xnext = Xcurrent+Pcurrent*acurrent;
        Rnext = Rcurrent-Q*acurrent;
        # if Residual norm of columns in Rcurrent < tol, stop
        if norm(Rcurrent(:,1)) < tol && norm(Rcurrent(:,2)) < tol
            fprintf("\nRANK:\t%d",rank(Rcurrent,tol))
            fprintf("\nNORM column1:\t%1.20f",norm(Rcurrent(:,1)))
            fprintf("\nNORM column2:\t%1.20f\n=============",norm(Rcurrent(:,2)))
            break
        endif
        Znext = M*Rnext;
        bcurrent = -(Pcurrent' * Q)\(Q'*Znext);
        Pnext = orth(Znext+Pcurrent*bcurrent);

        Xcurrent = Xnext;
        Zcurrent = Znext;
        Rcurrent = Rnext;
        Pcurrent = Pnext;
        fprintf("\nRANK:\t%d",rank(Rcurrent,tol))
        fprintf("\nNORM column1:\t%1.8f",norm(Rcurrent(:,1)))
        fprintf("\nNORM column2:\t%1.8f\n=============",norm(Rcurrent(:,2)))
    endfor
    result = Xnext;
endfunction

# BFBCG(A,guess,M,tol,1000,R0)