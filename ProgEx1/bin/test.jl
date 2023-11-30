include("../src/ds.jl")
include("../src/const.jl")
include("../src/move_ops.jl")
include("../src/metaheuristics.jl")


filename = "../data/datasets/inst_test/heur002_n_100_m_3274.txt"

G = readSPSolutionFile(filename)

det_const!(G, 100)
#local_search!(G, false, "fuse")
println("value after fuse: $(calc_objective(G))")
local_search!(G, false, "swap")
println("value after swap: $(calc_objective(G))")



writeAdjacency(G, "test", false)