include("ds.jl")
include("const.jl")
include("local_improve.jl")

#TODO: there seems to be something wrong with the calculation of the objective value, see output below

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
fuse_to_max!(G_test)
writeAdjacency(G_test, "testfile_after_fuse", false)
println("cost after fuse = $(calc_objective(G_test))")


println("old value is $(G_test.obj_val)")

valid = flipij!(G_test, 7, 36)

println("change is valid: $(valid) and new value is $(G_test.obj_val)")




