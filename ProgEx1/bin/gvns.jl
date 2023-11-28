include("../src/ds.jl")
include("../src/const.jl")
include("../src/move_ops.jl")
include("../src/metaheuristics.jl")

filename = "../data/datasets/inst_competition/heur051_n_300_m_20122.txt"

function shaking1(G::SPSolution)
    disconnect_rd_n!(G, 10)
    return G
end

function shaking2(G::SPSolution)
    disconnect_rd_n!(G, 20)
    return G
end

function shaking3(G::SPSolution)
    disconnect_rd_n!(G, 30)
    return G
end

shaking_meths_init = [shaking1, shaking2, shaking3]

println("GVNS for "*filename)

G = readSPSolutionFile(filename)
println("performing gvns for file $filename")
G = gvns!(G, 5, false, false, 100, 2)
println("found obj-fct value is: $(calc_objective(G))")