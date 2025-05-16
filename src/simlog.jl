function simloginit(
    app::String,
    status::String = "initializing"
    ;endpoint::String="http://netlabdesk5:3100")::STLogger
    
    return _simloginit(endpoint, app, status, Dict{String, String}())
end

function simloginit(
    app::String,
    PARAMSDICT::Dict{String, Any},
    SEED::Int,
    datapath::String,
    status::String="prod"
    ;endpoint::String="http://netlabdesk5:3100")::STLogger

    return _simloginit(endpoint, app, status,
        Dict{String, String}("SEED" => string(SEED), "datapath" => datapath,
            ((k => string(v)) for (k, v) in PARAMSDICT)...))
end

function _simloginit(
    endpoint::String,
    app::String,
    status::String,
    labelsDict::Dict{String, String})::STLogger


    return STLogger(LokiLogger.Logger(LokiLogger.json, endpoint; 
        labels=Dict{String, String}("host" => gethostname(), "user" => Sys.username(), "lokiLogger" => "LokiLogger.jl", "app" => app, "status" => status,
            ((k => v) for (k, v) in labelsDict)...)))
end

struct STLogger
    logger::LokiLogger.Logger
end

function logValues(STLogger::SimTreeUtils.STLogger, data::Dict{String, Any})
    json = JSON3.write(data)
    
    with_logger(STLogger.logger) do
        @info string(json)
    end
end
function logValues(STLogger::SimTreeUtils.STLogger, column::String, data::Any)
    logValues(STLogger, Dict{String, Any}(column => data))
    
end