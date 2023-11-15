using LinearAlgebra

mutable struct graphData
    n::Int8
    m::Int8
    l::Int8
    A0::Symmetric{Int8, Matrix{Int8}}  # initial adjacency matrix
    A::Symmetric{Int8, Matrix{Int8}}   # current adjacency matrix
    W::Symmetric{Int8, Matrix{Int8}}   # weight matrix
end

function read_instance_file(file_path_rel::AbstractString)
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

    # Only keep the lower (or upper) triangular part by using symmetric matrices
    A0 = Symmetric(A)
    G = graphData(n, m, l, A0, copy(A0), Symmetric(W))

    return G
end

# # Provide the path to your instance file
# file_path = "datasets/inst_test/heur001_n_10_m_31.txt"

# # Call the function to generate matrices
# G_test = read_instance_file(file_path)

# # Display the matrices
# println("Adjacency Matrix:")
# display(G_test.A0)

# println("\nWeight Matrix:")
# display(G_test.W)
