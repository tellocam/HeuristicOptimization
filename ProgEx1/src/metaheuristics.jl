include("ds.jl")
include("const.jl")
include("move_ops.jl")
include("move_ops_delta.jl")


#### local search ####

function local_search!(G::SPSolution, best, move)
    if best
        if move == "swap"
            fct = swap_best!
        else
            fct = fuse_best!
        end
    else
        if move == "swap"
            fct = swap_first!
        else
            fct = fuse_first!
        end
    end
    changed = true
    while changed
        changed = fct(G)
    end
end


#### VND ####
function vnd!(G::SPSolution, fuse_best::Bool, swap_best::Bool)
    # initial cluster size does not seem to matter.
    # we use 1 to have the bulk of the work in the local search here 
    move_meths = []
    fuse_best ? push!(move_meths,fuse_best!) : push!(move_meths,fuse_first!)
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
    cliquify_then_sparse!(G)
    return G
end

function vnd_delta!(G::SPSolution) #only for fuse first and swap first
    move_meths = [fuse_first_delta!, swap_first_delta!]
    I = 1
    obj_value = calc_objective(G) # only one regular obj_val calculation
    while I < 3
        old_val = obj_value
        obj_value += move_meths[I](G)
        if obj_value < old_val
            I = 1
        else
            I = I+1
        end
    end
    cliquify_then_sparse!(G)
    println("calculated obj value of delta evaluation is: $obj_value")
end

function vnd_profiler!(G::SPSolution, fuse_best::Bool, swap_best::Bool) #see the fraction of the time used for calc of obj_val. indicates how useful delta_eval will be
    calc_time = 0
    fuse_time = 0
    swap_time = 0
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
function grasp!(G::SPSolution, fuse_best::Bool, swap_best::Bool, vnd::Bool, max_iter::Int, init_cluster_size::Int)
    if max_iter < 2
        error("grasp not meaningful with max_iter < 2")
    end
    initialize!(G)
    Gstar = copy(G)
    iter = 1

    while iter <= max_iter
        ###sns, random construction then local search
        rd_const!(G, init_cluster_size)
        if vnd
            G = vnd!(G, fuse_best, swap_best)
        else
            G = sns!(G, fuse_best, swap_best)
        end
        improvement = calc_objective(Gstar) - calc_objective(G)
        println("grasp iteration $iter out of $max_iter, improvement: $improvement")
        if improvement > 0
            Gstar = copy(G)
        end
        iter += 1
    end
    return Gstar
end


#### GVNS ####
function gvns!(G::SPSolution, fuse_best::Bool, swap_best::Bool, init_cluster_size, max_iter, nr_nodes_shaking1, nr_nodes_shaking2)# pass list of shaking moves
        
    det_const!(G, init_cluster_size)
    Gprime = SPSolution(G.s, G.n, G.m, G.l, zeros(Bool, G.n, G.n),zeros(Bool, G.n, G.n), zeros(Bool, G.n, G.n), typemax(Int), false)
    copy_sol!(Gprime, G)
    vnd!(G, fuse_best, swap_best)
    println("found value $(calc_objective(G)) after first vnd")
    shaking1!(G) = disconnect_rd_n!(G, nr_nodes_shaking1)
    shaking2!(G) = disconnect_rd_n!(G, nr_nodes_shaking2)
    shaking_meths = [shaking1!, shaking2!] # take all shaking methods from 1 to nr_shaking_meths
    iter = 1
    while iter <= max_iter
        println("gvns iteration $(iter) out of $max_iter")
        iter += 1
        k = 1
        while k < 3
            writeAdjacency(Gprime, "../data/matrices_for_inspection/Gp_before_shak", false)
            writeAdjacency(G, "../data/matrices_for_inspection/G_before_shak", false)
            shaking_meths[k](Gprime) #list of functions handed the argument GPrime
            writeAdjacency(Gprime, "../data/matrices_for_inspection/Gp_after_shak", false)
            writeAdjacency(G, "../data/matrices_for_inspection/G_after_shak", false)
            vnd!(Gprime, fuse_best, swap_best)
            if calc_objective(Gprime) < calc_objective(G)
                copy_sol!(G, Gprime)
                k = 1
            else
                k += 1
            end
        end
    end
    return G
end


#### SNS ####: sequential neighbourhood search
#custom method following from the specific problem structure. Close to VND
function sns!(G::SPSolution, fuse_best::Bool, swap_best::Bool)
    local_search!(G, fuse_best, "fuse")
    local_search!(G, swap_best, "swap")
    cliquify_then_sparse!(G)
    return G
end







#= OLD...here we tried to make an algorithm that detects the type of graph and uses the appropriate algorithm

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
=#