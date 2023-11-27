include("../src/ds.jl")
include("../src/const.jl")
include("../src/local_improve.jl")
include("../src/metaheuristics.jl")

filename = "../data/datasets/inst_competition/heur051_n_300_m_20122.txt"

println("GRASP for "*filename)
G = readSPSolutionFile(filename)
grasp!(G, 0, 10, 100, false, true, true)
println("found obj-fct value is: $(calc_objective(G))")