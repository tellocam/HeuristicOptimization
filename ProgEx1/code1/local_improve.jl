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
    cluster = 1
    for i in 1:G.n
        empty = true
        for j in i:G.n
            if G.A[i,j] == 1
                empty = false
                clusters[i] = cluster
                break
            end
        end
        if empty
            clusters[i] = cluster
            cluster += 1
        end
    end
    return clusters
end

function fuse_cluster_cost(G::SPSolution, clusters, i) #try to fuse cluster number i and its successor, returns improvement via delta eval
    if i == last(clusters)
        return 0 #last cluster cannot be fused
    end
    start_i = findfirst(isequal(i), clusters) #finds first node in cluster i
    start_ip = findfirst(isequal(i+1), clusters) #finds first node in cluster i+1
    fin_ip = findfirst(isequal(i+2),clusters)
    if typeof(fin_ip) == Nothing
        fin_ip = G.n# if i+1 is the last cluster
    else
        fin_ip -= 1 #last element of cluster i+1
    end
    change_id_x1 = start_i
    change_id_x2 = start_ip - 1
    change_id_y1 = start_ip
    change_id_y2 = fin_ip
    relevant_edges = G.A0[change_id_x1:change_id_x2, change_id_y1:change_id_y2]
    relevant_weights = G.W[change_id_x1:change_id_x2, change_id_y1:change_id_y2]
    added_cost = sum(.!(relevant_edges) .* relevant_weights) - sum(relevant_edges .* relevant_weights)
    return added_cost
end

function fuse_cluster!(G::SPSolution, clusters, i) #TODO: unify copy pasted stuff from fuse_cluster_cost
    if i == last(clusters)
        return #last cluster cannot be fused
    end
    start_i = findfirst(isequal(i), clusters) #finds first node in cluster i
    start_ip = findfirst(isequal(i+1), clusters) #finds first node in cluster i+1
    fin_ip = findfirst(isequal(i+2),clusters)
    if typeof(fin_ip) == Nothing
        fin_ip = G.n# if i+1 is the last cluster
    else
        fin_ip -= 1 #last element of cluster i+1
    end
    change_id_x1 = start_i
    change_id_x2 = start_ip - 1
    change_id_y1 = start_ip
    change_id_y2 = fin_ip
    G.obj_val += fuse_cluster_cost(G, clusters, i)
    G.A[change_id_x1:change_id_x2, change_id_y1:change_id_y2] = ones(Bool, change_id_x2-change_id_x1+1, change_id_y2-change_id_y1+1)
end

function fuse_best!(G::SPSolution)
    changed = false
    clusters = find_clusters(G)
    nr_clusters = last(clusters)
    added_costs = zeros(Int64, nr_clusters)
    for i in 1:nr_clusters-1
        added_costs[i] = fuse_cluster_cost(G, clusters, i)
    end
    best_cluster = argmin(added_costs)
    if added_costs[best_cluster] < 0
        fuse_cluster!(G, clusters, best_cluster)
        changed = true
    end
    return changed
end

function fuse_to_max!(G::SPSolution)
    changed = true
    while changed
        changed = fuse_best!(G)
    end
end