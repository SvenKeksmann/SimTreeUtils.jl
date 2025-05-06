function simloginit(
    app::String,
    ;endpoint::String="http://netlabdesk5:3100")::LokiLogger.Logger

    
    return _simloginit(endpoint, app, "initializing", Dict{String, String}())
end

function simloginit(
    app::String,
    PARAMSDICT::Dict{String, Any},
    SEED::Int,
    datapath::String
    ;endpoint::String="http://netlabdesk5:3100")::LokiLogger.Logger

    return _simloginit(endpoint, app, "prod",
        Dict{String, String}("SEED" => string(SEED), "datapath" => datapath,
            ((k => string(v)) for (k, v) in PARAMSDICT)...))
end

function _simloginit(
    endpoint::String,
    app::String,
    status::String,
    labelsDict::Dict{String, String})::LokiLogger.Logger

    if haskey(ENV, "USERNAME")
        user = ENV["USERNAME"]
    else
        user = run(`whoami`)
    end

    return LokiLogger.Logger(LokiLogger.json, endpoint; 
        labels=Dict{String, String}("host" => gethostname(), "user" => user, "lokiLogger" => "LokiLogger.jl", "app" => app, "status" => status,
            ((k => v) for (k, v) in labelsDict)...))
end
