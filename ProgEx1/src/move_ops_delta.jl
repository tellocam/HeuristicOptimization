include("ds.jl")
include("const.jl")
include("move_ops.jl")
using Random
using StatsBase
using Graphs
using MHLib
using ArgParse



####### implementation of delta eval for all functions where its meaningful in move_ops. #######
# basic idea: update the cost not for everything but only for the s-plex that is effected and return the added_cost.


#### FUSE OPERATION ####


function fuse_cluster_delta!(G::SPSolution, clusters, i, j, modify::Bool) #try to fuse cluster number i and j, returns improvement
    #should to check here to make sure i and j are ok
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
                    # DELTA EVAL: compute the added cost here only for this one edge
                    changed = (G.A[min(i,j),max(i,j)] == 0)
                    cost_reduced = (G.A0[min(i,j),max(i,j)] == 1)
                    added_cost += changed * (-cost_reduced * 2 + 1) * G.W[min(i,j),max(i,j)]
                    # DELTA EVAL over
                end
            end
        end
    end
    # take out the unnecessary connections
    if modify
        G.A = AC 
    end
    return added_cost
end

function fuse_first_delta!(G::SPSolution)::Int
    clusters = find_clusters(G)
    nr_clusters = maximum(clusters)
    for i in 1:nr_clusters
        for j in i:nr_clusters
            added_cost = fuse_cluster_delta!(G, clusters, i, j, false)
            if added_cost < 0
                fuse_cluster_delta!(G, clusters, i, j, true)
                return added_cost
            end
        end
    end
    return 0
end




#### SWAP OPERATION ####


function swap_node_delta!(G::SPSolution, node, from, to, clusters, modify)
    added_cost = 0
    #disconnect node
    save_col = copy(G.A[node,:])
    save_row = copy(G.A[:,node])
    for other in 1:G.n
        changed = (G.A[min(node, other),max(node, other)] == 1)
        G.A[min(node, other),max(node, other)] = 0
        # DELTA EVAL: compute the added cost here only for this one edge
        cost_reduced = (G.A0[min(node, other),max(node, other)] == 0)
        added_cost += changed * (-cost_reduced * 2 + 1) * G.W[min(node, other),max(node, other)]
        # DELTA EVAL over
    end
    rel_weights = zeros(Int8, G.n) # relevant weights for later 
    for other in 1:G.n
        if clusters[other] == to
            changed = (G.A[min(node, other),max(node, other)] == 0)
            G.A[min(node, other),max(node, other)] = 1
            # DELTA EVAL: compute the added cost here only for this one edge
            cost_reduced = (G.A0[min(node, other),max(node, other)] == 1)
            added_cost += changed * (-cost_reduced * 2 + 1) * G.W[min(node, other),max(node, other)]
            # DELTA EVAL over
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
            changed = (G.A[min(node, other),max(node, other)] == 1)
            G.A[node, other] = 0
            # DELTA EVAL: compute the added cost here only for this one edge
            cost_reduced = (G.A0[min(node, other),max(node, other)] == 0)
            added_cost += changed * (-cost_reduced * 2 + 1) * G.W[min(node, other),max(node, other)]
            # DELTA EVAL over
        end
        if rel_weights[other] == 0 #no more potential edges
            break
        end
    end
    

    if !modify
        G.A[node,:] = save_col
        G.A[:,node] = save_row
        return 0
    end
    
    return added_cost
end



function swap_first_delta!(G::SPSolution)
    clusters = find_clusters(G)
    clusters_u = unique(clusters)
    for node in 1:G.n
        my_cluster = clusters[node]
        for new_cluster in clusters_u
            if new_cluster != my_cluster
                improvement = swap_node!(G, node, my_cluster, new_cluster, clusters, false)
                if improvement < 0
                    swap_node!(G, node, my_cluster, new_cluster, clusters, true)
                    return improvement
                end
            end
        end
    end
    return 0
end
