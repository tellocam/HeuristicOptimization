include("../src/ds.jl")
include("../src/const.jl")
include("../src/move_ops.jl")
include("../src/metaheuristics.jl")
include("../src/move_ops_delta.jl")

filename = "../data/datasets/inst_competition/heur051_n_300_m_20122.txt"

println("======\nDemo of Delta Evaluation\n======")
println("running vnd and vnd_delta for file "*filename)
G = readSPSolutionFile(filename)

println("\nProfiler of VND with fastest configuration with delta evaluation")
tstart = time()
det_const!(G, 100)
vnd_delta!(G)
tend = time()
println("Actual obj value is: $(calc_objective(G))")
println("Total time for VND is $(tend-tstart)\n====\n")


println("\nProfiler of VND with fastest configuration without delta evaluation")
tstart = time()
det_const!(G, 100)
vnd!(G, false, false)
tend = time()
println("Actual obj value is: $(calc_objective(G))")
println("Total time for VND is $(tend-tstart)\n====\n")


