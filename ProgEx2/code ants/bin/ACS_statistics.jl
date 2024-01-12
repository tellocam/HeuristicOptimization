include("../src/ACS_fun.jl")
include("../bin/ACS.jl")

function run_algorithm_for_files(data_folder_path, solutions_folder_path, output_file_path, num_runs)
    open(output_file_path, "w") do file
        # Write header line
        write(file, "file; obj_val \n")

        files = readdir(data_folder_path, join=false)

        for run in 1:num_runs
            for i in 1:length(files)
                read_file_name = joinpath(data_folder_path, files[i])
                current_SPSOL = readSPSolutionFile(read_file_name)

                et1 = time()
                current_result = AntColonySystemAlgorithm!(current_SPSOL, tmax, m, n_conv_thread, n_conv_global, α, β, μ, q0)
                et2 = time() - et1

                write(file, string(i-1, ";", current_result[1].obj_val, "\n"))
            end
        end
    end
end

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

# Run the algorithm for each file in sequence for num_runs times
run_algorithm_for_files("/home/tellocam/CSE/HeuristicOptimization/ProgEx2/code ants/data/datasets/inst_test_random",
                        "/home/tellocam/CSE/HeuristicOptimization/ProgEx2/code ants/data/solutions",
                        "/home/tellocam/CSE/HeuristicOptimization/ProgEx2/code ants/data/solutions/statistics_solution.txt",
                        10)
