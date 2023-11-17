using LinearAlgebra

struct Instance
    s::Int64
    n::Int64
    m::Int64
    l::Int64
    A0::Symmetric{Int8, Matrix{Int8}}  # initial adjacency matrix
    A::Symmetric{Int8, Matrix{Int8}}   # current adjacency matrix
    W::Symmetric{Int8, Matrix{Int8}}   # weight matrix
    cf_actual::Int64
    cf_min::Int64 # Minimal cost so far
end



function readGraphFile(file_path_rel::AbstractString)
    # read file
    # Construct the absolute path by combining the script's directory with the relative path
    script_dir = @__DIR__
    file_path = joinpath(script_dir, file_path_rel)
    content = read(file_path, String)
    lines = split(content, '\n')
    
    # Parse the first line to get the number of nodes, edges, and lines
    metadata = split(lines[1], ' ')
    s, n, m, l = parse.(Int8, metadata[1:4])

    # Initialize adjacency and weight matrices
    A = zeros(Int8, n, n)
    W = zeros(Int8, n, n)

    # Parse the remaining lines to populate the matrices
    for line in lines[2:end]
        if !isempty(line)
            vals = split(line, ' ')
            i, j, edge_present, weight = parse.(Int, vals)
            
            A[i, j] = edge_present
            W[i, j] = weight

        end
    end

    # make matrices symmetric thereby it doesnt matter if we addres edge by i,j or j,i
    A0 = Symmetric(A)
    W0 = Symmetric(W)
    G = Instance(s, n, m, l, A0, copy(A0), W0, typemax(Int), typemax(Int)) # costs initialized to max
    
    return G
end

function deltaEval(G::Instance, i, j) #TODO
    modifiedA = copy(G.A)
    modifiedA[i,j] = abs(G.A[i,j] - 1) # flip 1->0 or 0->1

    if G.A[i,j] # check if edge is present initially
        added_cost = -G.W[i,j] # deduct cost of edge if yes
    else # add cost if edge is not present
        added_cost = G.W[i,j]
    end

    deltaCost = G.cf_actual + added_cost
    return Instance(G.s, G.n, G.m, G.l, G.A0, modifiedA, G.W, deltaCost, G.cf_min)
end

function det_constr(G::Instance)
    G.A = zeros(G.n,G.n)
    for i in 1:G.n
        for j in i:G.n
            if G.A0[i,j]
                legal = is_legal(G, i, j) #check if adding makes s-plex
                cost_old = cost(G)
                G.A[i,j] = 1
                better = cost_old > cost(G) #check if adding makes f better
                G.A[i,j] = 0
                if legal && better
                    G.A[i,j] = 1
                end
            end
        end
    end
    return G
end

function cost(G)
    return sum(G.W * (abs.(G.A - G.A0))) # TODO: make this operation right. element-wise absolute of the difference. then element-wise multiplication. then sum of entries. Use symmetry.
end

function is_legal(G::Instance, i, j)
    G.A[i,j] = 1
    subgraph = connected_subgraph(G, i) # which nodes are connected to i (directly or indirectly)
    size = sum(subgraph) # how many points are now connected to i

    min_deg = G.n # minimal degree in subgraph
    for k in 1:G.n
        if subgraph[k]
            min_deg = min(min_deg, degree(G, k))
        end
    end

    if size - min_deg > G.s # adding the edge is illegal
        G.A[i,j] = 0
        return false
    end
    return true
end

function connected_subgraph(G::Instance, i)
    visited = zeros(G.n)
    dfs(G, i, visited)
    return visited
end

function dfs(G::Instance, i, visited) #depth first search
    if !visited[i]
        visited[i] = true
        for neighbor in G.A[i,:]
            if neighbour
                dfs(graph, neighbor, visited)
            end
        end
    end
end

function degree(G::Instance, i) #returns degree of node i in G.A
    return sum(G.A[i,:])
end



# Provide the path to your instance file
file_path = "datasets/inst_test/heur001_n_10_m_31.txt"

# Call the function to generate matrices
G_test = readGraphFile(file_path)

# # Display the matrices
# println("Adjacency Matrix:")
display(G_test.A)
display(degree(G_test, 3))

display(G_test.A)
G_test = det_constr(G_test)
display(G_test.A)

deltaEval(G_test, 4,8)

# println("\nWeight Matrix:")
# display(G_test.W)
