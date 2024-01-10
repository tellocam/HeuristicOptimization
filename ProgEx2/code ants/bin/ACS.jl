include("../src/ACS_fun.jl")

using Random
using StatsBase
using Graphs
using ArgParse
using Base.Threads

push!(LOAD_PATH, "../src")
using ReadWriteLocks

# α: Global Evaporation Rate, μ: Local Evaporation Rate, β: Heuristic Exponent
# q0: Roulette/Greedy Probability Parameter
# n_conv is length of thread solution vector to check convergence
"The Ant Colony System algorithm which uses a repair function in order to not recalculate probabilities etc."
function AntColonySystemAlgorithm!(G::SPSolution, tmax, m, n_conv_thread, n_conv_global,
                                     α , β, μ, q0)
    
    G_ACO = initialize_ACS_solution(G) # Initialize Ant Colony System Solution based on SPSolution
    ant_results = Vector{Matrix{Bool}}(undef, m) # Vector for solutions that are accessed by each thread
    best_solution = zeros(Bool, G.n, G.n)  # Initialize best_solution
    best_obj_val = typemax(Int64)  # Initialize best_obj_val with a high value
    print_debugging = true
    
    for i in 1:m
        ant_results[i] = zeros(Int, G.n, G.n)
    end

    pheromone_lock = Base.Threads.ReentrantLock() # Lock for each entry in the pheromone matrix
    #pheromone_lock = Base.Threads.SpinLock() # Lock for each entry in the pheromone matrix
    # The type provided by this package is ReadWriteLock.
    # It has a single constructor.
    # This lock provides access to a read lock and a write lock
    # rwlock = ReadWriteLock()
    # rlock_pheromone = read_lock(rwlock)
    # wlock_pheromone = write_lock(rwlock)


    twice_locking = true

    t = 0
    min_obj_idx = 1  # Declare min_obj_idx here
    convergence_criteria_global = false
    start_timing = time()
    while (t<=tmax && !convergence_criteria_global)

        Threads.@threads for k in 1:m  # Parallelize m ants! Possibly gonna be 15.

            thread_results = Vector{Matrix{Bool}}()
            thread_objectives = Vector{Int}()
            thread_SPSol = copy(G)
            convergence_criteria_thread = false

            while (!convergence_criteria_thread) # let algorithm run until 1 of the convergence criteria is met!

                q_thread = 1-rand() # Every thread draws a random nr in uniformly distributed (0,1]
                if q_thread <= q0
                    selection_type = "Greedy"
                else
                    selection_type = "Roulette"
                end

                lock(pheromone_lock)
                current_edge = choose_edge!(G_ACO, β, ant_results[k], selection_type) # Choose next valid edge flip greedily/roulette
                
                if twice_locking == true
                    unlock(pheromone_lock)
                end

                if isnothing(current_edge)
                    println("No edges to choose left!")
                    # That means either all pheromones have completely evaporated or all edges are assigned.
                    unlock(pheromone_lock)
                    break
                end

                i,j = current_edge
                ant_results[k][i,j] = 1

                repairInstance!(ant_results[k], thread_SPSol)

                if twice_locking == true
                    lock(pheromone_lock)
                end

                localPheromoneUpdate!(G_ACO, ant_results[k], current_edge, μ)
                unlock(pheromone_lock)


                current_objective = calc_objective(G_ACO.W, G_ACO.A0 ,ant_results[k])
                push!(thread_objectives, current_objective)
                push!(thread_results, ant_results[k])
                convergence_criteria_thread = update_criteria_thread!(thread_objectives, thread_results, n_conv_thread)
                
                if convergence_criteria_thread == true
                    ant_results[k] = thread_results[1]
                end

            end

        end

        t += 1

        update_ACOSol!(G_ACO, G, ant_results, α)

        min_obj_idx = argmin(G_ACO.obj_vals)
        min_obj_val = G_ACO.obj_vals[min_obj_idx]

        if min_obj_val < best_obj_val
            best_obj_val = min_obj_val
            best_solution .= G_ACO.solutions[min_obj_idx]  # Update best_solution
        end

        if (print_debugging == true && t%10 == 0)
            println("iteration $(t) yields $(G_ACO.obj_vals[end]) objective value ")
            println("Norm of 𝜏: ", sum(sum(G_ACO.𝜏)))
            println("Current Number of Edges: ", sum(sum(G_ACO.solutions[end])))
            println("Best so far yields $(best_obj_val) objective value ")
            println("Objective value of function that is returned: $(calc_objective(G_ACO.W, G_ACO.A0, best_solution))")
        end

        convergence_criteria_global = update_criteria_global!(G_ACO.obj_vals, n_conv_global, best_obj_val)

    end
    elapsed_time = time() - start_timing
    Converged_Solution = copy(G)
    Converged_Solution.A = best_solution
    Converged_Solution.obj_val = best_obj_val
    println("Objective value of deterministic solution: ", G_ACO.c_det)
    println("Objective value of found solution: $best_obj_val")
    println("Elapsed Time for Algorithm: ", elapsed_time)

    return Converged_Solution

end