include("../src/ds.jl")
include("../src/const.jl")
include("../src/move_ops.jl")
include("../src/metaheuristics.jl")

filename = "../data/datasets/inst_test/heur020_n_320_m_5905.txt"


println("GVNS for "*filename)

G = readSPSolutionFile(filename)
println("performing gvns for file $filename")
G = gvns!(G, false, false, 100, 5, 50, 150)
println("found obj-fct value is: $(calc_objective(G))")