using Base.Threads

num_threads = Base.Threads.nthreads()
println("Number of threads available: $num_threads")

result = zeros(num_threads, num_threads)

thread_lock = Base.Threads.ReentrantLock()

@threads for i in 1:num_threads

    lock(thread_lock)
    try
        result[i,:] .= Base.Threads.threadid()
    finally
        unlock(thread_lock)
    end
end

print_index_tuple = (2,3)
i,j = print_index_tuple
println(result[i,j])
println(result)
