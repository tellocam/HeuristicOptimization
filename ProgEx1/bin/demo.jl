include("../src/ds.jl")
include("../src/const.jl")
include("../src/move_ops.jl")
include("../src/metaheuristics.jl")


function print_results(G::SPSolution, operation::AbstractString)
    println("cost after "*operation*" = $(calc_objective(G))")
    valid = is_splex(G, false)
    println("after "*operation*" is valid: $(valid)")
end

filename = "../data/datasets/inst_competition/heur051_n_300_m_20122.txt"
G = readSPSolutionFile(filename)
det_const!(G, 100)
print_results(G, "construction")
writeAdjacency(G, "../data/matrices_for_inspection/A0", true)
writeAdjacency(G, "../data/matrices_for_inspection/after_construction", false)

det_const!(G, 100)
local_search!(G, false, "fuse")
print_results(G, "fuse")
writeAdjacency(G, "../data/matrices_for_inspection/after_fuse", false)


#local_search!(G, true, "swap")
swap_best!(G)
writeAdjacency(G, "../data/matrices_for_inspection/after_swap", false)
print_results(G, "swap")

cliquify_then_sparse!(G)
print_results(G, "cliquify then sparsen")
writeAdjacency(G, "../data/matrices_for_inspection/after_sparsen", false)
