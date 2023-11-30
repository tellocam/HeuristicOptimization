include("../src/ds.jl")
include("../src/const.jl")
include("../src/move_ops.jl")
include("../src/metaheuristics.jl")

using ArgParse
valid_arguments = ["ini", "grasp"]

if ARGS[1] in valid_arguments
    # all good
else
    println("provided argument is not a valid algorithm")
end

if ARGS[1] == "ini"
    println("tuning for initial cluster size\n==========")
    filename = "../data/datasets/inst_tuning/heur055_n_300_m_5164.txt"

    G = readSPSolutionFile(filename)

    open("../data/tuning/initial_cluster_size", "w") do file
        write(file, "const_type,initial_cluster_size,cost_after_fuse,cost_after_cthens\n")

        println("=======\ndeterministic construction\n =========")
        for initial_size in 1:G.s+2 #+2 to make sure that after G.s nothing changes
            println("initial size $initial_size")
            write(file, "det,"*string(initial_size)*",")
            det_const!(G, initial_size)
            local_search!(G, true, "fuse")
            write(file, string(calc_objective(G))*",")
            cliquify_then_sparse!(G)
            write(file, string(calc_objective(G))*"\n")
        end

        println("=======\nrandom construction\n =========")
        nr_runs = 20
        for initial_size in 1:G.s+2
            println("initial size $initial_size")
            write(file, "rd,"*string(initial_size)*",")
            results = zeros(Int, nr_runs, 2)
            for run in 1:nr_runs
                println("run number $run")
                rd_const!(G, initial_size)
                local_search!(G, true, "fuse")
                results[run, 1] = calc_objective(G)
                cliquify_then_sparse!(G)
                results[run, 2] = calc_objective(G)
            end
            write(file, string(minimum(results[:,1]))*","*string(minimum(results[:,2]))*"\n")
        end
    end
end

if ARGS[1] == "grasp"
    println("tuning grasp for hyperparameters")
    files_tuning = readdir("../data/datasets/inst_tuning/")
        open("../data/tuning/grasp", "w") do file
            write(file, "filename,init_cluster_size,fuse_best,swap_best,swap_revisit,max_iter,eps,time,obj_val\n")
            for filename in [files_tuning[1], files_tuning[5], files_tuning[10], files_tuning[17]] #just take some, cant do all
                G = readSPSolutionFile("../data/datasets/inst_tuning/" * filename)

                fuse_best = false
                println("fuse first for file $filename")
                for init_cluster_size in [1, G.s]
                    for swap_best in [true]
                        for swap_revisit in [true]
                            for max_iter in [10, 40]
                                tstart = time()
                                grasp!(G,  max_iter, init_cluster_size, fuse_best, swap_best, swap_revisit, false)
                                tend = time()
                                write(file, filename * "," * string(init_cluster_size) * "," * string(fuse_best) * "," * string(swap_best) * "," * string(swap_revisit) * "," * string(max_iter) * "," * string(eps) * "," * string(tend-tstart) * "," * string(calc_objective(G)) *"\n")
                            end
                        end
                    end
                end

                fuse_best = true # here we need a small search space bc this is very slow
                println("fuse best for file $filename")
                for init_cluster_size in [1,G.s]
                    tstart = time()
                    grasp!(G, 5, init_cluster_size, fuse_best, true, true, false)
                    tend = time()
                    write(file, filename * "," * string(init_cluster_size) * ",true,true,true,5,0," * string(tend-tstart) * "," * string(calc_objective(G)) * "\n")
                end
            end
        end
    end