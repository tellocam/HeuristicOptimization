include("ds.jl")
using LinearAlgebra
using Random




function det_const(G::SPSolution) # deterministic construction of s-plexes from empty graph
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

function MHLib.Schedulers.construct!(G::SPSolution, par::Int, result::Result)
    if par == 0
        det_const(G)
        return
    end
    if par == 1
        rand_constr(G)
        return
    end
    error("invalid parameter to construct!")
end
