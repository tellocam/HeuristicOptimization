using LinearAlgebra

mutable struct Instance
    s::Int8
    n::Int64
    m::Int64
    l::Int64
    A0:: Matrix{Int8}  # initial adjacency matrix
    A::Matrix{Int8}    # current adjacency matrix
    W::Matrix{Int8}    # weight matrix
    cf_actual::Int64
    cf_min::Int64 # Minimal cost so far
end

function Base.show(io::IO, x::Instance)
    # This is to suppress the output in the Julia REPL when assigning Instance(..,..)
end

function readInstanceFile(file_path_rel::AbstractString)
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
            
            if i < j
                A[i, j] = edge_present
                W[i, j] = weight
            else
                A[j,i] = edge_present
                W[j,i] = weight
            end

        end
    end

    # normal matrices but make sure the lower triangular part is zero
    G = Instance(s, n, m, l, A, A, W, typemax(Int), typemax(Int)) # costs initialized to max, thats very cool!
    return G
end

function fullCost(G::Instance) # only calculated once, for 1st iter., after that, only  deltaEval(G,i,j)
    G.cf_actual = sum(G.W .* G.A) 
end

function deltaEval(G::Instance, i, j) # It is correct now, however not in FnProg paradigm anymore
    G.A[i,j] = !G.A[i,j] # flip 1->0 or 0->1
    if G.A0[i,j] == G.A[i,j] # Check if flipped edge state is equal to initial edge state
        added_cost = -G.W[i,j] # deduct cost of edge if yes
    else # If flipped edge state is not equal to initial edge state, add cost
        added_cost = G.W[i,j]
    end
    G.cf_actual += added_cost # adjust cost with delta evaluation
end





# Provide the path to your instance file
file_path = "datasets/inst_test/heur001_n_10_m_31.txt"

# Call the function to generate matrices
G_test = readInstanceFile(file_path)

# # # Display the matrices
# # println("Adjacency Matrix:")
# display(G_test.A)
# display(degree(G_test, 3))

# display(G_test.A)
# G_test = det_constr(G_test)
# display(G_test.A)

# deltaEval(G_test, 4,8)

# # println("\nWeight Matrix:")
# # display(G_test.W)
