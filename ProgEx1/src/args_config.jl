using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--algo_name", "--algo"
        help = "Name of the used Algorithm"
        arg_type = String
        default = nothing
        required = true
    end

    @add_arg_table s begin
        "--fuse_best", "-f"
        help = "Fuse best clusters"
        arg_type = Bool
        default = true
    end

    @add_arg_table s begin
        "--swap_best", "-s"
        help = "Swap best clusters"
        arg_type = Bool
        default = true
    end

    @add_arg_table s begin
        "--init_cluster_size", "-i"
        help = "Initial cluster size"
        arg_type = Int
        default = 10
    end

    @add_arg_table s begin
        "--max_iter", "-m"
        help = "Maximum number of iterations"
        arg_type = Int
    end

    @add_arg_table s begin
        "--nr_shaking_meths", "-n"
        help = "Number of shaking methods"
        arg_type = Int
    end

    @add_arg_table s begin
        "--revisit_swap", "-r"
        help = "Revisit swap"
        arg_type = Bool
    end

    @add_arg_table s begin
        "--vnd", "-v"
        help = "Variable neighborhood descent option in GRASP"
        arg_type = Bool
    end

    @add_arg_table s begin
        "--random", "--rand"
        help = "Random option in SNS"
        arg_type = Bool
    end

    return parse_args(s)

end

function assign_variables(parsed_args::Dict{String, Any})
    variables = []  # Initialize an empty list to store variables

    # Specify the order in which variables should be pushed into the list
    ordered_keys = ["algo_name", "fuse_best", "swap_best", "init_cluster_size", "max_iter", "nr_shaking_meths", "revisit_swap", "vnd", "random"]

    for key in ordered_keys
        if haskey(parsed_args, key) && !isnothing(parsed_args[key])
            var_name = Symbol(key)
            @eval const $var_name = $(parsed_args[key])
            push!(variables, var_name)
        end
    end

    return variables
end

cmd_args = assign_variables(parse_commandline())

print(cmd_args, "\n")