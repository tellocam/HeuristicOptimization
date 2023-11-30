#!/bin/bash

# parameters are: algo_name from_file_nr to_file_nr random_const init_cluster_size fuse_best swap_best nr_nodes_shaking1 nr_nodes_shaking2 max_iter vnd_grasp out_file
#julia run_all.jl sns 3 60 0 100 0 0 10 20 10 1 ../data/results/full_run.csv
#julia run_all.jl vnd 3 60 0 100 0 0 10 20 10 1 ../data/results/full_run.csv
#julia run_all.jl grasp 60 60 0 100 0 0 10 20 100 1 ../data/results/full_run.csv
julia run_all.jl gvns 60 60 0 100 0 0 10 20 100 1 ../data/results/full_run.csv
#julia run_all.jl gvns 3 60 0 100 0 0 50 100 10 1 ../data/results/full_run.csv