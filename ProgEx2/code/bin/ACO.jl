include("ds.jl")

using Random
using StatsBase
using Graphs
using ArgParse
using Base.Threads

filename = "../data/datasets/inst_competition/heur051_n_300_m_20122.txt"
G_0 = readSPSolutionFile(filename)