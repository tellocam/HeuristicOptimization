include("../bin/ACO.jl")
using LinearAlgebra

# filename = "../data/datasets/inst_competition/heur051_n_300_m_20122.txt"
filename = "../data/datasets/inst_test/heur001_n_10_m_31.txt"
G_0 = readSPSolutionFile(filename)

tmax = 20
m = Int8(15)
α = 0.1 
β = 2.0
μ = 0.1
q0 = 0.9
etm = 100

final_best_ant_result = ant_colony_algorithm(G_0, tmax, m, α, β, μ, q0, etm)
println("are we done?")
println("is_splex output of final solution: ", is_splex(final_best_ant_result, G_0.n, G_0.s))

println("Objective Value of final solution: ", calc_objective(G_0.W, G_0.A0, final_best_ant_result))
println(display(final_best_ant_result))
println(display(G_0.A0))
is_splex(G_0.A0, G_0.n, G_0.s)

test_matrix = G_0.A0

for i in 1:G_0.n
    for j in 1:i-1
        test_matrix[i,j] = 1
    end
end

println(display(test_matrix))
is_splex(test_matrix, G_0.n, G_0.s)



