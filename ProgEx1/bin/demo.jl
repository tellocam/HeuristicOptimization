include("../src/ds.jl")
include("../src/const.jl")
include("../src/local_improve.jl")


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

fuse_to_max!(G, false)
print_results(G, "fuse")
writeAdjacency(G, "../data/matrices_for_inspection/after_fuse", false)

#=
if filename == "../data/datasets/inst_competition/heur051_n_300_m_20122.txt" #demo of swapping nodes for 051
    swap!(G, 154, true)
    print_results(G, "swap node 154")

    swap!(G, 267, true)
    print_results(G, "swap node 267")
    
    writeAdjacency(G, "matrix_after_swap", false)
end
=#

swap_to_max!(G, true, true)
print_results(G, "swap to max")

cliquify_then_sparse(G)
print_results(G, "cliquify then sparsen")
writeAdjacency(G, "../data/matrices_for_inspection/after_sparsen", false)