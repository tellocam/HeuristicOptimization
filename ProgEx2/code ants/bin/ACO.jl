include("../src/ACO_fun.jl")

using Random
using StatsBase
using Graphs
using ArgParse
using Base.Threads

# α: Global Evaporation Rate, μ: Local Evaporation Rate, β: Decision Probability Exponent, q0: Roulette/Greedy Probability Parameter

function ant_colony_algorithm(G::SPSolution, tmax, m,
                              α , β, μ, q0, 
                              edge_try_max)
    
    G_ACO = initialize_ACO_solution(G) # Initialize 𝜏 and η matrices

    ant_results = Vector{Matrix{Bool}}(undef, m)

    for i in 1:m
        ant_results[i] = zeros(Int, G.n, G.n)
    end
    pheromone_lock = Base.Threads.ReentrantLock() # Lock for each entry in the pheromone matrix
    # stop_threads = Base.Threads.Atomic{Bool}(false)  # Atomic boolean flag to signal threads to stop
    sol_idx = 1  # Initialize sol_idx before the loop
    for t in 1:tmax

        Threads.@threads for k in 1:m  # Parallelize m ants! Possibly gonna be 10..
            
            flipped_edges = 1
            success = false
            while (flipped_edges <=  floor(1/10 * G.n * (G.n -1) / 2)) # 10 percent of all possible edges is upper limit

                q_thread = 1-rand() # Every thread draws a random nr in uniformly distributed (0,1]
                if q_thread <= q0
                    current_edge = choose_edge_greedy!(G_ACO, Int64(G.s), β, ant_results[k]) # Choose next valid edge flip greedily
                    flipped_edges += 1
                    success = true

                    # Lock around the pheromone update
                    lock(pheromone_lock)
                    localPheromoneUpdate!(G_ACO, ant_results[k], current_edge, μ)
                    unlock(pheromone_lock)
                
                else
                    success = false
                    for attempt in 1:edge_try_max # Attempt to flip an edge with roulette selection wheel
                        
                        lock(pheromone_lock)
                        # stupid, but this function already flips the edge.. dont need to flip it outside of the fct call
                        current_edge = choose_edge_roulette(G_ACO, β, ant_results[k]) # Choose an edge by chance with roulette selection
                        if (isnothing(current_edge))
                            println("No edges to flip left for ant $k")
                            unlock(pheromone_lock)
                            # Threads.AtomicAssign(stop_threads, true)  # Signal other threads to stop
                            break
                        end

                        i,j = current_edge
                        unlock(pheromone_lock)
                        ant_results[k][i,j] = 1
                        
                        if is_splex(ant_results[k], G.n, G.s)
                            success = true
                            flipped_edges += 1
                            # Lock around the pheromone update
                            lock(pheromone_lock)
                            localPheromoneUpdate!(G_ACO, ant_results[k], current_edge, μ)
                            unlock(pheromone_lock)
                        else
                            ant_results[k][i,j] = 0 # flip edge back if it resulted in a invalid s-plex
                        end
                    end

                end

                if success
                # Nothing, we can just continue trying to flip other edges
                else
                    println("Failed ", edge_try_max, " times, ant ", k, " is done")
                    break
                end
            end
        end

        update_ACOSol!(G_ACO, G, ant_results, α)
        sol_idx = argmin(G_ACO.obj_vals)
        println("iteration $(t) yields $(G_ACO.obj_vals[end]) objective value ")
        println("Best so far yields $(G_ACO.obj_vals[sol_idx]) objective value ")
        println("Norm of 𝜏: ",sum(sum(G_ACO.𝜏)))

    end

    return G_ACO.solutions[sol_idx]

end