# SweepFunction

Types and methods for sweeping the evaluation of a function over a sample space. These methods are useful for automating the process of sensitivity analysis and generation of response surfaces.

See `examples.ipynb` for examples on how to use this package.

## Notes
  * Parallel processing is done through [multi-threading](https://docs.julialang.org/en/v1.0/manual/parallel-computing/#Multi-Threading-(Experimental)-1), which requires declaring the number of threads (or cores available) through the system environment variable `JULIA_NUM_THREADS` that Julia reads before launching. To do so, either do `export JULIA_NUM_THREADS=4` before launching Julia, or add this line (after changing the number of threads according to the number of cores aviable to your machine) to the system environment (i.e., `~/.bashrc` and/or `~/.bash_profile`). Verify the correct declaration of threads with `Threads.nthreads()` after launching Julia.
