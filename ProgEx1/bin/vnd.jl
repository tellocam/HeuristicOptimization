include("../src/ds.jl")
include("../src/const.jl")
include("../src/local_improve.jl")
include("../src/metaheuristics.jl")

filename = "../data/datasets/inst_competition/heur051_n_300_m_20122.txt"

println("VND for "*filename)
G = readSPSolutionFile(filename)
vnd!(G)
println("found obj-fct value is: $(calc_objective(G))")