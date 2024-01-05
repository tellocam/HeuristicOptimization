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

ant_colony_algorithm(G_0, tmax, m, α, β, μ, q0, etm)
println("are we done?")
println()
