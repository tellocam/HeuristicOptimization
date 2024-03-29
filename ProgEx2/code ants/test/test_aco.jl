include("../bin/ACS.jl")
using LinearAlgebra

#filename = "../data/datasets/inst_test/heur008_n_250_m_1045.txt"
#filename = "../data/datasets/inst_test/heur001_n_10_m_31.txt"
filename = "../data/datasets/inst_test_tuning/heur003_n_120_m_2588.txt"
#filename = "../data/datasets/inst_test_tuning/heur030_n_330_m_5613.txt"
#filename = "../data/datasets/inst_test_tuning/heur002_n_100_m_3274.txt"
G_0 = readSPSolutionFile(filename)

tmax = 1000
m = Int8(15)
n_conv_thread = 1
n_conv_global = 20

α = 0.1  # global evaporation rate
β = 2.0  # Heuristic Matrix Exponent
μ = 0.1  # local evaporation rate
q0 = 0.5 # Probability Threshold

G_Result = AntColonySystemAlgorithm!(G_0, tmax, m, n_conv_thread, n_conv_global, α, β, μ, q0)

println("is_splex output of final solution: ", is_splex(G_Result.A, G_Result.n, G_Result.s))
println("Objective Value of final solution: ", G_Result.obj_val)
println("Number of Edges of final solution: ", sum(sum(G_Result.A)))