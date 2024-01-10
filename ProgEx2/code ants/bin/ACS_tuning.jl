include("../src/ACS_fun.jl")
include("../bin/ACS.jl")

num_trials = 50
instance_folder_path = "../data/datasets/inst_test_tuning/"
data_folder_path = "../data"
num_files = 1

best_params, best_avg_result = random_search_ACS_tuning(num_trials, instance_folder_path, num_files)

# Append num_trials, num_files, best_params, and best_avg_result to the text file
output_file = joinpath(data_folder_path, "reported_parameters.txt")
open(output_file, "a") do file
    println(file, "\n---------------------------")
    println(file, "Number of Trials: $num_trials")
    println(file, "Number of Files: $num_files")
    println(file, "\nBest Parameters:")
    println(file, best_params)
    println(file, "\nBest Average Result:")
    println(file, best_avg_result)
end

println("Results have been written to $output_file")