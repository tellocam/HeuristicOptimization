include("../src/ACS_fun.jl")
include("../bin/ACS.jl")

competition_data_folder_path = "/home/tellocam/CSE/HeuristicOptimization/ProgEx2/code ants/data/datasets/inst_competition"
solutions_folder_path = "/home/tellocam/CSE/HeuristicOptimization/ProgEx2/code ants/data/solutions"
G_solved = Vector()

# Parameters obtained by "advanced" parameter tuning
α = 0.3
μ = 0.35
q0 = 0.3

# Parameters that are set, bcs likely to not impact objective value performance
β = 2.0
tmax = 1000
m = Int8(15)
n_conv_thread = 1
n_conv_global = 5

files = readdir(competition_data_folder_path, join=false)
# print(files)
for i in 1:length(files)

    read_file_name = joinpath(competition_data_folder_path, files[i])
    current_SPSOL = readSPSolutionFile(read_file_name)
    current_result = AntColonySystemAlgorithm!(current_SPSOL, tmax, m, n_conv_thread, n_conv_global, α, β, μ, q0)
    writeSolution(current_SPSOL, joinpath(solutions_folder_path, files[i]))
    
end



