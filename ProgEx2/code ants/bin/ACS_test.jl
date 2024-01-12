include("../src/ACS_fun.jl")
include("../bin/ACS.jl")

test_data_folder_path = "/home/tellocam/CSE/HeuristicOptimization/ProgEx2/code ants/data/datasets/inst_test"
solutions_folder_path = "/home/tellocam/CSE/HeuristicOptimization/ProgEx2/code ants/data/solutions"
G_solved = Vector()

# Parameters obtained by "advanced" parameter tuning
α = 0.3
μ = 0.35
q0 = 0.3

# Parameters that are set because they are likely to not impact objective value performance
β = 2.0
tmax = 1000
m = Int8(15)
n_conv_thread = 1
n_conv_global = 5

# Create a single text file for the entire loop
output_file_path = joinpath(solutions_folder_path, "all_solutions_test.txt")
open(output_file_path, "w") do file
    # Write header line
    write(file, "n, m, s, obj_val, time \n")

    files = readdir(test_data_folder_path, join=false)
    for i in 1:length(files)
        read_file_name = joinpath(test_data_folder_path, files[i])
        current_SPSOL = readSPSolutionFile(read_file_name)
        et1 = time()
        current_result = AntColonySystemAlgorithm!(current_SPSOL, tmax, m, n_conv_thread, n_conv_global, α, β, μ, q0)
        et2 = time() - et1
            write(file, string(current_result.n, ", ", current_result.m, ", ", current_result.s, ", ", current_result.obj_val,", ", et2,  "\n"))
    end
end
