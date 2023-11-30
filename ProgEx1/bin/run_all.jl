include("../src/ds.jl")
include("../src/const.jl")
include("../src/move_ops.jl")
include("../src/metaheuristics.jl")


using ArgParse

###selecting algo
valid_algos = ["lsw", "lfu", "vnd", "sns", "grasp", "gvns"]
algo_name = ARGS[1]
if algo_name in valid_algos
    #all good
else
    println("provided argument is not a valid algorithm")
end

###preparing all the file names
files = []
files_test = readdir("../data/datasets/inst_test/")
for file in files_test
    push!(files,"../data/datasets/inst_test/" * file)
end
files_tuning = readdir("../data/datasets/inst_tuning/")
for file in files_tuning
    push!(files,"../data/datasets/inst_tuning/" * file)
end
files_comp = readdir("../data/datasets/inst_competition/")
for file in files_comp
    push!(files,"../data/datasets/inst_competition/" * file)
end




###selecting which files to run on
from_file_nr = parse(Int,ARGS[2])
to_file_nr = parse(Int,ARGS[3])
files = files[from_file_nr:to_file_nr]


###Taking the other params from console:
random = parse(Bool,ARGS[4])
init_cluster_size = parse(Int,ARGS[5])
fuse_best = parse(Bool,ARGS[6])
swap_best = parse(Bool,ARGS[7])
nr_nodes_shaking1 = parse(Int,ARGS[8])
nr_nodes_shaking2 = parse(Int,ARGS[9])
max_iter = parse(Int, ARGS[10])
vnd_grasp = parse(Bool, ARGS[11])
out_filename = ARGS[12]




#helper function

function write_res_line(file, params)
    for i in 1:length(params)-1
        write(file, string(params[i]) * ",")
    end
    write(file, string(params[length(params)]) * ",\n")
end


function run!(G, in_filename, out_file, algo_name, random::Bool, init_cluster_size::Int, fuse_best::Bool, swap_best::Bool, nr_nodes_shaking1, nr_nodes_shaking2, max_iter, vnd_grasp)
    tstart = time()
    random ? rd_const!(G, init_cluster_size) : det_const!(G, init_cluster_size)
    if algo_name == "lsw"
        local_search!(G, swap_best, "swap")
    elseif algo_name == "lfu"
        local_search!(G, fuse_best, "fuse")
    elseif algo_name == "sns"
        sns!(G, false, false)
    elseif algo_name == "vnd"
        vnd!(G, fuse_best, swap_best)
    elseif algo_name == "grasp"
        grasp!(G, fuse_best, swap_best, vnd_grasp, max_iter, init_cluster_size)
    elseif algo_name == "gvns"
        gvns!(G, fuse_best, swap_best, init_cluster_size, max_iter, nr_nodes_shaking1, nr_nodes_shaking2)
    end

    tend = time()
    ttime = tend - tstart
    obj_val = calc_objective(G)
    params = [in_filename, algo_name, random, SPARSEN, fuse_best, swap_best, init_cluster_size, nr_nodes_shaking1, nr_nodes_shaking2, vnd_grasp, ttime, obj_val]
    write_res_line(out_file, params)
    println("ran on "*in_filename*" with algo "*algo_name*" took "*string(ttime)*" s and found val: "*string(obj_val))  
end

open(out_filename, "a") do out_file
    write(out_file, "filename,algo,SPARSE,best_fuse,best_swap,init_cluster_size,nr_nodes_shaking1,nr_nodes_shaking2,max_iter,vnd_grasp,time,obj_val\n")
    for in_filename in files
        println("working on "*in_filename)
        G = readSPSolutionFile(in_filename)
        run!(G, in_filename, out_file, algo_name, random::Bool, init_cluster_size::Int, fuse_best::Bool, swap_best::Bool, nr_nodes_shaking1, nr_nodes_shaking2, max_iter, vnd_grasp)
        ind = 0
        strl = length(in_filename)
        for i in 1:strl # dont wanna deal with regex
            if in_filename[i] == 'h'
                ind = i
            end
        end
        writeSolution(G, "../data/solutions/"*in_filename[ind:length(in_filename)]*algo_name)
    end
end