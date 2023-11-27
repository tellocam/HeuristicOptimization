include("../src/ds.jl")
include("../src/const.jl")
include("../src/move_ops.jl")

files_comp = readdir("../data/datasets/inst_competition/")
files_tuning = readdir("../data/datasets/inst_tuning/")
files_test = readdir("../data/datasets/inst_test/")

for file in files_comp
    G = readSPSolutionFile("../data/datasets/inst_competition/" * file)
    writeAdjacency(G, "../data/adjacency_matrices/inst_competition/" * file, true)
    println("$(is_splex(G, true)) is splex for inst " * file)
end
for file in files_tuning
    G = readSPSolutionFile("../data/datasets/inst_tuning/" * file)
    writeAdjacency(G, "../data/adjacency_matrices/inst_tuning/" * file, true)
    println("$(is_splex(G, true)) is splex for inst " * file)
end
for file in files_test
    G = readSPSolutionFile("../data/datasets/inst_test/" * file)
    writeAdjacency(G, "../data/adjacency_matrices/inst_test/" * file, true)
    println("$(is_splex(G, true)) is splex for inst " * file)
end
