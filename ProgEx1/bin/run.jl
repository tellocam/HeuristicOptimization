include("../src/ds.jl")
include("../src/const.jl")
include("../src/move_ops.jl")
include("../src/metaheuristics.jl")
include("../src/args_config.jl")

cmd_args = assign_variables(parse_commandline())

files_comp = readdir("../data/datasets/inst_competition/")
files_tuning = readdir("../data/datasets/inst_tuning/")
files_test = readdir("../data/datasets/inst_test/")
  
valid_algos = ["grasp!", "vnd!", "sns!", "gvns!"]
!if algo_name in valid_algos
    usedAlgorithm = getfield(Main, Symbol(algo_name)) # Assign function name string as function to variable
else
    println("provided argument is not a valid algorithm")
end

function run!(G, hotFunc::Function, in_filename, out_file, args...)

    tStart = time()
    hotFunc(G, args...)
    tElapsed = tStart - time()

    args_str = join(map(string, args), ",") # Put all elements of args... in a string to write things
    write(out_file, in_filename * "," * args_str * "," * string(tElapsed) * "," * string(calc_objective(G)) * "\n")
    println("wrote ", in_filename, ",", args_str, ",", string(tElapsed), ",", string(calc_objective(G)), "\n")

end

open("../data/tuning/run_all_" * algo_name, "w") do file
    #write(file, "filename,random,ini_cluster_size,fuse_best,swap_best,swap_revisit,time_" * algo_name * ",val_" * algo_name) #put parameters here
    write(file, "filename,best_fuse,best_swap,time_" * algo_name * ",val_" * algo_name) #put parameters here
    
    # Select a specific filename from files_comp
    filename = files_comp[1]  # Change the index as needed
    
    println("working on " * filename)
    rootfilename = "../data/datasets/inst_competition/" * filename
    G = readSPSolutionFile(rootfilename)
    run!(G, filename, file, cmd_args)
end

# #### SNS #### G, 4 bools, 1 int
# function sns!(G::SPSolution,
# random::Bool, fuse_best::Bool, swap_best::Bool, revisit_swap::Bool, init_cluster_size::Int)

# end

# #### VND #### G, 2 Bools, 1 int
# function vnd!(G::SPSolution, fuse_best::Bool, swap_best::Bool, init_cluster_size)

# end

# #### GRASP #### G, 4 Bools, 2 Ints
# function grasp!(G::SPSolution, fuse_best::Bool, swap_best::Bool, revisit_swap::Bool, vnd::Bool, max_iter::Int, init_cluster_size::Int)

# end

# #### GVNS #### G, 2 Bools, 3 Ints
# function gvns!(G::SPSolution, fuse_best::Bool, swap_best::Bool, init_cluster_size::int, max_iter, nr_shaking_meths)# pass list of shaking moves

# fuse_best::Bool, swap_best::Bool, init_cluster_size::Int, max_iter::Int, nr_shaking_meths::Int,
# revisit_swap::Bool, vnd::Bool, random::Bool