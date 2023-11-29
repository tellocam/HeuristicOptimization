include("../src/ds.jl")
include("../src/const.jl")
include("../src/move_ops.jl")
include("../src/metaheuristics.jl")

filenames =
["../data/datasets/inst_competition/heur049_n_300_m_17695.txt",
"../data/datasets/inst_competition/heur050_n_300_m_19207.txt",
"../data/datasets/inst_competition/heur051_n_300_m_20122.txt",
"../data/datasets/inst_test/heur005_n_160_m_4015.txt",
"../data/datasets/inst_test/heur020_n_320_m_5905.txt",
"../data/datasets/inst_test/heur025_n_329_m_32168.txt",
"../data/datasets/inst_test/heur021_n_320_m_13507.txt",
"../data/datasets/inst_tuning/heur047_n_300_m_20096.txt"]

visual_inspection_type = #types of graphs from visual inspection of a
["locally_connected",
"locally_connected",
"locally_connected",
"locally_connected",
"random", "random", "random", "random"]

filename = filenames[3]

println("SNS for "*filename)
G = readSPSolutionFile(filename)
sns!(G, false, 100, false, false)
println("found obj-fct value is: $(calc_objective(G))")


#= OLD...here we tried to make an algorithm that detects the type of graph and uses the appropriate algorithm
open("../data/tuning/custom_detection_test.csv", "w") do file
    write(file, "filename,visual_type,detected_type\n")
    for file_nr in 1:length(filenames)
        filename = filenames[file_nr]
        println("\nCUSTOM metaheuristic for "*filename)
        println("file should be of type $(visual_inspection_type[file_nr])")
        G = readSPSolutionFile(filename)
        G, fast = custom_MH!(G, 3) # low max_iter, just want to look at matrix detection
        fast ? detected_type = "locally_connected" : detected_type = "random"
        write(file, filename * "," * visual_inspection_type[file_nr] * "," * detected_type * "\n")
        println("found obj-fct value is: $(calc_objective(G))")
    end
end
=#