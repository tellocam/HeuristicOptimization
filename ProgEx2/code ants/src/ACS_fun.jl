include("move_ops.jl")
include("ds.jl")

"Initialize η, 𝜏 matrices with initial adjacency matrix A0 and create sorted vector of tuples"
function initialize_ACS_solution(G::SPSolution)
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

    # println("thats the initialization objective $(calc_objective(G_1))")

    𝜏_obj_val_init = 1/calc_objective(G_1)
    
    for i in 1:G_1.n
        for j in i+1:G_1.n
            𝜏[i,j] = 𝜏_obj_val_init
        end
    end

    # println("Norm of 𝜏 at initialization is: ",sum(sum(𝜏)))

    # Use the deterministic solution to introduce initial values to the pheromone matrix
    return ACOSolution(G.s, G.n, G.m, G.A0, G.W, 𝜏, η, calc_objective(G_1), Vector{Matrix{Bool}}(), Float64[] )
end

# This function is tested for the initial state, let's see if it works correctly later on..
"takes G_ACO, beta and current_ant_matrix to decide which edge to flip with roulette selection wheel"
function choose_edge_roulette!(G_ACO::ACOSolution, β::Float64, current_ant_matrix::Matrix)

    indices = [(i, j) for i in 1:G_ACO.n for j in (i+1):G_ACO.n if current_ant_matrix[i, j] == 0]

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

function choose_edge!(G_ACO::ACOSolution, β::Float64, current_ant_matrix::Matrix, selection_type::String)

    if selection_type == "Roulette"
        return choose_edge_roulette!(G_ACO, β, current_ant_matrix)

    elseif selection_type == "Greedy"
        return choose_edge_greedy!(G_ACO, β, current_ant_matrix)

    else
        print("non-valid selection type")
        return nothing
    end

end


"Local Pheromone Update that is performed in a threadsafe manner after one edge is flipped"
function localPheromoneUpdate!(G_ACO::ACOSolution, current_ant_result::Matrix, current_edge::Tuple{Int, Int}, evaporation_rate::Float64)
    # println("Current Edge: ", current_edge)  # Add this line for debugging
    number_of_edges_used = sum(sum(abs.(current_ant_result), dims=1))

    i, j = current_edge
    G_ACO.𝜏[i, j] = (1 - evaporation_rate) * G_ACO.𝜏[i, j] + evaporation_rate * number_of_edges_used / G_ACO.c_det

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
function update_criteria_thread!(thread_objectives::Vector{Int64}, thread_results::Vector, n_conv_thread::Int)
    if length(thread_objectives) > n_conv_thread
        popfirst!(thread_objectives)
        popfirst!(thread_results)
    end
    
    if length(thread_objectives) == n_conv_thread
        last_n_values = thread_objectives[end-n_conv_thread+1:end]
        if all(diff(last_n_values) .<= 0)
            return true  # Last n_conv values are non-increasing
        end
    end
    
    return false  # Not converged, ant can continue!
end

"Determines if global solution is considered converged, returns true if so, otherwise false"
function update_criteria_global!(global_objectives::Vector{Int64}, n_conv_global::Int, best_obj_val::Int)

    if length(global_objectives) > n_conv_global
        last_n_entries = global_objectives[end - n_conv_global + 1:end]
        return all(last_n_entries .> best_obj_val)
    end
    
    return false
end

"This function takes a solution matrix as input and adds edges deterministically by adding the cheapest edges to fulfill s-plex condition"
function repairInstance!(ant_k_solution:: Matrix, G_thread::SPSolution)

    G_thread.A = ant_k_solution

    cliquify!(G_thread)
    sparsen!(G_thread)

    repaired_solution = G_thread.A
    
    return repaired_solution
end

function random_search_ACS_tuning(num_trials, all_combinations, folder_path, num_files)
    best_params = Dict("α" => 0.0, "μ" => 0.0, "q0" => 0.0)
    best_avg_result = Inf

    β = 2.0
    tmax = 1000
    m = Int8(15)
    n_conv_thread = 1
    n_conv_global = 5

    # Shuffle the list of combinations
    shuffled_combinations = shuffle(all_combinations)

    for params in Iterators.take(shuffled_combinations, num_trials)
        
        α, μ, q0 = params

        total_result = 0.0

        for _ in 1:num_files
            files = readdir(folder_path)
            file_name = joinpath(folder_path, files[rand(1:end)])
            G = readSPSolutionFile(file_name)
            result = AntColonySystemAlgorithm!(G, tmax, m, n_conv_thread, n_conv_global, α, β, μ, q0)
            total_result += result.obj_val
        end

        avg_result = total_result / num_files

        if avg_result < best_avg_result
            best_avg_result = avg_result
            best_params["α"] = α
            best_params["μ"] = μ
            best_params["q0"] = q0
        end
    end

    return best_params, best_avg_result
end

# # Example usage
# num_trials = 5  # Change this to the desired number of trials
# instance_folder_path = "../data/datasets/inst_tuning/"
# num_files = 1

# # Define fixed values for parameters
# α_values = [0.2, 0.25, 0.3, 0.35, 0.4]
# μ_values = [0.2, 0.25, 0.3, 0.35, 0.4]
# q0_values = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7]

# # Generate all combinations
# all_combinations = collect(Iterators.product(α_values, μ_values, q0_values))

# # Call the tuning function with the combinations
# best_params, best_avg_result = random_search_ACS_tuning_with_combinations(num_trials, all_combinations, instance_folder_path, num_files)

# # ... (rest of the code remains the same)