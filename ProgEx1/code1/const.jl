include("ds.jl")
using LinearAlgebra
using Random

#TODO: one can stop in a row, when one has found s n's because this heuristic can only find up to 
# s n's in one row, then the corresponding node is connected to s others who each have degree 1, which
# makes the cluster an s-plex and no node can be added. stopping at the s_th found one improves performance
# a bit but not much. maybe its even better to stop earlier to have only "local cliques" in the constructed
# first solution (especially in combination with the fuse methods later)


function det_const!(G::SPSolution, init_cluster_size) # deterministic construction of s-plexes from empty graph
    initialize!(G)
    check
    for i in 1:G.n
        count = 0
        for j in i:G.n
            if count > init_cluster_size
                break 
            end
            if G.A0[i,j]
                count += 1
                obj_val_old = G.obj_val
                flipij!(G, i, j)
                if !(G.obj_val_valid && G.obj_val < obj_val_old)
                    #flip was illegal, take back
                    flipij!(G, i, j)
                    G.obj_val_valid = true
                    count -= 1
                end
            end
        end
    end
    return G
end

function rand_constr!(G::SPSolution)
    initialize!(G)
    for i in randcycle(G.n)
        for j in i:G.n
            if G.A0[i,j]
                obj_val_old = G.obj_val
                flipij!(G, i, j)
                if !(G.obj_val_valid && G.obj_val < obj_val_old)
                    #flip was illegal, take back
                    flipij!(G, i, j)
                    G.obj_val_valid = true
                end
            end
        end
    end
    return G
end

function MHLib.Schedulers.construct!(G::SPSolution, par::Int, result::Result)
    if par == 0
        det_const!(G)
        return
    end
    if par == 1
        rand_constr!(G)
        return
    end
    error("invalid parameter to construct!")
end
