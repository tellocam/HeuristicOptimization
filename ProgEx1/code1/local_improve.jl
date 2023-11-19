include("ds.jl")
include("const.jl")
using Random
using StatsBase
using Graphs
using MHLib
using ArgParse

# Functionality of local_improve with other MHLib components was successful!!
# However, the flip we want to perform that actually improves the cost, does not happen.
# Why? Why?
function MHLib.Schedulers.local_improve!(G::SPSolution, par::Int, result::Result)
    for i in 1:G.n
        for j in i:G.n
            if G.A0[i,j] && !G.A[i,j]
                obj_val_old = G.obj_val
                valid = flipij(G, i, j)
                if !valid
                    flipij(G, i, j) # take back
                else
                    result.changed = true
                    return #first improvement strategy
                end
                # if the change was valid we have an improvement with certainty so keep it
            end
        end
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
    settings_new_default_value!(MHLib.settings_cfg, "ifile", "datasets/inst_test/heur002_n_100_m_3274.txt")
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

