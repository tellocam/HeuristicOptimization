function objective_function(x, y)
    return sin(x) * sin(y) + x / 7 * exp(-x^2 - y^2 / 50)
end

function update_velocity_position(x, v, pbest, gbest, w, phi1, phi2)
    r1, r2 = rand(), rand()
    
    v = ((w * v[1] + phi1 * r1 * (pbest[1] - x[1]) + phi2 * r2 * (gbest[1] - x[1])),
         (w * v[2] + phi1 * r1 * (pbest[2] - x[2]) + phi2 * r2 * (gbest[2] - x[2])))

    x = (x[1] + v[1], x[2] + v[2])
    
    return x, v
end

function PSO()
    # Constants
    num_particles = 4
    num_iterations = 41
    w, phi1, phi2 = 0.95, 0.15, 0.08

    pbest_positions = [(4.11, -1.12), (4.73, -1.36), (1.87, 1.44), (4.68, -0.86)]

    positions = [(3.16, -1.73), (4.73, -1.36), (1.89, 1.35), (3.44, -0.88)]
    velocities = [(0.0, 0.0), (0.0, 0.3), (0.3, 0.0), (0.0, 0.0)]

    gbest_position = pbest_positions[argmax([objective_function(p[1], p[2]) for p in pbest_positions])]

    for iteration in 41:num_iterations
        println("Iteration $iteration")

        for i in 1:num_particles
            x, v = positions[i], velocities[i]
            pbest = pbest_positions[i]
            x, v = update_velocity_position(x, v, pbest, gbest_position, w, phi1, phi2)
            positions[i], velocities[i] = x, v
        end

        for i in 1:num_particles
            current_position = positions[i]
            current_fitness = objective_function(current_position[1], current_position[2])
            if current_fitness > objective_function(pbest_positions[i][1], pbest_positions[i][2])
                pbest_positions[i] = current_position
            end
        end

        gbest_position = pbest_positions[argmax([objective_function(p[1], p[2]) for p in pbest_positions])]

        for i in 1:num_particles
            println("Particle $i: $(round.(positions[i], digits=2))")
        end
        println("Best-known position: $(round.(gbest_position, digits=2))")
    end
end

# Run from iteration 41!
PSO()
