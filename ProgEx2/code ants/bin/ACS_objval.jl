include("../src/ACS_fun.jl")
include("../bin/ACS.jl")

# Parameters obtained by "advanced" parameter tuning
α = 0.3
μ = 0.35
q0 = 0.3

# Parameters that are set, bcs likely to not impact objective value performance
β = 1.0
tmax = 1000
m = Int8(15)
n_conv_thread = 1
n_conv_global = 10

file_name = "/home/tellocam/CSE/HeuristicOptimization/ProgEx2/code ants/data/datasets/inst_competition/heur050_n_300_m_19207.txt"

current_SPSOL = readSPSolutionFile(file_name)
current_result, result_all_objectives = AntColonySystemAlgorithm!(current_SPSOL, tmax, m, n_conv_thread, n_conv_global, α, β, μ, q0)

file_name_save = "output.txt"
folder_path_save = "/home/tellocam/CSE/HeuristicOptimization/ProgEx2/code ants/data/solutions"

# Combine the folder path and file name
file_path = joinpath(folder_path_save, file_name_save)

# Open the file in write mode
file = open(file_path, "w")

# Write the vector to the file
write(file, join(result_all_objectives, '\n'))

# Close the file
close(file)

println("Vector saved to: $file_path")