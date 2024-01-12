include("../src/GA.jl")
include("../src/metaheuristics.jl")

using ArgParse

RES_FILE = "../data/results/results.csv"

function writetoRES(s)
    open(RES_FILE, "a") do file
        write(file, s)
    end
end

filearg = ARGS[1]

files = []
if filearg == "tuning"
    ###diversity of files from tuning folder
    files = ["heur041_n_300_m_17492.txt",#medium dense, line-structures
            "heur044_n_300_m_3234.txt",#very sparse, line-structures
            "heur048_n_300_m_14666.txt",#small clusters
            "heur052_n_300_m_26628.txt",#big clusters
            "heur053_n_300_m_39861.txt",#fully connected
            "heur055_n_300_m_5164.txt",#sparse, no structure
            "heur058_n_300_m_4010.txt",#medium, no structure
            "heur060_n_300_m_12405.txt"]#rather dense, no structure
elseif filearg == "competition"
    files = ["heur049_n_300_m_17695.txt", "heur050_n_300_m_19207.txt", "heur051_n_300_m_20122.txt"]
elseif filearg == "test"
    files = readdir("../data/datasets/inst_test/")
else
    files = [filearg]
end

N = parse(Int,ARGS[2])
T = parse(Int,ARGS[3])
max_useless_gens = parse(Int,ARGS[4])
overlap = parse(Float64, ARGS[5])
selected_percentage = parse(Float64, ARGS[6])
recomb_meth = parse(Float64, ARGS[7])
n_elites = parse(Int, ARGS[8])
selection_pressure = parse(Float64, ARGS[9])


for inst_file in files
    writetoRES("$inst_file,$N,$T,$max_useless_gens,$overlap,$selected_percentage,$recomb_meth,$n_elites,$selection_pressure,")

    if parse(Int,inst_file[6:7]) < 40
        folder = "../data/datasets/inst_test/"
    else
        folder = "../data/datasets/inst_tuning/"
    end
    if parse(Int,inst_file[6:7]) in [49,50,51]
        folder = "../data/datasets/inst_competition/"
    end
    G = readSPSolutionFile(folder*inst_file)
    tstart = time()
    #inst_file, N, T, max_useless_gens, overlap, selected_percentage, recomb_meth, n_elites, selection_pressure
    new_G = GA(copy(G), inst_file, N, T, max_useless_gens, overlap, selected_percentage, recomb_meth, n_elites, selection_pressure)
    tend = time()
    if filearg == "competition"
        writeSolution(new_G, "solution_"*inst_file)
    end
    println("total time for $inst_file was $(tend-tstart) value is $(calc_objective(new_G)) and the solution is valid $(is_splex(new_G, false))")
    writetoRES("$(tend-tstart),$(calc_objective(new_G))\n")
end