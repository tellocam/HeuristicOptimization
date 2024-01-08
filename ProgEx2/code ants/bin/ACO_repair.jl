include("../src/ACO_fun_repair.jl")

using Random
using StatsBase
using Graphs
using ArgParse
using Base.Threads



# REMARKS / TODOS : 
# The parameter edge_try_max is redundant with the repair method of ACS - get rid of it!
# We need 2 functions that monitor convergence criteria per thread and globally to stop the algorithm - to implement!




# α: Global Evaporation Rate, μ: Local Evaporation Rate, β: Heuristic Exponent, q0: Roulette/Greedy Probability Parameter
"The Ant Colony System algorithm which uses a repair function in order to not recalculate probabilities etc."
function ant_colony_algorithm_repair(G::SPSolution, tmax, m,
                                     α , β, μ, q0)
    
    G_ACO = initialize_ACO_solution(G) # Initialize Ant Colony System Solution based on SPSolution
    ant_results = Vector{Matrix{Bool}}(undef, m) # Vector for solutions that are accessed by each thread
    ant_objectives = Vector{Int}(undef, m)

    for i in 1:m
        ant_results[i] = zeros(Int, G.n, G.n)
    end

    pheromone_lock = Base.Threads.ReentrantLock() # Lock for each entry in the pheromone matrix
    sol_idx = 1  # Initialize sol_idx before the loop
    
    t = 0
    convergence_criteria_global = false
    while (t<=tmax || not(convergence_criteria_global))

        Threads.@threads for k in 1:m  # Parallelize m ants! Possibly gonna be 10..
            convergence_criteria_thread = false
            while (not(convergence_criteria_thread)) # let algorithm run until 1 of the convergence criteria is met!

                q_thread = 1-rand() # Every thread draws a random nr in uniformly distributed (0,1]
                
                if q_thread <= q0

                    lock(pheromone_lock)
                    current_edge = choose_edge_greedy!(G_ACO, β, ant_results[k]) # Choose next valid edge flip greedily
                    unlock(pheromone_lock)

                    isnothing(current_edge) && break # short circuiting && operator, very fancy, if current_edge is nothing, break
                    i,j = current_edge
                    ant_results[k][i,j] = 1 # set the current edge to 1, non-critical, therefore not with lock
                    repairInstance!(ant_results[k], G_ACO.s)

                    # Lock around the pheromone update
                    lock(pheromone_lock)
                    localPheromoneUpdate!(G_ACO, ant_results[k], current_edge, μ)
                    unlock(pheromone_lock)

                    push!(ant_objectives[k], calc_objective(G_ACO.W, G_ACO.A0 ,ant_results[k]))
                    convergence_criteria_thread = update_criteria!(ant_objectives[k])
    
                else

                    lock(pheromone_lock)
                    current_edge = choose_edge_roulette(G_ACO, β, ant_results[k]) # Choose an edge by chance with roulette selection
                    unlock(pheromone_lock)

                    isnothing(current_edge) && break # short circuiting && operator, very fancy, if current_edge is nothing, break
                    i,j = current_edge
                    ant_results[k][i,j] = 1
                    repairInstance!(ant_results[k], G_ACO.s)

                    lock(pheromone_lock)
                    localPheromoneUpdate!(G_ACO, ant_results[k], current_edge, μ)
                    unlock(pheromone_lock)

                    push!(ant_objectives[k], calc_objective(G_ACO.W, G_ACO.A0 ,ant_results[k]))
                    convergence_criteria_thread = update_criteria_thread!(ant_objectives[k])

                end
            end
        end

        t += 1
        convergence_criteria_global = update_criteria_global!(G_ACO)
        update_ACOSol!(G_ACO, G, ant_results, α)
        sol_idx = argmin(G_ACO.obj_vals)
        println("iteration $(t) yields $(G_ACO.obj_vals[end]) objective value ")
        println("Best so far yields $(G_ACO.obj_vals[sol_idx]) objective value ")
        println("Norm of 𝜏: ",sum(sum(G_ACO.𝜏)))

    end

    return G_ACO.solutions[sol_idx]

end