include("ds.jl")
#include("const.jl")
using Random
using StatsBase
using Graphs
using MHLib
using ArgParse



#### FUSE OPERATION ####

#try to fuse clusters (quasi cliques) from the construction heuristic

function find_clusters(G::SPSolution)
    clusters = zeros(Int64, G.n)
    visited = zeros(Int64, G.n)
    cluster = 1
    for i in 1:G.n
        if visited[i] == 0
            in_cluster = cluster_list(G, i, false)
            clusters += cluster .* in_cluster # if in cluster this is 1 and ones get multiplied to cluster number 
            visited += in_cluster # we dont need to check these nodes later 
            cluster += 1
        end
    end
    return clusters
end




#second version for 2nd project, the first version was stupid (borderline insane)
function fuse_cluster!(G::SPSolution, clusters, i, j) #try to fuse cluster number i and j, returns improvement
    in_i = Int[]
    in_j = Int[]
    AC = copy(G.A)
    for k in 1:G.n
        if clusters[k] == i 
            push!(in_i, k)
        elseif clusters[k] == j
            push!(in_j, k)
        end
    end
    added_cost = 0
    # fully connect the 2 clusters
    for nodei in in_i
        for nodej in in_j
            AC[min(nodei,nodej),max(nodei,nodej)] = 1
            added_cost += (2 * (G.A0[min(nodei,nodej),max(nodei,nodej)] == 0) - 1) * G.W[min(nodei,nodej),max(nodei,nodej)]
        end
    end
    if added_cost < 0
        G.A = AC 
    end
    return added_cost
end

function fuse_first!(G::SPSolution)::Bool
    clusters = find_clusters(G)
    nr_clusters = maximum(clusters)
    for i in 1:nr_clusters
        for j in i:nr_clusters
            added_cost = fuse_cluster!(G, clusters, i, j)
            if added_cost < 0
                return true
            end
        end
    end
    return false
end



function fuse_rd!(G::SPSolution, clusters)
    nr_clusters = maximum(clusters)
    for i in shuffle(1:nr_clusters)
        for j in shuffle(i+1:nr_clusters)
            added_cost = fuse_cluster!(G, clusters, i, j)
            if added_cost < 0
                for k in 1:G.n
                    if clusters[k] == j
                        clusters[k] = i 
                    end
                end
                return clusters, true
            end
        end
    end
    return clusters, false
end







#### CLIQUIFY THEN SPARSEN OPERATION ####

function cliquify!(G::SPSolution)
    clusters = find_clusters(G)
    for node in 1:G.n
        my_cluster = clusters[node]
        for other in node+1:G.n
            if clusters[other] == my_cluster
                G.A[min(node,other),max(node,other)] = 1
            end
        end
    end
end


"""OLD
function sparsen!(G)
    if G.s == 1 #nothing to do, cant remove any edges
        return
    end
    n_deleted = zeros(G.n) #number of already deleted edges for each node
    #get list of indices of best to worst weight
    linear_indices = sortperm(G.W[:], rev=true)
    # Convert linear indices to Cartesian indices
    indices = CartesianIndices(size(G.W))[linear_indices]
    for index in indices
        if G.A0[index] == 0 && G.A[index] == 1 && n_deleted[index[1]] < G.s-1 && n_deleted[index[2]] < G.s-1
            G.A[index] = 0
            n_deleted[index[1]] += 1
            n_deleted[index[2]] += 1
        end
    end
end
"""

function sparsen!(G)
    if G.s == 1 #nothing to do, cant remove any edges

        return
    end
    n_deleted = zeros(G.n) #number of already deleted edges for each node
    for index in G.indices
        if G.A0[index] == 0 && G.A[index] == 1 && n_deleted[index[1]] < G.s-1 && n_deleted[index[2]] < G.s-1
            G.A[index] = 0
            n_deleted[index[1]] += 1
            n_deleted[index[2]] += 1
        end
    end
end


function cliquify_then_sparse!(G::SPSolution)
    cliquify!(G)
    sparsen!(G)
end


















