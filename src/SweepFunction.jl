"""
  Automatic sweeping of function evaluations over a sample space.

  # AUTHORSHIP
    * Author    : Eduardo J. Alvarez
    * Email     : Edo.AlvarezR@gmail.com
    * Created   : Nov 2018
    * License   : MIT
"""
module SweepFunction

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



end # END OF MODULE
