include("../src/ds.jl")
include("../src/ACO_fun.jl")

using Random
using StatsBase
using Graphs
using ArgParse
using Threads

filename = "../data/datasets/inst_competition/heur051_n_300_m_20122.txt"
G_0 = readSPSolutionFile(filename)

# Placeholder: Define tmax, m, edge_try_max, edge_flip_max, and other parameters
tmax = 10
m = 5
edge_try_max = 10
edge_flip_max = ...
num_edges = ...
evaporation_rate = ...


function ant_colony_algorithm(G::SPSolution, G_ACO::ACOSolution, tmax, m, alpha_edges, edge_try_max, evaporation_rate)
    
    # Initialize pheromone matrix
    G_ACO.𝜏 = initialize_pheromones(G)

    # Vector that holds ant k's solutions
    ant_results = Vector{Matrix{Int}}((G.n, G.n), m)
    
    for t in 1:tmax

        Threads.@threads for k in 1:m  # Parallelize the loop through each ant
            flipped_edges = 1 
            while (flipped_edges <=  floor(alpha_edges * G.n * (G.n -1) / 2))
                ant_results[k][rand(1:G.n), rand(1:G.n)] = 1  # Activate the first edge randomly
                success = False
                for attempt in 1:edge_try_max # Attempt to flip an edge with 𝜏 and roulette wheel
                    current_edge = choose_edge_roulette(G_ACO.𝜏) # Choose an edge according to pheromone matrix 𝜏
                    ant_results[k][current_edge] = 1 
                    if is_splex(ant_results[k], G.n, G.s)
                        success = True
                        flipped_edges += 1
                        break
                    else
                        ant_results[k][current_edge] = 0 # flip edge back if it is invalid
                    end

                end

                if success
                # Nothing, we can just continue trying to flip other edges
                else
                    println("Failed edge_try_max times. ant k is done")
                    break
                end
            end
        end

        update_pheromones!(G_ACO.𝜏, ant_results, evaporation_rate)

    end
end