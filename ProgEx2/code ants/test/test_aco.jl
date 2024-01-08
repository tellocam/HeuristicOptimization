include("../bin/ACO_repair.jl")
using LinearAlgebra

filename = "../data/datasets/inst_test/heur002_n_100_m_3274.txt"
# filename = "../data/datasets/inst_test/heur001_n_10_m_31.txt"
G_0 = readSPSolutionFile(filename)

# α: Global Evaporation Rate, μ: Local Evaporation Rate, β: Heuristic Exponent
# q0: Roulette/Greedy Probability Parameter
# n_conv is length of thread solution vector to check convergence
# "The Ant Colony System algorithm which uses a repair function in order to not recalculate probabilities etc."
# function ant_colony_algorithm_repair(G::SPSolution, tmax, m, n_conv,
#                                      α , β, μ, q0)

tmax = 5
m = Int8(15)
n_conv = 5
α = 0.1  # global evaporation rate
β = 2.0  # Heuristic Matrix Exponent
μ = 0.1  # local evaporation rate
q0 = 0.9 # Probability Threshold

final_best_ant_result = ant_colony_algorithm_repair(G_0, tmax, m, n_conv, α, β, μ, q0)

println("is_splex output of final solution: ", is_splex(final_best_ant_result, G_0.n, G_0.s))
println("Objective Value of final solution: ", calc_objective(G_0.W, G_0.A0, final_best_ant_result))
println(display(final_best_ant_result))





