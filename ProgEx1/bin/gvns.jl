include("../src/ds.jl")
include("../src/const.jl")
include("../src/move_ops.jl")
include("../src/metaheuristics.jl")

filename = "../data/datasets/inst_competition/heur051_n_300_m_20122.txt"


println("GVNS for "*filename)

G = readSPSolutionFile(filename)
println("performing gvns for file $filename")
G = gvns!(G, false, false, 100, 5, 20, 40)
println("found obj-fct value is: $(calc_objective(G))")