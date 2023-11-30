include("../src/ds.jl")
include("../src/const.jl")
include("../src/move_ops.jl")
include("../src/metaheuristics.jl")

filename = "../data/datasets/inst_competition/heur051_n_300_m_20122.txt"

println("GRASP with max_iter=10 for "*filename)
G = readSPSolutionFile(filename)
grasp!(G, false, false, true, 3, 100)
println("found obj-fct value is: $(calc_objective(G))")