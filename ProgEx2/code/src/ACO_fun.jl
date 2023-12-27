include("ds.jl")

"Initialize η and 𝜏 matrices with initial adjacency matrix A0"
function initialize_ACO_solution(G::SPSolution) # Initialize η and 𝜏 matrices
    
    n = size(G.A0, 1)
    𝜏, η = zeros(n, n), zeros(n,n)     
    indices = findall(G.A0 .== 1)
    η[indices] .= G.W[indices]
    indices_0 = findall(G.A0 .== 0)                     # Find indices where G.A0 is 0
    sorted_values = sort(G.W[indices_0], rev=true)      # Sort the values from G.W at indices_0 in reverse order
    η[indices_0] .= sorted_values                       # Assign the sorted values to corresponding positions in tau
    
    # Create a vector of index pairs above the diagonal of η, sorted descendingly w.r.t. the entries.
    idx_sorted = [(i, j) for i in 1:n, j in i+1:n]
    sorted_indices_η = sortperm(η[idx_sorted], rev=true)
    idx_sorted = idx_sorted[sorted_indices_η]
    return ACOSolution(G, G, 𝜏, η, idx_sorted)          # for now, the pheromone matrix is just zeros

    
end

"takes G_ACO, beta and current_ant_matrix to decide which edge to flip with roulette selection wheel"
function choose_edge_roulette(G_ACO::ACOSolution, β::Float64, current_ant_matrix::Matrix)

    # Hopefully we'll get rid of this, when we made sure, that only the upper triangular matrix is used.
    Arows, Acols = size(current_ant_matrix)
    indices = [(i, j) for i in 1:Arows for j in (i+1):Acols if current_ant_matrix[i, j] == 0]

    # Calculate probabilities according to HOT slides
    probabilities = [G_ACO.𝜏[i, j] * G_ACO.η[i, j]^β for (i, j) in indices]

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

"Takes G_ACO, Beta and current_ant_matrix an returns the next edge that results in a valid flip"
function choose_edge_greedy(G_ACO::ACOSolution, s::Int, β::Float64, current_ant_matrix::Matrix)
    
    for (i,j) in G_ACO.sorted_indices
        if current_ant_matrix[i,j] == 0
            current_ant_matrix[i,j] = 1 # flip/activate edge i,j
            if is_splex(current_ant_matrix, s) # check validity
                return (i,j)
                break 
            else
                current_ant_matrix[i,j] = 0 # Flip back invalid edge
            end
        end
    end

end

"Local Phereomone Update that is performed in a threadsafe manner after one edge is flipped"
function localPheromoneUpdate!(G_ACO::ACOSolution, current_ant_matrix::Matrix, current_edge::Tuple{Int, Int})

end


# Updates entire ant colony solution after all ants have finished one iteration
function update_ACOSol!(G_ACO::ACOSolution, ant_results::Vector, evaporation_rate::Float64)
    # This functions needs to:
    # 1. update the pheromones G_aco.𝜏 according to the k new solutions stored in ant_results
    # 2. after 1. has been done, the evaporation rate needs to be applied to the pheromone matrix
    # 3. control structure that checks updates G_ACO.1st and G_ACO.2nd according to ant_results
end