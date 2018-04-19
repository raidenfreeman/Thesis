using MatrixDepot

function getMatrices()
    println(matrixdepot("HB/bcsstk28", :get))
end
MatrixDepot.update()
#getMatrices()
matrixdepot("SNAP/web-Google", :get)
