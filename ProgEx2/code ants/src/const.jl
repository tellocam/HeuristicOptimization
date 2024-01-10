using LinearAlgebra
using Random

"function that constructs a solution deterministically with highest cost edges that are present initially"
function det_const!(G::SPSolution, init_cluster_size) # deterministic construction of s-plexes from empty graph
    initialize!(G)
    for i in 1:G.n
        count = 0
        for j in i:G.n
            if count > init_cluster_size
                break 
            end
            if G.A0[i,j]
                count += 1
                obj_val_old = G.obj_val
                valid = flipij!(G, i, j)
                if !(valid && G.obj_val < obj_val_old)
                    #flip was illegal, take back
                    flipij!(G, i, j)
                    count -= 1
                end
            end
        end
    end
end

function rd_const!(G::SPSolution, init_cluster_size) # random construction of s-plexes from empty graph
    initialize!(G)
    for i in shuffle(1:G.n)
        count = 0
        for j in shuffle(i:G.n)
            if count > init_cluster_size
                break 
            end
            if G.A0[i,j]
                count += 1
                obj_val_old = G.obj_val
                valid = flipij!(G, i, j)
                if !(valid && G.obj_val < obj_val_old)
                    #flip was illegal, take back
                    flipij!(G, i, j)
                    count -= 1
                end
            end
        end
    end
end

function MHLib.Schedulers.construct!(G::SPSolution, par::Int, result::Result)
    if par == 0
        det_const!(G, 100)
        return
    end
    if par == 1
        rd_const!(G, 100)
        return
    end
    error("invalid parameter to construct!")
end
