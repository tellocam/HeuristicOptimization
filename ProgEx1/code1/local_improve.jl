include("ds.jl")
include("const.jl")
using Random
using StatsBase
using Graphs
using MHLib
using ArgParse

# Functionality of local_improve with other MHLib components was successful!!
# However, the flip we want to perform that actually improves the cost, does not happen.
# Why? Why?
function MHLib.Schedulers.local_improve!(G::SPSolution, par::Int, result::Result)
    for i in 1:G.n
        for j in i:G.n
            if G.A0[i,j] != G.A[i,j]
                valid = flipij!(G, i, j)
                if !valid
                    flipij!(G, i, j) # take back
                else
                    result.changed = true
                    return #first improvement strategy
                end
                # if the change was valid we have an improvement with certainty so keep it
            end
        end
    end
end

const splex_settings_cfg = ArgParseSettings()
@add_arg_table! splex_settings_cfg begin
    "--splex"
        help = "none, only bc copied from demo"
        arg_type = Int
        default = 3
end

function solve_splex(args=ARGS)
    println("splex problem algo")

    # We set some new default values for parameters and parse all relevant arguments
    settings_new_default_value!(MHLib.Schedulers.settings_cfg, "mh_titer", 1000)
    settings_new_default_value!(MHLib.settings_cfg, "ifile", "datasets/inst_test/heur002_n_100_m_3274.txt")
    parse_settings!([MHLib.Schedulers.settings_cfg, splex_settings_cfg], args)
    println(get_settings_as_string())
        
    G = readSPSolutionFile(settings[:ifile])

    alg = GVNS(G, [MHMethod("con", construct!, 0)],
        [MHMethod("li1", local_improve!, 1)],[MHMethod("li1", local_improve!, 1)], 
        consider_initial_sol = true)
    run!(alg)
    method_statistics(alg.scheduler)
    main_results(alg.scheduler)
    check(G)
    return G
end



# Another approach: try to fuse clusters (quasi cliques) from the construction heuristic

function find_clusters(G::SPSolution)
    clusters = zeros(Int64, G.n)
    visited = zeros(Int64, G.n)
    cluster = 1
    for i in 1:G.n
        if visited[i] == 0
            in_cluster = connected_subgraph(G, i, false)
            clusters += cluster .* in_cluster # if in cluster this is 1 and ones get multiplied to cluster number 
            visited += in_cluster # we dont need to check these nodes later 
            cluster += 1
        end
    end
    return clusters
end

function fuse_cluster!(G::SPSolution, clusters, i, j, modify::Bool) #try to fuse cluster number i and its successor, returns improvement via delta eval
    #TODO: check if i!=j and if i and j are smaller than max(clusters)
    in_i = zeros(Bool, G.n)
    in_j = zeros(Bool, G.n)
    for k in 1:G.n
        if clusters[k] == i 
            in_i[k] = 1
        elseif clusters[k] == j
            in_j[k] = 1
        end
    end
    added_cost = 0
    # fully connect the 2 clusters
    for i in 1:G.n
        if in_i[i]
            for j in 1:G.n
                if in_j[j]
                    flipcost = (-2 * G.A0[min(i,j),max(i,j)] + 1) * G.W[min(i,j),max(i,j)]
                    added_cost += flipcost
                    if modify
                        G.A[min(i,j),max(i,j)] = 1
                        G.obj_val += flipcost
                    end
                end
            end
        end
    end
    # take out the unnecessary connections
    #TODO: do some kind of local search here, not only delete the edges by node numbering order
    #TODO: also calculate for the non modify case, this can change everything because fuses will be legal that werent before
    if modify
        for i in 1:G.n
            if in_i[i]
                for j in 1:G.n
                    if in_j[j]
                        if G.A0[min(i,j),max(i,j)] == 0
                            added_cost -= G.W[min(i,j),max(i,j)]
                            G.obj_val -= G.W[min(i,j),max(i,j)]
                            flipij!(G, min(i,j), max(i,j))
                        end
                    end
                end
            end
        end
    end
    return added_cost
end

function fuse_first!(G::SPSolution)::Bool
    clusters = find_clusters(G)
    nr_clusters = maximum(clusters)
    for i in 1:(nr_clusters-1)
        for j in 1:(nr_clusters-1)
            added_cost = fuse_cluster!(G, clusters, i, j, false)
            if added_cost < 0
                fuse_cluster!(G, clusters, i, j, true)
                return true
            end
        end
    end
    return false
end


function fuse_best!(G::SPSolution)::Bool
    changed = false
    clusters = find_clusters(G)
    nr_clusters = maximum(clusters)
    added_costs = zeros(Int64, nr_clusters, nr_clusters)
    for i in 1:(nr_clusters-1)
        for j in 1:(nr_clusters-1)
            added_costs[i, j] = fuse_cluster!(G, clusters, i, j, false)
        end
    end
    best_cluster = argmin(added_costs)
    if added_costs[best_cluster] < 0
        fuse_cluster!(G, clusters, best_cluster[1], best_cluster[2], true)
        changed = true
    end
    return changed
end

function fuse_to_max!(G::SPSolution, best::Bool) # true for best false for first improvement
    if best
        fct = fuse_best!
    else
        fct = fuse_first!
    end
    changed = true
    while changed
        changed = fct(G)
    end
end