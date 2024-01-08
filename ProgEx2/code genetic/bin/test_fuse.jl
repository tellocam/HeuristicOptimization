include("../src/move_ops.jl")
include("../src/metaheuristics.jl")

G = readSPSolutionFile("../data/datasets/inst_test/heur005_n_160_m_4015.txt")
G2 = readSPSolutionFile("../data/datasets/inst_test/heur005_n_160_m_4015.txt")

function dum()
    det_const!(G, 100)
    det_const!(G2, 100)
    clusters = find_clusters(G)
    clusters2 = find_clusters(G2)
    for i in 1:10
        for j in 1:10
            added_cost1 = fuse_cluster!(G, find_clusters(G), i, j, false)
            if added_cost1 < 0
                fuse_cluster!(G, find_clusters(G), i, j, true)
            end
            added_cost2 = fuse_cluster2!(G2, find_clusters(G2), i, j)
            if added_cost1 != added_cost2
                println("we have a problem here $added_cost1 $added_cost2")
            end
        end
    end

    writeAdjacency(G,"test_good.txt", false)
    writeAdjacency(G2,"test_bad.txt", false)
    println("old version $(calc_objective(G)), $(is_splex(G,false))")
    println("new version $(calc_objective(G2)), $(is_splex(G2,false))")
end

dum()
