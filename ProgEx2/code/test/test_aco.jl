include("../src/ACO_fun.jl")
include("../src/const.jl")
include("../src/ds.jl")
using LinearAlgebra

function generate_random_matrix(size, n)
    # Create a square matrix with random 1's and 0's
    matrix = rand(0:1, size, size)

    # If you want exactly n 1's, you can set additional values to 0
    total_elements = size^2
    num_zeros = total_elements - n
    zero_indices = rand(1:total_elements, num_zeros)

    # Set selected elements to 0
    matrix[zero_indices] .= 0

    return matrix
end

# Example: generate a 5x5 matrix with 8 random 1's and 0's

G_test = readSPSolutionFile("../data/datasets/inst_test/heur001_n_10_m_31.txt")

currentAntRandomMatrix = generate_random_matrix(G_test.n, 4)

GACO = initialize_ACO_solution(G_test)

print(choose_edge_roulette(GACO, 0.0, 1.0, currentAntRandomMatrix))
