include("ds.jl")

# Initialize η and 𝜏 matrices with adjacency matrix A0
function initialize_ACO_solution(G::SPSolution) # Initialize η and 𝜏 matrices
    
    n = size(G.A0, 1)
    𝜏, η = zeros(n, n), zeros(n,n)     
    indices = findall(G.A0 .== 1)
    η[indices] .= G.W[indices]
    indices_0 = findall(G.A0 .== 0)                     # Find indices where G.A0 is 0
    sorted_values = sort(G.W[indices_0], rev=true)      # Sort the values from G.W at indices_0 in reverse order
    η[indices_0] .= sorted_values                       # Assign the sorted values to corresponding positions in tau
    return ACOSolution(G, G, 𝜏, η)          # for now, the pheromone matrix is just zeros
end

# takes G_ACO, alpha and beta and current_ant_matrix to determine with roulette which edge to flip.
function choose_edge_roulette(G_ACO::ACOSolution, α::Float64, β::Float64, current_ant_matrix::Matrix)
    
    indices = findall(isequal(1), UpperTriangular(current_ant_matrix))
    # G_ACO.𝜏  G_ACO.η are matrices of floats of correct size already.
    # take 𝜏, η and current_ant_matrix to determine with roulette which edge to flip. return its indices i,j.
    # only indices i,j are considered if current_ant_matrix[i,j] = 0
    # alpha and beta are the known parameters for the probabilities for tau and eta.
    
    
    return indices
end

# Updates entire ant colony solution after all ants have finished one iteration
function update_ACOSol!(G_ACO::ACOSolution, ant_results::Vector, evaporation_rate::Float64)
    # This functions needs to:
    # 1. update the pheromones G_aco.𝜏 according to the k new solutions stored in ant_results
    # 2. after 1. has been done, the evaporation rate needs to be applied to the pheromone matrix
    # 3. control structure that checks updates G_ACO.1st and G_ACO.2nd according to ant_results
end