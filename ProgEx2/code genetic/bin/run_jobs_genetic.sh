#!/bin/bash

# Define an array of parameter sets
# params are  N, T, overlap, selected_percentage, recomb_meth, n_elites, selection_pressure

best_pop=100
if [ "$1" -eq 1 ]; then #population size test
    param_sets=(
        "tuning 5 0 100 0.2 0.5 1 1 1.9"
        "tuning 10 0 100 0.2 0.5 1 1 1.9"
        "tuning 20 0 100 0.2 0.5 1 1 1.9"
        "tuning 50 0 100 0.2 0.5 1 1 1.9"
        "tuning 100 0 100 0.2 0.5 1 1 1.9"
        "tuning $best_pop 0 100 0.1 0.5 1 1 1.9"
        "tuning $best_pop 0 100 0.2 0.5 1 1 1.9"
        "tuning $best_pop 0 100 0.3 0.5 1 1 1.9"
        "tuning $best_pop 0 100 0.4 0.5 1 1 1.9"
        "tuning $best_pop 0 100 0.5 0.5 1 1 1.9"
        "tuning $best_pop 0 100 0.6 0.5 1 1 1.9"
        "tuning $best_pop 0 100 0.7 0.5 1 1 1.9"
        "tuning $best_pop 0 100 0.8 0.5 1 1 1.9"
        "tuning $best_pop 0 100 0.2 0.1 1 1 1.9"
        "tuning $best_pop 0 100 0.2 0.2 1 1 1.9"
        "tuning $best_pop 0 100 0.2 0.3 1 1 1.9"
        "tuning $best_pop 0 100 0.2 0.4 1 1 1.9"
        "tuning $best_pop 0 100 0.2 0.5 1 1 1.9"
        "tuning $best_pop 0 100 0.2 0.6 1 1 1.9"
        "tuning $best_pop 0 100 0.2 0.7 1 1 1.9"
        "tuning $best_pop 0 100 0.2 0.8 1 1 1.9"
        "tuning $best_pop 0 100 0.2 0.5 1 1 1.9"
        "tuning $best_pop 0 100 0.2 0.5 1 2 1.9"
        "tuning $best_pop 0 100 0.2 0.5 1 3 1.9"
        "tuning $best_pop 0 100 0.2 0.5 1 5 1.9"
        "tuning $best_pop 0 100 0.2 0.5 1 10 1.9"
        "tuning $best_pop 0 100 0.2 0.5 1 20 1.9"
        "tuning $best_pop 0 100 0.2 0.5 1 50 1.9"
        "tuning $best_pop 0 100 0.2 0.5 1 1 1.2"
        "tuning $best_pop 0 100 0.2 0.5 1 1 1.4"
        "tuning $best_pop 0 100 0.2 0.5 1 1 1.6"
        "tuning $best_pop 0 100 0.2 0.5 1 1 1.8"
        "tuning $best_pop 0 100 0.2 0.5 1 1 2.0"
        "competition 300 0 300 0.4 0.4 1 10 1.6"
    )
elif [ "$1" -eq 2 ]; then #...
    param_sets=(
        "test 100 0 100 0.2 0.5 1 10 1.6"
    )
fi 


# Function to run a single job
run_job() {
    julia GA.jl $1
}

# Iterate over parameter sets and run jobs in parallel
for params in "${param_sets[@]}"; do
    run_job "$params" 
done
# Wait for all background jobs to finish
wait
