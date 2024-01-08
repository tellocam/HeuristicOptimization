include("ds.jl")
using LinearAlgebra
using Random




function rd_const!(G::SPSolution)
    initialize!(G)
    used = zeros(Bool, G.n)
    for i in shuffle(1:G.n)
        if used[i]
            continue
        end
        used[i] = true
        added = 0
        for j in shuffle(i:G.n)
            if G.A0[i,j] && !used[j]
                G.A[i,j] = 1
                added += 1
                used[j] = true
                if added == G.s
                    break
                end
            end
        end
        #= decided against this even though it makes performance of subsequent fuse better
        if added < G.s # make G.s sized splexes even though cost gos up
            for j in 1:G.n
                if !used[j]
                    G.A[i,j] = 1
                    added += 1
                    if added == G.s
                        break
                    end
                end
            end
        end
        =#
    end
end








# OBSOLETE STUFF
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