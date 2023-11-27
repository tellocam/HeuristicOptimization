include("ds.jl")
include("const.jl")
include("move_ops.jl")

#### VND ####
function vnd!(G::SPSolution, fuse_best::Bool, swap_best::Bool)
    det_const!(G, 1)
    # initial cluster size does not seem to matter.
    # we use 1 to have the bulk of the work in the local search here 
    move_meths = []
    fuse_best ? move_methspush!(move_meths,fuse_best!) : push!(move_meths,fuse_first!)
    swap_best ? push!(move_meths,swap_best!) : push!(move_meths,swap_first!)
    I = 1
    while I < 3
        old_val = calc_objective(G)
        move_meths[I](G)
        if calc_objective(G) < old_val
            I = 1
        else
            I = I+1
        end
    end
    return G
end

function vnd_profiler!(G::SPSolution, fuse_best::Bool, swap_best::Bool) #see the fraction of the time used for calc of obj_val. indicates how useful delta_eval will be
    calc_time = 0
    fuse_time = 0
    swap_time = 0
    det_const!(G, 1)
    # initial cluster size does not seem to matter.
    # we use 1 to have the bulk of the work in the local search here 
    move_meths = []
    fuse_best ? move_methspush!(move_meths,fuse_best!) : push!(move_meths,fuse_first!)
    swap_best ? push!(move_meths,swap_best!) : push!(move_meths,swap_first!)
    I = 1
    totstart = time()
    while I < 3
        tstart = time()
        old_val = calc_objective(G)
        tend = time()
        calc_time += tend-tstart
        tstart2 = time()
        move_meths[I](G)
        tend2 = time()
        if I ==1
            fuse_time += tend2 - tstart2
        else
            swap_time += tend2 - tstart2
        end
        tstart = time()
        if calc_objective(G) < old_val
            I = 1
        else
            I = I+1
        end
        tend = time()
        calc_time += tend-tstart
    end
    totend = time()
    println("total time for calc of val: $calc_time")
    println("total time for fuse: $fuse_time")
    println("total time for swap: $swap_time")
    println("total time: $(totend-totstart)")
    return G
end

#### GRASP ####
function grasp!(G::SPSolution, max_iter::Int, init_cluster_size::Int, fuse_best::Bool, swap_best::Bool, revisit_swap::Bool, vnd::Bool)
    if max_iter < 2
        error("grasp not meaningful with max_iter < 2")
    end
    initialize!(G)
    Gstar = copy(G)
    iter = 1

    while iter <= max_iter
        println("grasp iteration $iter out of $max_iter")
        ###sns, random construction then local search
        #TODO tuning for the true/false parameters here
        if vnd
            G = vnd!(G, fuse_best, swap_best)
        else
            G = sns!(G, true, 100, fuse_best, swap_best, revisit_swap)
        end
        improvement = calc_objective(Gstar) - calc_objective(G)
        if improvement > 0
            Gstar = copy(G)
        end
        iter += 1
    end
    return Gstar
end


#### GVNS ####
function gvns!(G::SPSolution, max_iter, shaking_meths, fuse_best::Bool, swap_best::Bool)# pass list of shaking moves
    det_const!(G, G.s)
    vnd!(G, fuse_best, swap_best)
    println("found value $(calc_objective(G)) after first vnd")
    iter = 1
    while iter <= max_iter
        iter += 1
        k = 1
        Gprime = copy(G)
        shaking_meths[k](Gprime)
        vnd!(Gprime, fuse_best, swap_best)
        println("gvns iteration $(iter-1) out of $max_iter found value $(calc_objective(Gprime))")
        if calc_objective(Gprime) < calc_objective(G)
            G = copy(Gprime)
            k = 1
        else
            k += 1
        end
    end
    return G
end


#### SNS ####: sequential neighbourhood search
#custom method following from the specific problem structure. Close to VND
function sns!(G::SPSolution, random::Bool, init_cluster_size::Int, fuse_best::Bool, swap_best::Bool, revisit_swap::Bool)
    random ? rd_const!(G, init_cluster_size) : det_const!(G, init_cluster_size)
    fuse_to_max!(G, fuse_best)
    swap_to_max!(G, swap_best, revisit_swap)
    cliquify_then_sparse!(G)
    return G
end


#### CUSTOM ####
#metaheuristic that tries to use the locally strongly connected Graphs
function custom_MH!(G::SPSolution, max_iter)
    #deterministic solution
    tstart = time()
    sns!(G, false, 100, false, true, true)# fuse first, should be good for locally strongly connected
    Gdet = copy(G)
    tend = time()
    Tdet = tstart - tend
    println("obj val with det: $(calc_objective(G))")

    #random solution
    tstart = time()
    sns!(G, true, 100, false, true, true)# fuse first, should be good for locally strongly connected
    Grd = copy(G)
    tend = time()
    Trd = tstart - tend
    println("obj val with rd: $(calc_objective(G))")

    fast = false
    if Tdet < 0.7*Trd #TODO: this detection is not good. 
        fast = true
        println("Used fast algo for locally strongly connected graph")
        G = Gdet
        return G, fast
    end
    print("Use slow algo for seemingly randomly connected graph")
    grasp!(G, max_iter, 100, false, true, true, true)

    return G, fast
end