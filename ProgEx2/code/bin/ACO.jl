include("../src/ds.jl")
include("../src/ACO_fun.jl")

using Random
using StatsBase
using Graphs
using ArgParse
using Threads

filename = "../data/datasets/inst_competition/heur051_n_300_m_20122.txt"
G_0 = readSPSolutionFile(filename)

tmax = 10 # maximal number of times each ant constructs a solution
m = 5 # number of ants
edge_try_max = 10 # maximal number of algorithm's try's of flipping an edge s.t. graph is valid splex
evaporation_rate = 1 # dont know what sensible numbers are here yet..


function ant_colony_algorithm(G::SPSolution, G_ACO::ACOSolution,
                              tmax::Int64, m::Int64, α::Float64, β::Float64,
                              edge_try_max::Int64, evaporation_rate::Float64)
    
    G_ACO = initialize_ACO_solution(G::SPSolution) # Initialize 𝜏 and η matrices
    ant_results = Vector{Matrix{Int}}((G.n, G.n), m) # Vector that holds ant k's solutions

    for t in 1:tmax

        Threads.@threads for k in 1:m  # Parallelize the m ants!

            flipped_edges = 1 
            while (flipped_edges <=  floor(1/10 * G.n * (G.n -1) / 2)) # 10 percent of all possible edges is upper limit
                # alright, here all ants draw random number q
                # if q>q0 -> ant performs greedy heuristic edge flip that yields in valid s-plex
                # if q<=q0 -> ant perfroms edge flip with roulette wheel
                ant_results[k][rand(1:G.n), rand(1:G.n)] = 1  # Activate the first edge randomly, maybe not necessary.
                success = False
                for attempt in 1:edge_try_max # Attempt to flip an edge with either greedy or roulette method
                    current_edge = choose_edge_roulette(G_ACO, α, β, ant_results[k]) # Choose an edge according to pheromone matrix 𝜏
                    ant_results[k][current_edge] = 1 
                    
                    if is_splex(ant_results[k], G.n, G.s)
                        # here we must include the local pheromone update that is threadsafe or an atomic operation,
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
                    break # break while i hope..
                end
            end
        end

        update_ACOSol!(G_ACO, ant_results, evaporation_rate)

    end
end