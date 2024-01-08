include("ds.jl")

"Initialize η, 𝜏 matrices with initial adjacency matrix A0 and create sorted vector of tuples"
function initialize_ACO_solution(G::SPSolution)
    n = G.n
    𝜏, η = zeros(n, n), zeros(n, n)

    # Initialize η with values from G.W where A0 is 1, and sorted values where A0 is 0
    indices_1 = findall(G.A0 .== 1)
    η[indices_1] .= G.W[indices_1]
    indices_0 = findall(G.A0 .== 0)
    sorted_values = sort(G.W[indices_0], rev=true)
    η[indices_0] .= sorted_values

    # Create a vector of linear indices above the diagonal of η, sorted descendingly w.r.t. the entries.
    idx_sorted = [(i + n * (j - 1)) for i in 1:n for j in i+1:n]
    sorted_indices_η = sortperm(η[idx_sorted], rev=true)
    idx_sorted = idx_sorted[sorted_indices_η]

    # Introduce a cost yielded by a deterministic construction
    # The deterministic construction used here is just a fully connected graph which is a clique
    # and therefore also an S-Plex for any S

    G_1 = copy(G)

    for i in 1:G_1.n
        for j in i+1:G_1.n
            G_1.A[i, j] = 1 # Fully connected graph
        end
    end

    𝜏_obj_val_init = 1/calc_objective(G_1)
    
    for i in 1:G_1.n
        for j in i+1:G_1.n
            𝜏[i,j] = 𝜏_obj_val_init
        end
    end

    # Use the deterministic solution to introduce initial values to the pheromone matrix
    return ACOSolution(G.s, G.n, G.m, G.A0, G.W, 𝜏, η, calc_objective(G_1), Vector{Matrix{Bool}}(), Float64[] )
end

# This function is tested for the initial state, let's see if it works correctly later on..
"takes G_ACO, beta and current_ant_matrix to decide which edge to flip with roulette selection wheel"
function choose_edge_roulette(G_ACO::ACOSolution, β::Float64, current_ant_matrix::Matrix)

    indices = [(i, j) for i in 1:G_ACO.n for j in (i+1):Acols if current_ant_matrix[i, j] == 0]

    # Calculate probabilities according to HOT slides for ACS
    probabilities = [G_ACO.𝜏[i, j] * G_ACO.η[i, j]^β for (i, j) in indices]
   
    # Check if there are available edges
    if isempty(probabilities)
        return nothing
    end

    # Get the indices that would sort probabilities in ascending order, cumbersome, but in this case needed :(
    sorted_indices = sortperm(probabilities)

    # Sort indices and probabilities based on the sorted order of probabilities
    sorted_probabilities = probabilities[sorted_indices]
    # print(sorted_probabilities)
    sorted_indices = indices[sorted_indices]

    # Perform cumulative sum on the sorted probabilities, CDF implementation for roulette wheel selection
    cumulative_probs = cumsum(sorted_probabilities)
    random_value = rand() * cumulative_probs[end]

    # Find the index where the random value falls into the cumulative distribution
    selected_index = searchsortedfirst(cumulative_probs, random_value)

    # Retrieve the corresponding index from the sorted indices
    selected_indices = sorted_indices[selected_index]

    return selected_indices
end

function choose_edge_greedy!(G_ACO::ACOSolution, β::Float64, current_ant_matrix::Matrix)
    
    indices = [(i, j) for i in 1:G_ACO.n for j in (i+1):G_ACO.n if current_ant_matrix[i, j] == 0]

    # Calculate probabilities according to HOT slides for ACS
    probabilities = [G_ACO.𝜏[i, j] * G_ACO.η[i, j]^β for (i, j) in indices]
    # println("greedy size: ", size(probabilities))

    # Check if there are available edges to flip!
    if isempty(probabilities)
        return nothing
    end

    # Get the indices that would sort probabilities in ascending order
    sorted_indices = sortperm(probabilities)

    for linear_idx in sorted_indices
        # Convert linear index back to 2D indices
        i, j = indices[linear_idx]
        return i, j  # Return the greedily choosen indices.
    end

end


"Local Pheromone Update that is performed in a threadsafe manner after one edge is flipped"
function localPheromoneUpdate!(G_ACO::ACOSolution, current_ant_result::Matrix, current_edge::Tuple{Int, Int}, evaporation_rate::Float64)
    # println("Current Edge: ", current_edge)  # Add this line for debugging
    number_of_edges_used = sum(sum(abs.(current_ant_result), dims=1))

    i, j = current_edge
    G_ACO.𝜏[i, j] = (1 - evaporation_rate) * G_ACO.𝜏[i, j] + evaporation_rate / (number_of_edges_used * G_ACO.c_det)

end


"Global Phereomone Update that is performed after an iteration t is done, best ant evaporates and deposites pheromones"
function update_ACOSol!(G_ACO::ACOSolution, G::SPSolution, ant_results::Vector, evaporation_rate::Float64)
    
    # Find the best ant
    best_ant_index = argmin([calc_objective(G.W, G.A0, ant) for ant in ant_results])
    best_ant_objective = calc_objective(G.W, G.A0, ant_results[best_ant_index])

    # Update Pheromones only for the best ant
    best_ant_result = ant_results[best_ant_index]
    for i in 1:G.n
        for j in (i+1):G.n
            if best_ant_result[i, j] == 1
                # Update pheromone for the flipped edge
                G_ACO.𝜏[i, j] = (1 - evaporation_rate) * G_ACO.𝜏[i, j] + evaporation_rate / best_ant_objective
            end
        end
    end

    
    # Update G_ACO Solution vectors
    push!(G_ACO.solutions, best_ant_result)
    push!(G_ACO.obj_vals, best_ant_objective)

end

"Determines if thread solution is considered converged, returns true if so, otherwise false"
function update_criteria_thread!(ant_objectives::Vector)

    # D0 something with the input to determine convergence state
    # returns false if thread convergence criteria are not met, true otherwise
    return true
    
end

"Determines if global solution is considered converged, returns true if so, otherwise false"
function update_criteria_global!(G_ACO::ACOSolution)

    # D0 something with the input to determine convergence state
    # returns false if global convergence criteria are not met, true otherwise
    return true

end

"This function takes a solution matrix as input and adds edges deterministically by adding the cheapest edges to fulfill s-plex condition"
function repairInstance!(ant_k_solution:: Matrix, s)

    repaired_solution = ant_k_solution * s
    
    return repaired_solution
end    
# Functions we need in order to repair S-Plexes. but are already containedi in ds.jl and move_ops.jl

function deg(M::Matrix{Bool}, i) #returns degree of node i in G.A
    return sum(M[i,:]) + sum(M[:,i])
end

function dfs(M::Matrix{Bool}, n, i, visited) # depth first search to traverse all connected vertices
    if !visited[i]
        visited[i] = true
        for neighbour in 1:n
            if M[min(i, neighbour), max(i, neighbour)]
                dfs(M, n, neighbour, visited)
            end
        end
    end
end

# Find connected vertices in a cluster.
function cluster_list(M::Matrix{Bool}, n, i)
    visited = zeros(Bool, n)
    dfs(M, n, i, visited)
    return visited
end

function cluster_list(G::SPSolution, i, original::Bool)
    B = original ? G.A0 : G.A
    return cluster_list(B, G.n, i)
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
