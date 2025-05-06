function simloginit(
    app::String,
    ;endpoint::String="http://netlabdesk5:3100")::LokiLogger.Logger

    
    return _simloginit(endpoint, app, "initializing", Dict{String, String}())
end

function simloginit(
    app::String,
    PARAMSDICT::Dict{String, Any},
    SEED::String,
    datapath::String
    ;endpoint::String="http://netlabdesk5:3100")::LokiLogger.Logger

    return _simloginit(endpoint, app, "prod",
        Dict{String, String}("SEED" => SEED, "datapath" => datapath,
            [(k => string(v)) for (k, v) in PARAMSDICT]...))
end

function _simloginit(
    endpoint::String,
    app::String,
    status::String,
    labels::Dict{String, String})::LokiLogger.Logger

    return LokiLogger.Logger(LokiLogger.json, endpoint; 
        labels=Dict("host" => gethostname(), "user" => getuser(), "lokiLogger" => "LokiLogger.jl", "app" => app, "status" => status,
            [(k => v) for (k, v) in labels]...))
end