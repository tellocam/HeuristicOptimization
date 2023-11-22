include("ds.jl")
include("const.jl")
include("local_improve.jl")

files_comp = readdir("datasets/inst_competition/")
files_tuning = readdir("datasets/inst_tuning/")
files_test = readdir("datasets/inst_test/")

for file in files_comp
    G = readSPSolutionFile("datasets/inst_competition/" * file)
    writeAdjacency(G, "adjacency_matrices/inst_competition/" * file, true)
    println("$(is_splex(G, true)) is splex for inst " * file)
end
for file in files_tuning
    G = readSPSolutionFile("datasets/inst_tuning/" * file)
    writeAdjacency(G, "adjacency_matrices/inst_tuning/" * file, true)
    println("$(is_splex(G, true)) is splex for inst " * file)
end
for file in files_test
    G = readSPSolutionFile("datasets/inst_test/" * file)
    writeAdjacency(G, "adjacency_matrices/inst_test/" * file, true)
    println("$(is_splex(G, true)) is splex for inst " * file)
end
#=
G_test = readSPSolutionFile("datasets/inst_test/test_s_2_n_10_m_31.txt")
result = Result()
par::Int = 0
det_const!(G_test)
G_test.A[1,3] = false
#display(G_test.A)
local_improve!(G_test, par, result)
#display(G_test.A)

G_test = readSPSolutionFile("datasets/inst_test/heur019_n_300_m_28765.txt")
det_const!(G_test)
writeAdjacency(G_test, "testfile_A0", true)
writeAdjacency(G_test, "testfile_before_fuse", false)
println("cost before fuse = $(calc_objective(G_test))")
valid = is_splex(G_test, false)
println("before fuse is valid: $(valid)")

for i in 1:9
    fuse_cluster!(G_test, find_clusters(G_test), 1)
    valid = is_splex(G_test, false)
    println("before fuse is valid: $(valid)")
end
writeAdjacency(G_test, "testfile_after_fuse", false)