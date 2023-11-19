using LinearAlgebra

function degree(G::Instance, i) #returns degree of node i in G.A
    return sum(G.A[i,:])
end

function dfs(G::Instance, i, visited) # depth first search to traverse all connected vertices
    if !visited[i]
        visited[i] = true
        for neighbor in G.A[i,:]
            if neighbour
                dfs(graph, neighbor, visited)
            end
        end
    end
end

# Find connected vertices in a subgraph.
function connected_subgraph(G::Instance, i)
    visited = zeros(G.n)
    dfs(G, i, visited)
    return visited
end

function is_legal(G::Instance, i, j)
    G.A[i,j] = 1
    subgraph = connected_subgraph(G, i) # which nodes are connected to i (directly or indirectly)
    size = sum(subgraph) # how vertices in the subgraph

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

function det_constr(G::Instance) # deterministic construction of s-plexes from empty graph
    G.A = zeros(Int8, G.n,G.n)
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





