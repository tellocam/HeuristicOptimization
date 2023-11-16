using LinearAlgebra

struct graphData
    n::Int8
    m::Int8
    l::Int8
    A0::Symmetric{Int8, Matrix{Int8}}  # initial adjacency matrix
    A::Symmetric{Int8, Matrix{Int8}}   # current adjacency matrix
    W::Symmetric{Int8, Matrix{Int8}}   # weight matrix
    cf_0::Int8 # Initial cost
    cf_actual::Int8
    cf_min::Int8 # Minimal cost so far
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
    n, m, l = parse.(Int8, metadata[2:4])

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
    f0 = sum(tril(A0) .* tril(W0)) # frobenius product on lower triangular matrices A and W for inital cost.
    G = graphData(n, m, l, A0, copy(A0), W0, f0, f0, f0)
    
    return G
end

function deltaEval(G::graphData, i, j)
    modifiedA = copy(G.A)
    modifiedA[i,j] = abs(G.A[i,j] - 1) # flip 1->0 or 0->1

    if G.A[i,j] # check if edge is present initially
        added_cost = -G.W[i,j] # deduct cost of edge if yes
    else # add cost if edge is not present
        added_cost = G.W[i,j]
    end

    deltaCost = G.cf_actual + added_cost
    return graphData(G.n, G.m, G.l, G.A0, modifiedA, G.W, G.cf_0, deltaCost, G.cf_min)
end

# Provide the path to your instance file
file_path = "datasets/inst_test/heur001_n_10_m_31.txt"

# Call the function to generate matrices
G_test = readGraphFile(file_path)

# # Display the matrices
# println("Adjacency Matrix:")
display(G_test.cf_min)
deltaEval(G_test, 4,8)

# println("\nWeight Matrix:")
# display(G_test.W)
