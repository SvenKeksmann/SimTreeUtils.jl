"""
$(TYPEDSIGNATURES)

Get the SimTree parameters in a `Dictionary{String, Vector{String}}`
SimTree must be installed.
Give the root simtree directory
"""
function getsimtreeparams(simtreedirectory::String=".")::Dict{String,Vector{String}}
    cmd = Cmd(`SimTree list`; dir=simtreedirectory)
    iobf = IOBuffer()
    @suppress begin
        run(pipeline(cmd, stdout=iobf))
    end
    seekstart(iobf)

    parvaldict = Dict{String, Vector{String}}()

    par_val_rgx = r"\[([^\] ]*) ([^\]]*)\]"

    for l in eachline(iobf)
        for m in eachmatch(par_val_rgx, l)
            if haskey(parvaldict, m.captures[1])
                vals = parvaldict[m.captures[1]]
                m.captures[2] ∈ vals && continue
                push!(vals, m.captures[2])
            else
                parvaldict[m.captures[1]] = String[m.captures[2]]
            end
        end
    end
    return parvaldict
end

"""
$(TYPEDSIGNATURES)

Wraps the function you want to run through SimTree simulate
"""
function stsimulate(app::String, simulatefunction; savefile=true)
    SEED = -1
    datapath = ""
    SIMTREE_RESULTS_PATH = ""

    Logging.with_logger(simloginit(app)) do
        @debug "Init-Logger initialized!"

        if haskey(ENV, "SIMTREE_RESULTS_PATH")
            SIMTREE_RESULTS_PATH = ENV["SIMTREE_RESULTS_PATH"]
        else
            @warn "Now resultspath set using $(pwd())/results"
            SIMTREE_RESULTS_PATH = "$(pwd())/results"
        end
        @info "SIMTREE_RESULTS_PATH: " * SIMTREE_RESULTS_PATH

        starguments=TOML.parsefile("$SIMTREE_RESULTS_PATH/simtree_arguments.toml")
        if starguments == nothing
            @warn "starguments empty"
        else
            @info "starguments: " * string(starguments)
        end

        if haskey(starguments, "s")
            str_seed = starguments["s"]
            @info "Seed is: " * str_seed

            SEED = parse(Int, str_seed)
        else
            @warn "Seed not set from ST using 0"
            SEED = 0
        end

        # INFO: This file has the definition from PARAMSDICT
        include("$SIMTREE_RESULTS_PATH/$(starguments["p"])")
        if haskey(starguments, "DATA_PATH")
            datapath = starguments["DATA_PATH"]
        else
            @warn "Datapath not set using pwd/data"
            datapath = "$(pwd())/data"
        end
        @info "datapath: " * datapath

        PARAMSDICT["stresultspath"]=SIMTREE_RESULTS_PATH
        @show PARAMSDICT
        @debug "Init-Logger closed"
    end

    results = nothing
    internalLogger = SimTreeUtils.STLogger(logger = simloginit(app, PARAMSDICT, SEED, datapath, "data"))
    Logging.with_logger(simloginit(app, PARAMSDICT, SEED, datapath, "prod")) do
        @debug "Prod-Logger initialized!"

        #TEmporary DB Create in study.jl/data (datapath)
        database = CreateBaseTable(OpenDatabase(SIMTREE_RESULTS_PATH, "database"), PARAMSDICT, SEED, datapath)
        results = simulatefunction(internalLogger, database, PARAMSDICT, SEED, datapath)
        CloseDataBase(database)
        database = nothing

        # @show results
        if savefile
            BSON.bson("$SIMTREE_RESULTS_PATH/study.bson", results)
        end
        @debug "Prod-Logger closed"
    end

    return results
end
