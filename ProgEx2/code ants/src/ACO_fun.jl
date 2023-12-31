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
    return ACOSolution(𝜏, η, calc_objective(G_1), Vector{Matrix{Bool}}(), Float64[] )
end

# This function is tested for the initial state, let's see if it works correctly later on..
"takes G_ACO, beta and current_ant_matrix to decide which edge to flip with roulette selection wheel"
function choose_edge_roulette(G_ACO::ACOSolution, β::Float64, current_ant_matrix::Matrix)

    # Hopefully we'll get rid of this, when we made sure, that only the upper triangular matrix is used.
    Arows, Acols = size(current_ant_matrix)
    indices = [(i, j) for i in 1:Arows for j in (i+1):Acols if current_ant_matrix[i, j] == 0]

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

function linear_to_sub(ind, size)
    i = (ind - 1) % size[1] + 1
    j = div(ind - 1, size[1]) + 1
    return (i, j)
end

function choose_edge_greedy!(G_ACO::ACOSolution, s::Int, β::Float64, current_ant_matrix::Matrix)

    product_matrix = G_ACO.𝜏 .* G_ACO.η .^ β
    n = size(current_ant_matrix, 1)
    
    # Linearize the matrix indices
    idx_sorted = sortperm(vec(product_matrix), rev=true)
    
    for linear_idx in idx_sorted
        # Convert linear index back to 2D indices
        i, j = linear_to_sub(linear_idx, (n, n))
        
        if current_ant_matrix[i, j] == 0
            current_ant_matrix[i, j] = 1  # flip/activate edge i,j
            
            if is_splex(current_ant_matrix, n, s)  # check validity
                return (i, j)
            else
                current_ant_matrix[i, j] = 0  # Flip back invalid edge
            end
        end
    end

    # If the function reaches this point without being able to flip a valid edge,
    # the function will return nothing. This case needs to be handled in the main ACO function
    # to bring the algorithm to stop.
    return nothing
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
