include("ds.jl")
include("const.jl")
include("local_improve.jl")

G_test = readSPSolutionFile("datasets/inst_test/heur002_n_10_m_31.txt")
result = Result()
par::Int = 0
det_const(G_test)
G_test.A[1,3] = false
display(G_test.A)
local_improve!(G_test, par, result)
display(G_test.A)