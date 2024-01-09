include("../src/GA.jl")
include("../src/metaheuristics.jl")

G = readSPSolutionFile("../data/datasets/inst_test/heur002_n_100_m_3274.txt")

tstart = time()
new_G = GA(copy(G), 100, 200, 0.2, 0.5, 1, 1, 1.9)
tend = time()
println("total time $(tend-tstart)")
tstart = time()
#ref_G = vnd!(copy(G), false, false)
tend = time()
println("total time $(tend-tstart)")

println("value is $(calc_objective(new_G)) and the solution is valid $(is_splex(new_G, false))")
#println("for reference: vnd gives $(calc_objective(ref_G)) and the solution is valid $(is_splex(ref_G, false))")
