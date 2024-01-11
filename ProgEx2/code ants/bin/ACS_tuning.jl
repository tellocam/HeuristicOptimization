include("../src/ACS_fun.jl")
include("../bin/ACS.jl")


instance_folder_path = "../data/datasets/inst_tuning_selected/"
data_folder_path = "../data"


num_trials = 30 # number of combinations tested
num_files = 8 # number of files selected randomly out of folder. if 8 then all files!
α_values = [0.2, 0.25, 0.3, 0.35, 0.4] # discrete value list for parameters
μ_values = [0.2, 0.25, 0.3, 0.35, 0.4]
q0_values = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7]

# Generate combinations
all_combinations = collect(Iterators.product(α_values, μ_values, q0_values))
println(length(all_combinations)) #prints the number of combinations that are available of which num_trials will be tested

# # Call tuning function with combinations
best_params, best_avg_result = random_search_ACS_tuning(num_trials, all_combinations, instance_folder_path, num_files)

# Append num_trials, num_files, best_params, and best_avg_result to text file
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