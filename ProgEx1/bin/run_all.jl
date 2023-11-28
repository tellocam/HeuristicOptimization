include("../src/ds.jl")
include("../src/const.jl")
include("../src/move_ops.jl")
include("../src/metaheuristics.jl")

files_comp = readdir("../data/datasets/inst_competition/")
files_tuning = readdir("../data/datasets/inst_tuning/")
files_test = readdir("../data/datasets/inst_test/")

using ArgParse

valid_algos = ["vnd", "sns", "grasp", "gvns"]
algo_name = ARGS[1]

if algo_name in valid_algos
    #all good
else
    println("provided argument is not a valid algorithm")
end

####TODO: make the manual entry of values better. now you have to do it at the commented places.

# algo_name = "vnd" #give algo name

function run!(G, in_filename, out_file)
    
    if algo_name == "sns"
        tstart = time()
        sns!(G, false, 100, false, true, true)
        tend = time()
        write(out_file, in_filename*",false,100,false,true,true,"*string(tend-tstart)*","*string(calc_objective(G))*"\n") # put parameters here
        println("wrote "*in_filename*",false,100,false,true,true,"*string(tend-tstart)*","*string(calc_objective(G))*"\n")
    
    elseif algo_name == "vnd"
        tstart = time()
        vnd!(G, false, false, 100)
        tend = time()
        write(out_file, in_filename*",false,false,"*string(tend-tstart)*","*string(calc_objective(G))*"\n") # put parameters here
        println("wrote "*in_filename*",false,false,"*string(tend-tstart)*","*string(calc_objective(G))*"\n")
    end
    
end

open("../data/tuning/run_all_"*algo_name, "w") do file
    #write(file, "filename,random,ini_cluster_size,fuse_best,swap_best,swap_revisit,time_"*algo_name*",val_"*algo_name) #put parameters here
    write(file, "filename,best_fuse,best_swap,time_"*algo_name*",val_"*algo_name) #put parameters here
    for filename in files_comp
        println("working on "*filename)
        rootfilename = "../data/datasets/inst_competition/" * filename
        G = readSPSolutionFile(rootfilename)
        run!(G, filename, file)
    end
    for filename in files_tuning
        println("working on "*filename)
        rootfilename = "../data/datasets/inst_tuning/" * filename
        G = readSPSolutionFile(rootfilename)
        run!(G, filename, file)
    end
    for filename in files_test
        println("working on "*filename)
        rootfilename = "../data/datasets/inst_test/" * filename
        G = readSPSolutionFile(rootfilename)
        run!(G, filename, file)
    end
end