include("../src/ACS_fun.jl")
include("../bin/ACS.jl")

num_trials = 100
folder_path = "../data/datasets/inst_test_tuning/"
num_files = 2

best_params, best_avg_result = random_search_ACS_tuning(num_trials, folder_path, num_files)

println(best_params)