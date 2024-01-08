include("../src/move_ops.jl")
include("../src/metaheuristics.jl")

G = readSPSolutionFile("../data/datasets/inst_test/heur001_n_10_m_31.txt")

ref_G = vnd!(G, false, false)

cliquify!(ref_G)
sparsen!(ref_G)
display(ref_G.A)
println("value after sparsen: $(calc_objective(ref_G)) and sol is valid: $(is_splex(ref_G, false))")