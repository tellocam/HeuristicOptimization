#!/bin/bash

# parameters are: algo_name from_file_nr to_file_nr random_const init_cluster_size fuse_best swap_best nr_nodes_shaking1 nr_nodes_shaking2 max_iter vnd_grasp out_file


#run vnd for all files with fastest config
if [ "$1" = "vnd" ]; then
    echo "The argument is 'vnd'"
    julia run_all.jl vnd 2 60 0 100 0 0 10 20 10 1 ../data/results/full_run_vnd.csv
fi

##competition runs
#run vnd for all configs for all competition files
if [ "$1" = "comp_vnd" ]; then
    echo "The argument is 'comp_vnd'"
    julia run_all.jl vnd 59 59 0 100 0 0 10 20 10 1 ../data/results/comp_vnd.csv
    julia run_all.jl vnd 58 60 0 100 0 1 10 20 10 1 ../data/results/comp_vnd.csv
    julia run_all.jl vnd 58 60 0 100 1 0 10 20 10 1 ../data/results/comp_vnd.csv
    julia run_all.jl vnd 58 60 0 100 1 1 10 20 10 1 ../data/results/comp_vnd.csv
    julia run_all.jl vnd 58 60 0 1 0 0 10 20 10 1 ../data/results/comp_vnd.csv
    julia run_all.jl vnd 58 60 0 1 0 1 10 20 10 1 ../data/results/comp_vnd.csv
    julia run_all.jl vnd 58 60 0 1 1 0 10 20 10 1 ../data/results/comp_vnd.csv
    julia run_all.jl vnd 58 60 0 1 1 1 10 20 10 1 ../data/results/comp_vnd.csv
fi

if [ "$1" = "comp_local_swap" ]; then
    echo "The argument is 'comp_local_swap'"
    julia run_all.jl local_swap 58 60 0 1 0 0 10 20 10 1 ../data/results/comp_swap.csv
    julia run_all.jl local_swap 58 60 0 1 0 1 10 20 10 1 ../data/results/comp_swap.csv
fi

if [ "$1" = "comp_local_fuse" ]; then
    echo "The argument is 'comp_local_fuse'"
    julia run_all.jl local_fuse 58 60 0 1 0 0 10 20 10 1 ../data/results/comp_fuse.csv
fi

if [ "$1" = "comp_grasp" ]; then
    echo "The argument is 'comp_grasp'"
    julia run_all.jl grasp 58 60 0 100 0 0 10 20 50 1 ../data/results/comp_grasp.csv
fi

if [ "$1" = "comp_gvns" ]; then
    echo "The argument is 'comp_gvns'"
    julia run_all.jl gvns 58 60 0 100 0 0 100 200 50 1 ../data/results/comp_gvns.csv
fi



#run sns for some instances of all types to compare to vnd
if [ "$1" = "sns" ]; then
    echo "The argument is 'sns'"
    julia run_all.jl sns 2 27 0 100 0 0 10 20 10 1 ../data/results/full_run_sns.csv
fi
# gvns for some rather fast instances
if [ "$1" = "gvns" ]; then
    echo "The argument is 'gvns'"
    # parameters are: algo_name from_file_nr to_file_nr random_const init_cluster_size fuse_best swap_best nr_nodes_shaking1 nr_nodes_shaking2 max_iter vnd_grasp out_file
    #julia run_all.jl gvns 2 4 0 100 0 0 20 50 50 1 ../data/results/comp_gvns.csv
    #julia run_all.jl gvns 11 13 0 100 0 0 50 150 50 1 ../data/results/gvns.csv
    #julia run_all.jl gvns 21 21 0 100 0 0 50 150 50 1 ../data/results/gvns.csv
    #julia run_all.jl gvns 33 33 0 100 0 0 50 150 50 1 ../data/results/gvns.csv
    #julia run_all.jl gvns 35 35 0 100 0 0 50 150 50 1 ../data/results/gvns.csv
    #julia run_all.jl gvns 41 41 0 100 0 0 50 150 50 1 ../data/results/gvns.csv
    julia run_all.jl gvns 49 50 0 100 0 0 50 150 50 1 ../data/results/gvns.csv
    julia run_all.jl gvns 18 19 0 100 0 0 50 150 50 1 ../data/results/gvns.csv
fi
# grasp for some rather fast instances
if [ "$1" = "grasp" ]; then
    echo "The argument is 'grasp'"
    # parameters are: algo_name from_file_nr to_file_nr random_const init_cluster_size fuse_best swap_best nr_nodes_shaking1 nr_nodes_shaking2 max_iter vnd_grasp out_file
    #julia run_all.jl grasp 2 4 0 100 0 0 20 50 50 1 ../data/results/grasp.csv
    #julia run_all.jl grasp 11 13 0 100 0 0 50 150 50 1 ../data/results/grasp.csv
    #julia run_all.jl grasp 21 21 0 100 0 0 50 150 50 1 ../data/results/grasp.csv
    #julia run_all.jl grasp 33 33 0 100 0 0 50 150 50 1 ../data/results/grasp.csv
    #julia run_all.jl grasp 35 35 0 100 0 0 50 150 50 1 ../data/results/grasp.csv
    #julia run_all.jl grasp 41 41 0 100 0 0 50 150 50 1 ../data/results/grasp.csv
    julia run_all.jl grasp 49 50 0 100 0 0 50 150 50 1 ../data/results/grasp.csv
    julia run_all.jl grasp 18 19 0 100 0 0 50 150 50 1 ../data/results/grasp.csv
fi