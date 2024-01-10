using Plots

function spy_plot(matrix, threshold=0.0)
    spy_matrix = matrix .> threshold
    indices = findall(spy_matrix)

    x, y = Tuple.(indices)  # Convert CartesianIndex objects to tuples

    plot = scatter(x, y, ratio=1, legend=false, xlabel="Column Index", ylabel="Row Index", title="Spy Plot")

    # Save the plot as a PNG file
    savefig(plot, "spy_plot.png")
end

# Example usage:
# Create a random matrix
matrix = rand(0:1, 10, 10)

# Generate a spy plot and save it
spy_plot(matrix)