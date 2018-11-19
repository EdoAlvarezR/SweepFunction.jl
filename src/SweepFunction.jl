"""
  Automatic sweeping of function evaluations over a sample space.

  # AUTHORSHIP
    * Author    : Eduardo J. Alvarez
    * Email     : Edo.AlvarezR@gmail.com
    * Created   : Nov 2018
    * License   : MIT
"""
module SweepFunction

# ------------ EXPOSED FUNCTIONS------------------------------------------------
export ArgSweep
export Sweep, runsweep, printsweep


# ------------ GENERIC MODULES -------------------------------------------------
# None required

# ------------ FLOW LAB MODULES ------------------------------------------------
# None required

# ------------ GLOBAL VARIABLES AND DATA STRUCTURES ----------------------------
const module_path = splitdir(@__FILE__)[1]      # Path to this module
                                                # Default path to data files

# ------------ HEADERS ---------------------------------------------------------
# None required
for header_name in []
  include("SweepFunction_"*header_name*".jl")
end



################################################################################
# ARGSWEEP TYPE
################################################################################
"""
  `ArgSweep{T}(arg::Symbol, vals::Array{T, 1})`

Defines an argument `arg` to sweep and the set of values `vals` that the
argument will take.

NOTE: This is only for optional (keyword) arguments.
"""
type ArgSweep{T}
  arg::Symbol
  vals::Array{T, 1}
end

"""
  `get_nvals(self::ArgSweep)`

Returns the number of argument values
"""
function get_nvals(self::ArgSweep)
  return size(self.vals, 1)
end

"""
  `get_optarg(self::ArgSweep, i::Int64)`

Returns the i-th value of the argument
"""
function get_optarg(self::ArgSweep, i::Int64)
  if i>get_nvals(self)
    error("Invalid index $i; maximum is $(get_nvals(self))")
  end

  return (self.arg, self.vals[i])
end
##### END OF ARGSWEEP ##########################################################



################################################################################
# SWEEP TYPE
################################################################################

"""
  `Sweep(fun::Function, argsweep::Array{ArgSweep, 1},
cons_args::Array{Any, 1}, cons_optargs::Array{Tuple{Symbol, Any}, 1})`

Defines a sweep of function `fun` over multiple arguments `argsweep` with
constant required and optional arguments `cons_args` and `cons_optargs` (if
none, `cons_args` and `cons_optargs` can be omitted)
"""
type Sweep
  fun::Function                  # Function to sweep
  argsweep::Array{ArgSweep, 1}   # Variables to sweep

  # Constant required arguments
  cons_args::Array{Any, 1}

  # Constat optional arguments
  cons_optargs::Array{Tuple{Symbol, Any}, 1}

  Sweep(
          fun, argsweep,
          cons_args=Any[],
          cons_optargs=Tuple{Symbol, Any}[]
       ) = new(
          fun, argsweep,
          cons_args,
          cons_optargs
      )
end

"""
  `runsweep(self::Sweep)`

Runs the sweep evaluation of the function.

```jldoctest
julia> function fun(cons1, cons2; arg1=1.0, arg2=1.0, arg3=1.0)
           return arg1*arg2*arg3 + cons1 + cons2
       end;

julia> arg_sweep1 = ArgSweep{Int64}(:arg1, [1, 2, 3]);

julia> arg_sweep2 = ArgSweep{Float64}(:arg2, [4.0, 5.0]);

julia> arg_sweeps = [arg_sweep1, arg_sweep2];

julia> cons_args = [10, 20];

julia> sweep = Sweep(fun, arg_sweeps, cons_args);

julia> res = runsweep(sweep);

julia> printsweep(res)

"f(10, 20; arg1=1, arg2=4.0) = 34.0\n
f(10, 20; arg1=2, arg2=4.0) = 38.0\n
f(10, 20; arg1=3, arg2=4.0) = 42.0\n
f(10, 20; arg1=1, arg2=5.0) = 35.0\n
f(10, 20; arg1=2, arg2=5.0) = 40.0\n
f(10, 20; arg1=3, arg2=5.0) = 45.0\n"
```
"""
function runsweep(self::Sweep; _out=[])

  # Base case: no variables left to sweep
  if size(self.argsweep, 1)==0

    # Evaluates the function
    val = self.fun(self.cons_args...; self.cons_optargs...)

    # Saves this evaluation
    this_run = Dict(
                    "arguments"              => self.cons_args,
                    "optional_arguments"     => self.cons_optargs,
                    "result"                 => val
                    )
    push!(_out, this_run)

  # Recursive case
  else

    # Sweeps last argument
    argsweep = self.argsweep[end]

    for i in 1:get_nvals(argsweep) # Iterates over argument values

      # Get the optional argument pointer and its value
      this_optarg = get_optarg(argsweep, i)

      # Creates a new sweep with this argument being constant
      sweep = Sweep(self.fun,
                      self.argsweep[1:end-1],
                      self.cons_args,
                      vcat(this_optarg, self.cons_optargs)
                    )

      # Recursive call
      runsweep(sweep; _out=_out)
    end
  end

  return _out
end

"""
  `printsweep(runsweep_output; verbose=true, lvl=0)`

Given the output of `runsweep()`, it will format it and print it as a string.
"""
function printsweep(runsweep_output; verbose=true, lvl=0, newln=false)

  out = ""

  for this_run in runsweep_output # Iterates over function calls

    # Builds the string showing the function
    str = "\t"^lvl*"f("

    # Required arguments
    for (i, val) in enumerate(this_run["arguments"])
      str *= string(val)
      str *= i!=size(this_run["arguments"], 1) ? ", " : ""
    end

    # Optional arguments
    for (i, (arg, val)) in enumerate(this_run["optional_arguments"])

      if i==1
        str *= "; "
      end

      str *= string(arg)*"="string(val)
      str *= i!=size(this_run["optional_arguments"], 1) ? ", " : ""
    end

    str *= ")"*("\n"*"\t"^(lvl+1))^newln

    # Function output
    str *= " = " * string(this_run["result"])

    out *= str*"\n"
  end

  if verbose
    println(out)
  end

  return out
end
##### END OF SWEEP #############################################################


end # END OF MODULE
