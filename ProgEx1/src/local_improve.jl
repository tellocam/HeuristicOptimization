include("ds.jl")
include("const.jl")
using Random
using StatsBase
using Graphs
using MHLib
using ArgParse





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

function fuse_cluster!(G::SPSolution, clusters, i, j, modify::Bool) #try to fuse cluster number i and j, returns improvement
    #TODO: check if i!=j and if i and j are smaller than max(clusters)
    #TODO: delta eval.
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
    # take out the unnecessary connections
    added_cost = sum(G.W .* abs.(G.A0-AC)) - calc_objective(G)
    if modify
        G.A = AC 
    end
    return added_cost
end

function fuse_first!(G::SPSolution)::Bool
    clusters = find_clusters(G)
    nr_clusters = maximum(clusters)
    for i in 1:nr_clusters
        for j in i:nr_clusters
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
    for i in 1:nr_clusters
        for j in i:nr_clusters
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
    deleted = sum(in_new_cluster) - deg(G.A, node) #should be 0 here, todo: check
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

function swap!(G::SPSolution, node, best::Bool)
    clusters = find_clusters(G)
    clusters_u = unique(clusters)
    improvements = zeros(Int, length(clusters_u))
    my_cluster = clusters[node]
    old_val = calc_objective(G)
    
    for new_cluster in clusters_u
        if new_cluster != my_cluster
            improvements[new_cluster] = swap_node!(G, node, my_cluster, new_cluster, clusters, false)
            if improvements[new_cluster] < 0 && !best #found improvement, leave it if first improvement
                swap_node!(G, node, my_cluster, new_cluster, clusters, true)
                return improvements[new_cluster]
            end
        end
    end
    if best
        best_cluster = argmin(improvements)
        change = improvements[best_cluster] < 0
        if change
            swap_node!(G, node, my_cluster, best_cluster, clusters, true)
            return improvements[best_cluster]
        end
    end
    # no improvements found
    return 0
end


function swap_to_max!(G::SPSolution, best::Bool, revisit::Bool)
    # first improvement node swap. within the swap_node fct we choose first or best impr.
    if !revisit
        for i in shuffle(1:G.n) # randomly search for nodes to switch cluster
            swap!(G, i, best)
        end
    else
        changed = true
        while changed
            for i in shuffle(1:G.n) # randomly search for nodes to switch cluster
                added_cost = swap!(G, i, best)
                changed = added_cost < 0
            end
        end
    end
end


function swap_best!(G::SPSolution)
    clusters = find_clusters(G)
    clusters_u = unique(clusters)
    improvements = zeros(Int, G.n, length(clusters_u))
    for node in 1:G.n
        for new_cluster in clusters_u
            improvements[node, new_cluster] = swap_node!(G, node, clusters[node], new_cluster, clusters, false)
        end
    end
    best_swap = argmin(improvements)
    if improvements[best_swap] < 0
        swap_node!(G, best_swap[1], clusters[best_swap[1]], best_swap[2], clusters, true)
        return true
    end
    return false
end


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

function cliquify_then_sparse(G::SPSolution)
    cliquify!(G)
    clusters = find_clusters(G)
    in_my_cluster = zeros(Bool, G.n)
    for node in 1:G.n
        my_cluster = clusters[node]
        in_my_cluster = clusters .== my_cluster
        my_cluster_size = sum(in_my_cluster)
        deleted = my_cluster_size - deg(G.A, node) #this node has already deleted so many from clique state
        rel_weights = copy(G.W[node, :])
        rel_weights = rel_weights .* in_my_cluster .* (G.A0[node, :] .== 0) # only these edges are interesting to change for node i
        while deleted < G.s #can only delete up to s-1 edges
            other = argmax(rel_weights)
            rel_weights[other] = 0
            if deg(G.A, other) > my_cluster_size - G.s
                G.A[node, other] = 0
                deleted += 1
            end
            if rel_weights[other] == 0 #no more potential edges
                break
            end
        end
    end
end