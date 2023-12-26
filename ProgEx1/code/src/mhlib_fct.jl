include("ds.jl")
include("const.jl")
include("move_ops.jl")

function MHLib.Schedulers.local_improve!(G::SPSolution, par::Int, result::Result)
    if par == 0
        result.changed = fuse_best!(G)
    else
        result.changed = swap_best!(G)
    end
end

const splex_settings_cfg = ArgParseSettings()
@add_arg_table! splex_settings_cfg begin
    "--splex"
        help = "none, only bc copied from demo"
        arg_type = Int
        default = 3
end

function solve_splex(args=ARGS)
    println("splex problem algo")

    # We set some new default values for parameters and parse all relevant arguments
    settings_new_default_value!(MHLib.Schedulers.settings_cfg, "mh_titer", 1000)
    settings_new_default_value!(MHLib.settings_cfg, "ifile", "../data/datasets/inst_test/heur002_n_100_m_3274.txt")
    parse_settings!([MHLib.Schedulers.settings_cfg, splex_settings_cfg], args)
    println(get_settings_as_string())
        
    G = readSPSolutionFile(settings[:ifile])

    alg = GVNS(G, [MHMethod("con", construct!, 0)],
        [MHMethod("li1", local_improve!, 1)],[MHMethod("li1", local_improve!, 1)], 
        consider_initial_sol = true)
    run!(alg)
    method_statistics(alg.scheduler)
    main_results(alg.scheduler)
    check(G)
    return G
end