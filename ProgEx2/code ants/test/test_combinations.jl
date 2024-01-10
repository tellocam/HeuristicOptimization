# Define fixed values for parameters
α_values = [0.2, 0.25, 0.3, 0.35, 0.4]
μ_values = [0.2, 0.25, 0.3, 0.35, 0.4]
q0_values = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7]

# α = α_range[1] + (α_range[2] - α_range[1]) * rand()
# μ = μ_range[1] + (μ_range[2] - μ_range[1]) * rand()
# q0 = q0_range[1] + (q0_range[2] - q0_range[1]) * rand()

# Initialize an empty list to store combinations
all_combinations = []

# Nested loops to generate combinations
for p1 in α_values
    for p2 in μ_values
        for p3 in q0_values
            push!(all_combinations, (α = p1, μ = p2, q0 = p3))
        end
    end
end

params = rand(all_combinations)


# Display the generated combinations
println(params.α)

#println(rand(all_combinations, 20))