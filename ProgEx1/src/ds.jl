using MHLib
using LinearAlgebra

mutable struct SPSolution <: Solution
    s::Int8
    n::Int64
    m::Int64
    l::Int64
    A0:: Matrix{Bool}  # initial adjacency matrix
    A::Matrix{Bool}    # current adjacency matrix
    W::Matrix{Int8}    # weight matrix
    obj_val::Int64
    obj_val_valid::Bool
end

function Base.show(io::IO, x::SPSolution)
    # This is to suppress the output in the Julia REPL when assigning SPSolution(..,..)
end

function readSPSolutionFile(file_path_rel::AbstractString)
    # read file
    # Construct the absolute path by combining the script's directory with the relative path
    script_dir = @__DIR__
    file_path = joinpath(script_dir, file_path_rel)
    content = read(file_path, String)
    lines = split(content, '\n')
    
    # Parse the first line to get the number of nodes, edges, and lines
    metadata = split(lines[1], ' ')
    s, n, m, l = parse.(Int64, metadata[1:4])

    # Initialize adjacency and weight matrices
    A = zeros(Bool, n, n)
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
    G = SPSolution(s, n, m, l, A, zeros(Int8, n, n), W, typemax(Int), true)
    G.obj_val = calc_objective(G)
    return G
end

function writeAdjacency(G::SPSolution, out_path::AbstractString, original::Bool)
    
    open(out_path, "w") do file
        for i in 1:G.n
            for j in 1:G.n
                if original
                    write(file, string(Int(G.A0[i,j])))
                else
                    write(file, string(Int(G.A[i,j])))
                end
            end
            write(file,"\n")
        end
    end
end


function MHLib.calc_objective(G::SPSolution)
    return sum(G.W .* abs.(G.A0-G.A))
end

function MHLib.initialize!(G::SPSolution) # initialze to "empty" graph (no edges)
    G.A = zeros(Bool, G.n, G.n)
    G.obj_val = calc_objective(G)
    G.obj_val_valid = true
end

MHLib.to_maximize(::SPSolution) = false

function Base.copy!(G1::SPSolution, G2::SPSolution)
    G1.s = G2.s
    G1.n = G2.n
    G1.m = G2.m
    G1.l = G2.l
    G1.A0 = G2.A0
    G1.A = G2.A
    G1.W = G2.W
    G1.obj_val = G2.obj_val
    G1.obj_val_valid = G2.obj_val_valid
end

Base.copy(G::SPSolution) = SPSolution(G.s, G.n, G.m, G.l, G.A0, G.A, G.W, G.obj_val, G.obj_val_valid)

function adjacent(B::Matrix{Bool}, i, j)
    return B[min(i,j), max(i,j)]
end

function deg(M::Matrix{Bool}, i) #returns degree of node i in G.A
    return sum(M[i,:]) + sum(M[:,i])
end

function dfs(M::Matrix{Bool}, n, i, visited) # depth first search to traverse all connected vertices
    if !visited[i]
        visited[i] = true
        for neighbour in 1:n
            if M[min(i, neighbour), max(i, neighbour)]
                dfs(M, n, neighbour, visited)
            end
        end
    end
end

# Find connected vertices in a subgraph.
function cluster_list(M::Matrix{Bool}, n, i)
    visited = zeros(Bool, n)
    dfs(M, n, i, visited)
    return visited
end

function cluster_list(G::SPSolution, i, original::Bool)
    B = original ? G.A0 : G.A
    return cluster_list(B, G.n, i)
end

function is_splex(G::SPSolution, original::Bool)
    original ? B = G.A0 : B = G.A
    return is_splex(B, G.n, G.s)
end

function is_splex(M::Matrix{Bool}, n, s)
    visited = zeros(Bool, n)
    for i in 1:n # very inefficient, better in delta evaluation
        if visited[i] == 0 # if not visited check this connected subgraph
            subgraph = cluster_list(M, n, i) # which nodes are connected to i (directly or indirectly)
            visited += subgraph
            size = sum(subgraph) # how vertices in the subgraph

            for k in 1:n
                if subgraph[k]
                    if deg(M, k) < size - s
                        return false
                    end
                end
            end
        end
    end
    return true
end


    

function MHLib.check(G::SPSolution)
    return is_splex(G, false)
end


function flipij!(G::SPSolution, i, j) # flip bit, update cost and update validity
    if i>j
        error("want to flip in lower triangular but we use upper triangular adjecency matrix")
    end
    G.A[i,j] = !G.A[i,j] # flip 1->0 or 0->1

    #delta evaluation
    added_cost = 0
    if G.A0[i,j] == G.A[i,j] # Check if flipped edge state is equal to initial edge state
        added_cost = -G.W[i,j] # deduct cost of edge if yes
    else # If flipped edge state is not equal to initial edge state, add cost
        added_cost = G.W[i,j]
    end
    G.obj_val += added_cost # adjust cost with delta evaluation

    #check if still valid
    subgraph = cluster_list(G, i, false) # which nodes are connected to i (directly or indirectly)
    size = sum(subgraph) # how vertices in the subgraph

    min_deg = G.n # minimal degree in subgraph
    for k in 1:G.n
        if subgraph[k]
            min_deg = min(min_deg, deg(G.A, k))
        end
    end
    if (size - min_deg) > G.s # adding the edge is illegal
        return false
    end
    return true
end




function flipij!(A::Matrix{Bool}, i, j, s) # flip bit, update cost and update validity
    if i>j
        error("want to flip in lower triangular but we use upper triangular adjecency matrix")
    end
    A[i,j] = !A[i,j] # flip 1->0 or 0->1

    #delta evaluation

    #check if still valid
    n = Int(sqrt(length(A)))
    subgraph = cluster_list(A, n, i) # which nodes are connected to i (directly or indirectly)
    size = sum(subgraph) # how vertices in the subgraph

    min_deg = n # minimal degree in subgraph
    for k in 1:n
        if subgraph[k]
            min_deg = min(min_deg, deg(A, k))
        end
    end
    if (size - min_deg) > s # adding the edge is illegal
        return false
    end
    return true
end