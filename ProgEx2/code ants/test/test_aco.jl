include("../bin/ACO.jl")
using LinearAlgebra

filename = "../data/datasets/inst_competition/heur051_n_300_m_20122.txt"
# filename = "../data/datasets/inst_test/heur001_n_10_m_31.txt"
G_0 = readSPSolutionFile(filename)

tmax = 10
m = Int8(10)
α = 0.1  # global evaporation rate
β = 2.0  # Heuristic Matrix Exponent
μ = 0.1  # local evaporation rate
q0 = 0.9 # Probability Threshold
etm = 10 # edge try max

final_best_ant_result = ant_colony_algorithm(G_0, tmax, m, α, β, μ, q0, etm)

println("is_splex output of final solution: ", is_splex(final_best_ant_result, G_0.n, G_0.s))
println("Objective Value of final solution: ", calc_objective(G_0.W, G_0.A0, final_best_ant_result))
println(display(final_best_ant_result))





