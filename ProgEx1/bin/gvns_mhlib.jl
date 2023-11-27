include("../src/ds.jl")
include("../src/const.jl")
include("../src/local_improve.jl")
include("../src/mhlib_fct.jl")

function splex_vnd(filename::AbstractString, args=ARGS)
    println("splex vnd solver")

    # We set some new default values for parameters and parse all relevant arguments
    settings_new_default_value!(MHLib.Schedulers.settings_cfg, "mh_titer", 1000)
    settings_new_default_value!(MHLib.settings_cfg, "ifile", filename)
    parse_settings!([MHLib.Schedulers.settings_cfg, splex_settings_cfg], args)
    println(get_settings_as_string())
        
    G = readSPSolutionFile(settings[:ifile])

    initialize!(G)

    # fuse neighbourhood and swap neighbourhood
    alg = GVNS(G, [MHMethod("con", construct!, 0)],
    [MHMethod("li1", local_improve!, 0), MHMethod("li2", local_improve!, 1)],[MHMethod("sh1", construct!, 1)], 
    consider_initial_sol = true)
    run!(alg)
    method_statistics(alg.scheduler)
    main_results(alg.scheduler)
    check(sol)
    return sol
end

splex_vnd("../data/datasets/inst_competition/heur051_n_300_m_20122.txt")