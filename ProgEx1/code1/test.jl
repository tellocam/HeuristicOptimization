include("ds.jl")
include("const.jl")
include("local_improve.jl")

#TODO: there seems to be something wrong with the calculation of the objective value, see output below

G_test = readSPSolutionFile("datasets/inst_test/test_s_2_n_10_m_31.txt")
result = Result()
par::Int = 0
det_const!(G_test, 5)
G_test.A[1,3] = false
#display(G_test.A)
#local_improve!(G_test, par, result)
#display(G_test.A)
display(G_test.A)
#G_test.A[1,4] = 1
clusters = find_clusters(G_test)
display(clusters)
fuse_cluster!(G_test, clusters, 1, 2, true)
display(G_test.A)
clusters = find_clusters(G_test)
display(clusters)

G_test = readSPSolutionFile("datasets/inst_test/heur005_n_160_m_4015.txt")
det_const!(G_test, 0) # TODO: why is this still working with 0 and how the fuck does it even yield best results??
writeAdjacency(G_test, "testfile_A0", true)
writeAdjacency(G_test, "testfile_before_fuse", false)
println("cost before fuse = $(calc_objective(G_test))")
valid = is_splex(G_test, false)
println("before fuse is valid: $(valid)")

#=
for i in 1:9
    fuse_cluster!(G_test, find_clusters(G_test), 1, true)
    valid = is_splex(G_test, false)
    println("before fuse is valid: $(valid)")
end
=#
fuse_to_max!(G_test, false)
println("cost after fuse = $(calc_objective(G_test))")
writeAdjacency(G_test, "testfile_after_fuse", false)
#=
fuse_to_max!(G_test)
writeAdjacency(G_test, "testfile_after_fuse", false)
println("cost after fuse = $(calc_objective(G_test))")


println("old value is $(G_test.obj_val)")

valid = is_splex(G_test, false)

println("after fuse is valid: $(valid)")

valid = flipij!(G_test, 7, 36)

println("change is valid: $(valid) and new value is $(G_test.obj_val)")


=#

