include("ds.jl")
include("const.jl")
include("local_improve.jl")

#### VND ####
function vnd!(G::SPSolution)
    det_const!(G, 1)
    # initial cluster size does not seem to matter.
    # we use 1 to have the bulk of the work in the local search here 

    move_meths = [fuse_best!, swap_best!]
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

#### GRASP ####
function grasp!(G::SPSolution, eps::Int, max_iter::Int, init_cluster_size::Int, fuse_best::Bool, swap_best::Bool, revisit_swap::Bool)
    if max_iter == 0 # epsilon should hold here
        max_iter = typemax(Int)
    end
    if max_iter == 0 && eps == 0
        error("put either min improvement or max iter as stopping criterion")
    end
    initialize!(G)
    Gstar = copy(G)
    iter = 1

    while iter < max_iter
        println("$iter th iteration of random construction")
        ###randomized construction
        rd_const!(G, init_cluster_size) #init size does not seem to matter. max here so that rd construction has bigger influence
        ###local search
        #TODO tuning for the true/false parameters here
        fuse_to_max!(G, fuse_best)
        swap_to_max!(G, swap_best, revisit_swap)
        improvement = calc_objective(Gstar) < calc_objective(G)
        if improvement > 0
            Gstar = copy(G)
        end
        if eps > 0 && improvement < eps
            return Gstar
        end
        iter += 1
    end
    return Gstar
end