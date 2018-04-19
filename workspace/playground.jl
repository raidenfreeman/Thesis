function prettyprint(a, cnames, rnames="",digits=8, decimals=4)
    # TBD: try to use this to allow using specified digits and decimals
    #fmt = @sprintf("%d",digits)"."@sprintf("%d",decimals)"%f"
    #@eval dofmt(x) = @sprintf($fmt, x)

    # print column names
    for i = 1:size(a,2)
        pad = digits
        if rnames != "" && i==1
            pad = 2*digits
        end
        @printf("%s", lpad(cnames[i],pad," "))
    end
    @printf("\n")
    # print the rows
    for i = 1:size(a,1)
        if rnames != ""
            @printf("%s", lpad(rnames[i],digits," "))
        end
        for j = 1:size(a,2)
            # TBD: use fmt defined above to print array contents
            @printf("%8.4f",(a[i,j]))
        end
        @printf("\n")
    end
end

"""
orth(M)

Compute an orthogonal basis for matrix `A`.

Returns a matrix whose columns are the orthogonal vectors that constitute a basis for the range of A.
If the matrix is square/invertible, returns the `U` factor of `svdfact(A)`, otherwise the first *r* columns of U, where *r* is the rank of the matrix.

In the paper (A breakdown-free block conjugate gradient method), page 7, it proposes QR decomposition; SVD was chosen to be more similar to the algorithm implemented in Matlab.

# Examples
```julia
julia> orth([1 8 12; 5 0 7])
2×2 Array{Float64,2}:
 -0.895625  -0.44481
 -0.44481    0.895625
```
```
julia> orth([1 8 12; 5 0 7 ; 6 4 1])
3×3 Array{Float64,2}:
 -0.856421   0.468442   0.217036
 -0.439069  -0.439714  -0.783498
 -0.27159   -0.766298   0.582259
```
"""
function orth(M::Matrix)
  matrixRank = rank(M)
  Ufactor = svdfact(M)[:U]
  return Ufactor[:,1:matrixRank]
end

function orth(M::Matrix, tol::Real)
  matrixRank = rank(M,tol)
  Ufactor = svdfact(M)[:U]
  return Ufactor[:,1:matrixRank]
end

"""
# Breakdown Free Block CG

### *From BIT Numerical Mathematics 2016 Ji[158]*

### ArgumentList
* `A`: Symmetric Positive Def. Matrix A n x n
* `B`: Matrix B n x s
* `Xcurrent`: Initial guess n x s
* `M`: preconditioner n x n
* `tol`: tolerance (to compare against the norm of the residual matrix) Real Number
* `maxit`: maximum number of iterations Number
* `Rcurrent`: used instead of B, as in the paper's numerical results

Returns: an approximate solution `Xsol` n x s
"""
function BFBCG(A::Matrix, Xcurrent::Matrix, M::Matrix, tol::Number, maxit::Number, Rcurrent::Matrix)#,B)
    # initialization
    #Rcurrent = B - A*Xcurrent;
    Zcurrent = M*Rcurrent;
    Pcurrent = orth(Zcurrent,tol);
    @printf("\nRANK:\t%d",rank(Rcurrent,tol))
    @printf("\nNORM column1:\t%1.8f",vecnorm(Rcurrent[:,1]))
    @printf("\nNORM column2:\t%1.8f\n=============",vecnorm(Rcurrent[:,2]))

    Xnext::Matrix = ones(size(Xcurrent))
    # iterative method
    for i = 0:maxit
        Q = A*Pcurrent
        acurrent =  (Pcurrent' * Q)\(Pcurrent'*Rcurrent)
        Xnext = Xcurrent+Pcurrent*acurrent
        Rnext = Rcurrent-Q*acurrent
        # if Residual norm of columns in Rcurrent < tol, stop
        if vecnorm(Rcurrent[:,1]) < tol && vecnorm(Rcurrent[:,2]) < tol
            @printf("\nRANK:\t%d",rank(Rcurrent,tol))
            @printf("\nNORM column1:\t%1.20f",vecnorm(Rcurrent[:,1]))
            @printf("\nNORM column2:\t%1.20f\n=============",vecnorm(Rcurrent[:,2]))
            break
        end
        Znext = M*Rnext
        bcurrent = -(Pcurrent' * Q)\(Q'*Znext)
        Pnext = orth(Znext+Pcurrent*bcurrent,tol)

        Xcurrent = Xnext
        Zcurrent = Znext
        Rcurrent = Rnext
        Pcurrent = Pnext
        @printf("\nRANK:\t%d",rank(Rcurrent,tol))
        @printf("\nNORM column1:\t%1.8f",vecnorm(Rcurrent[:,1]))
        @printf("\nNORM column2:\t%1.8f\n=============",vecnorm(Rcurrent[:,2]))
    end
    return Xnext
end

A = [15 5 4 3 2 1; 5 35 9 8 7 6; 4 9 46 12 11 10; 3 8 12 50 14 13; 2 7 11 14 19 15; 1 6 10 13 15 45]
M = eye(6)

guess = ones(6,2) #rand(6,2)

R0 = [1 0.537266261211281;2 0.043775211060964;3 0.964458562037146;4 0.622317517840541;5 0.552735938776748;6 0.023323943544997]

R0_2 = [1 10; 2 20; 3 30; 4 40; 5 50; 6 60]

R0_3= [1 0.027212780358615; 2 0.117544343373396; 3 0.140184539179715; 4 0.605659566833592; 5 0.323269030695212; 6 0.590821508384101]

R0_4= [1 -8.888614458250306; 2 -10.999025290685955; 3 -19.339674247091921; 4 -10.289152668326622; 5 18.107579559267656; 6 -8.930794511222629]

tol = 10^(-7.0);

@printf("Case 1\n\tThe residual matrix Ri without rank deficiency")
X = BFBCG(A,guess,M,tol,1000,R0)

@printf("\nCase 2\n\tThe residual matrix Ri with rank deficiency")
X = BFBCG(A,guess,M,tol,9,R0_2)

@printf("\nCase 3\n\tThe residual matrix Ri with rank deficiency")
X = BFBCG(A,guess,M,tol,9,R0_3)

@printf("\nCase 4\n\tThe residual matrix Ri with rank deficiency")
X = BFBCG(A,guess,M,tol,9,R0_4)
