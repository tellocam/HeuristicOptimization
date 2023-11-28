using ArgParse

function get_args()

    parser = ArgParser()

    @add_arg_table parser begin
        "--algo"         | "vnd!" => algo_name | help("Name of the Used Algorithm")                
        "--fuse"         | false => fuse_best | help("Fuse best clusters in all Algorithms")
        "--swap"         | false => swap_best | help("Swap best clusters in all Algorithms")
        "--cluster"      | 0     => init_cluster_size | help("Initial cluster size in all Algorithms")
        "--iter"         | 10   => max_iter | help("Maximum number of iterations in GRASP and GVNS")
        "--shaking"      | 2     => nr_shaking_meths | help("Number of shaking methods in GVNS")
        "--revisit"      | false => revisit_swap | help("Revisit swap in SNS and GRASP")
        "--vnd"          | false => vnd | help("Variable neighborhood descent in GRASP")
        "--rand"         | false => random | help("Random in SNS")
    end

    parse_args!(parser)
    
    return  algo_name, 
            fuse_best, swap_best,
            init_cluster_size, max_iter, 
            nr_shaking_meths, revisit_swap, 
            vnd, random
end
