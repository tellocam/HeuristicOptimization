include("../src/ACS_fun.jl")
include("../bin/ACS.jl")

num_trials = 30
instance_folder_path = "../data/datasets/inst_tuning_selected/"
data_folder_path = "../data"
num_files = 8


# # Example usage
# num_trials = 5  # Change this to the desired number of trials
# instance_folder_path = "../data/datasets/inst_tuning/"
# num_files = 1

# Define fixed values for parameters
α_values = [0.2, 0.25, 0.3, 0.35, 0.4]
μ_values = [0.2, 0.25, 0.3, 0.35, 0.4]
q0_values = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7]

# Generate all combinations
all_combinations = collect(Iterators.product(α_values, μ_values, q0_values))

# # Call the tuning function with the combinations
# best_params, best_avg_result = random_search_ACS_tuning_with_combinations(num_trials, all_combinations, instance_folder_path, num_files)

# # ... (rest of the code remains the same)


best_params, best_avg_result = random_search_ACS_tuning(num_trials, all_combinations, instance_folder_path, num_files)

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