#OBSOLETE STUFF:
#borderline insane stupid
function fuse_cluster_old!(G::SPSolution, clusters, i, j, modify::Bool) #try to fuse cluster number i and j, returns improvement
    in_i = zeros(Bool, G.n)
    in_j = zeros(Bool, G.n)
    AC = copy(G.A)
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
                    AC[min(i,j),max(i,j)] = 1
                end
            end
        end
    end
    added_cost = sum(G.W .* abs.(G.A0-AC)) - calc_objective(G)
    if modify
        G.A = AC 
    end
    return added_cost
end

function fuse_best!(G::SPSolution)::Bool
    changed = false
    clusters = find_clusters(G)
    nr_clusters = maximum(clusters)
    added_costs = zeros(Int64, nr_clusters, nr_clusters)
    for i in 1:nr_clusters
        for j in i:nr_clusters
            added_costs[i, j] = fuse_cluster_old!(G, clusters, i, j, false)
        end
    end
    best_cluster = argmin(added_costs)
    if added_costs[best_cluster] < 0
        fuse_cluster_old!(G, clusters, best_cluster[1], best_cluster[2], true)
        changed = true
    end
    return changed
end



#### SWAP OPERATION ####


function swap_node!(G::SPSolution, node, from, to, clusters, modify)
    old_val = calc_objective(G)
    #disconnect node
    save_col = copy(G.A[node,:])
    G.A[node,:] = zeros(Bool, G.n)
    save_row = copy(G.A[:,node])
    G.A[:,node] = zeros(Bool, G.n)
    rel_weights = zeros(Int8, G.n) # relevant weights for later 
    for other in 1:G.n
        if clusters[other] == to
            G.A[min(node, other),max(node, other)] = 1
        end
    end
    # check if we can remove edges
    rel_weights = copy(G.W[node, :])
    in_new_cluster = (clusters .== to)
    rel_weights = rel_weights .* in_new_cluster .* (G.A0[node, :] .== 0) # only these edges are interesting to change for other i
    deleted = sum(in_new_cluster) - deg(G.A, node) #should be 0 here
    while deleted < G.s #can only delete up to s-1 edges
        other = argmax(rel_weights)
        rel_weights[other] = 0
        if deg(G.A, other) > sum(in_new_cluster) - G.s
            G.A[node, other] = 0
            deleted += 1
        end
        if rel_weights[other] == 0 #no more potential edges
            break
        end
    end
    
    added_cost = calc_objective(G) - old_val

    if !modify
        G.A[node,:] = save_col
        G.A[:,node] = save_row
    end
    
    return added_cost
end





function swap_first!(G::SPSolution)
    clusters = find_clusters(G)
    clusters_u = unique(clusters)
    for node in 1:G.n
        my_cluster = clusters[node]
        for new_cluster in clusters_u
            if new_cluster != my_cluster
                improvement = swap_node!(G, node, my_cluster, new_cluster, clusters, false)
                if improvement < 0
                    swap_node!(G, node, my_cluster, new_cluster, clusters, true)
                    return true
                end
            end
        end
    end
    return false
end

function swap_best!(G::SPSolution)
    clusters = find_clusters(G)
    clusters_u = unique(clusters)
    improvements = zeros(Int, G.n, length(clusters_u))
    for node in 1:G.n
        my_cluster = clusters[node]
        for new_cluster in clusters_u
            if new_cluster != my_cluster
                improvements[node, new_cluster] = swap_node!(G, node, my_cluster, new_cluster, clusters, false)
            end
        end
    end
    best_swap = argmin(improvements)
    if improvements[best_swap] < 0
        swap_node!(G, best_swap[1], clusters[best_swap[1]], best_swap[2], clusters, true)
        return true
    end
    return false
end



#### SHAKING OPERATION ####


function disconnect_node!(G::SPSolution, node)
    G.A[node, :] = zeros(Bool, G.n)
    G.A[:, node] = zeros(Bool, G.n)
end

function disconnect_rd_n!(G::SPSolution, n)
    if n> G.n
        error("trying to do shaking with $n disc. nodes but only $(G.n) nodes in total")
    end
    perm = shuffle(1:G.n)
    nodes_to_disconnect = perm[1:n]
    for node in nodes_to_disconnect
        disconnect_node!(G, node)
    end
end