# initialized the pheromone matrix with adjacency matrix A0
function initialize_pheromones(A0::Matrix)
    𝜏0 = A0
    return 𝜏0
end


# takes 𝜏 and current_ant_matrix to determine with roulette which edge to flip.
function choose_edge_roulette(𝜏::Matrix, current_ant_matrix::Matrix)
    # take 𝜏 and current_ant_matrix to determine with roulette which edge to flip.
    i,j = 1,1
    return (i,j)
end


# Updates entire ant colony solution after all ants have finished one iteration
function update_ACOSol!(G_ACO::ACOSolution, ant_results::Vector, evaporation_rate::Float64)
    # This functions needs to:
    # 1. update the pheromones G_aco.𝜏 according to the k new solutions stored in ant_results
    # 2. after 1. has been done, the evaporation rate needs to be applied to the pheromone matrix
    # 3. control structure that checks updates G_ACO.1st and G_ACO.2nd according to ant_results
end