include("ds.jl")
using LinearAlgebra
using Random




function det_constr(G::SPSolution) # deterministic construction of s-plexes from empty graph
    initialize!(G)
    for i in 1:G.n
        for j in i:G.n
            if G.A0[i,j]
                obj_val_old = G.obj_val
                flipij(G, i, j)
                if !(G.obj_val_valid && G.obj_val < obj_val_old)
                    #flip was illegal, take back
                    flipij(G, i, j)
                    G.obj_val_valid = true
                end
            end
        end
    end
    return G
end

function rand_constr(G::SPSolution)
    initialize!(G)
    for i in randcycle(G.n)
        for j in i:G.n
            if G.A0[i,j]
                obj_val_old = G.obj_val
                flipij(G, i, j)
                if !(G.obj_val_valid && G.obj_val < obj_val_old)
                    #flip was illegal, take back
                    flipij(G, i, j)
                    G.obj_val_valid = true
                end
            end
        end
    end
    return G
end



G_test = readSPSolutionFile(file_path)
display(G_test.A)
det_constr(G_test)
println("det constr: obj_val= $(G_test.obj_val) and matrix is:")
display(G_test.A)
for i in 1:5
    rand_constr(G_test)
    println("rand constr: obj_val= $(G_test.obj_val) and matrix is:")
    display(G_test.A)
end