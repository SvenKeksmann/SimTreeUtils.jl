module SimTreeUtils

using Parameters
using Printf
using DocStringExtensions
using Suppressor
using DimensionalData
using BSON
using TOML

using DuckDB
using DataFrames
using LokiLogger
using Logging
using JSON3

using Plots

export copyresults, findrelpaths, getparameters, simsnum, getsims, getsimspath, SimTreeSession, logValues, saveDuckDB

include("simTreeSession.jl")

include("simulation.jl")
include("loaddata.jl")
include("metaanalysis.jl")
include("simlog.jl")
include("simdatabase.jl")
include("MakroWrapper.jl")

end
