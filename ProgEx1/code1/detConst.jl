include("ds.jl")
using LinearAlgebra
using Plots, Graphs, GraphPlot




function det_constr(G::SPSolution) # deterministic construction of s-plexes from empty graph
    G.A = zeros(Int8, G.n,G.n)
    for i in 1:G.n
        for j in i:G.n
            if G.A0[i,j]
                obj_val_old = G.obj_val
                flipij(G, i, j)
                if !(G.obj_val_valid && G.obj_val < obj_val_old)
                    #flip was illegal, take back
                    flipij(G, i, j)
                    G.obj_val_valid = true
                end
            end
        end
    end
    return G
end



G_test = readSPSolutionFile(file_path)
display(G_test.A)
det_constr(G_test)
display(G_test.A)
display(G_test.A0)
println("new objective value $(G_test.obj_val) is smaller than 90 on empty graph")


g = SimpleGraph(Symmetric(G_test.A))