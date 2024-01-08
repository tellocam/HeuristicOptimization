include("ds.jl")
include("const.jl")
include("move_ops.jl")

using Base.Threads

mutable struct Population
    G::SPSolution
    N::Int #number of individuals
    encodings::Matrix{Int} #each column gives for each vertex the number of the splex it is in
    fitnesses::Vector{Float64}
    obj_vals::Vector{Float64}
end

function init_pop(G, N)
    pop = Population(copy(G), N, zeros(G.n, N), zeros(N), zeros(N))
    for i in 1:N
        rd_const!(G)
        improve = true
        clusters = find_clusters(G)
        while improve
            clusters, improve = fuse_rd!(G, clusters)
        end
        pop.encodings[:,i] = find_clusters(G)
    end
    return pop
end

function encoding_to_sol!(pop, i) #makes pop.G.A into the matrix corresponding to encoding number i
    initialize!(pop.G)
    clusters = pop.encodings[:,i]
    #fully connect all the clusters (cliquify)
    for node in 1:pop.G.n
        my_cluster = clusters[node]
        for other in node+1:pop.G.n
            if clusters[other] == my_cluster
                pop.G.A[min(node,other),max(node,other)] = 1
            end
        end
    end
    sparsen!(pop.G)
end


function eval_pop!(pop, selection_pressure)
    for i in 1:pop.N
        encoding_to_sol!(pop, i)
        pop.obj_vals[i] = calc_objective(pop.G) #before scaling and fitness
    end
    gmin = minimum(pop.fitnesses)
    gbar = sum(pop.fitnesses) / length(pop.fitnesses)
    a = (selection_pressure * gbar - gbar) / (gmin - gbar)
    b = a * gbar - gbar 
    for i in 1:pop.N
        pop.fitnesses[i] = a * pop.obj_vals[i] - b
    end
end

function select(pop, selected_percentage, n_elites)
    N_selected = Int(selected_percentage * pop.N)
    pop2 = Population(pop.G, N_selected, zeros(pop.G.n, N_selected), zeros(N_selected), zeros(N_selected))
    tot_fit = sum(pop.fitnesses)
    probs = pop.fitnesses ./ tot_fit
    n_chosen = 0
    if n_elites > 0
        elite = sortperm(pop2.fitnesses, rev=true)[1:n_elites]
    end
    while n_chosen < N_selected
        for i in 1:pop.N
            if n_elites > 0 && (i in elite)
                n_chosen += 1
                if n_chosen > N_selected
                    break
                end
                pop2.encodings[:,n_chosen] = copy(pop.encodings[:,i])
                pop2.fitnesses[n_chosen] = pop.fitnesses[i]
            else
                rd = rand(Float64)
                if rd < probs[i] #this individual is selected
                    n_chosen += 1
                    if n_chosen > N_selected
                        break
                    end
                    pop2.encodings[:,n_chosen] = copy(pop.encodings[:,i])
                    pop2.fitnesses[n_chosen] = pop.fitnesses[i]
                end
            end
        end
    end
    return pop2
end

function recombine!(pop, overlap, method)
    N_new_gen = pop.N - Int(floor(overlap*pop.N))
    new_gen = zeros(pop.G.n, N_new_gen)
    if method == 1
        #1 point crossover
        for i in 1:N_new_gen
            valid = false
            parent1 = 1
            parent2 = 1
            while !valid
                parent1 = rand(1:pop.N)
                parent2 = rand(1:pop.N)
                valid = parent1!=parent2
            end
            crossover = rand(1:pop.G.n-1)
            child = [pop.encodings[1:crossover, parent1]; pop.encodings[crossover+1:pop.G.n, parent2]]
            new_gen[:,i] = child
        end
        pop.encodings = new_gen
        pop.N = N_new_gen
    elseif method ==2
        #uniform crossover
        for i in 1:N_new_gen
            valid = false
            parent1 = 1
            parent2 = 1
            while !valid
                parent1 = rand(1:pop.N)
                parent2 = rand(1:pop.N)
                valid = parent1!=parent2
            end
            for j in 1:pop.G.n
                if j %2 == 0
                    new_gen[j,i] = pop.encodings[j][parent1]
                else
                    new_gen[j,i] = pop.encodings[j][parent2]
                end
            end
        end
        pop.encodings = new_gen
        pop.N = N_new_gen
    else
        error("not a valid method for recombination")
    end
end

function mutate!(pop, overlap)
    for i in 1:pop.N
        for j in 1:pop.G.n
            rd = rand(Float64)
            if rd < 1/pop.G.n #mutate this gene
                pop.encodings[j,i] = rand(1:maximum(pop.encodings[:,i])+1) #put this vert to another s-plex or it's own splex
            end
        end
    end
end

function replace!(pop, pop2, overlap)
    new_encodings = zeros(pop.G.n, pop.N)
    #from last generation
    n_survivors = Int(floor(overlap*pop.N))
    for i in 1:n_survivors
        best = argmax(pop.fitnesses)
        new_encodings[:,i] = pop.encodings[:,best]
        pop.fitnesses[i] = 0
    end
    for i in 1:pop2.N 
        new_encodings[:, i+n_survivors] = pop2.encodings[:,i]
    end
    pop.encodings = new_encodings
end

function GA(G::SPSolution, N::Int, T::Int, overlap::Float64, selected_percentage, recomb_meth, n_elites, selection_pressure)
    t = 0
    pop = init_pop(G, N)
    eval_pop!(pop, selection_pressure)
    while t < T
        t = t + 1
        pop2 = select(pop, selected_percentage, n_elites)
        recombine!(pop2, overlap, recomb_meth)
        mutate!(pop2, overlap)
        replace!(pop, pop2, overlap)
        tstart = time()
        eval_pop!(pop, selection_pressure)
    end
    winner = argmax(pop.fitnesses)
    encoding_to_sol!(pop, winner)
    return pop.G
end

