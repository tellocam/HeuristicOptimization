#!/bin/bash

# parameters are: algo_name from_file_nr to_file_nr random_const init_cluster_size fuse_best swap_best nr_nodes_shaking1 nr_nodes_shaking2 out_file
julia run_all.jl sns 60 60 0 100 1 0 10 20 ../data/results/test.csv