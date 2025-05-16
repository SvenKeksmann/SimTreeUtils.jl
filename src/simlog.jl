function simloginit(
    app::String,
    status::String = "initializing"
    ;endpoint::String="http://netlabdesk5:3100")::LokiLogger.Logger
    
    return _simloginit(endpoint, app, status, Dict{String, String}())
end

function simloginit(
    app::String,
    PARAMSDICT::Dict{String, Any},
    SEED::Int,
    datapath::String,
    status::String="prod"
    ;endpoint::String="http://netlabdesk5:3100")::LokiLogger.Logger

    return _simloginit(endpoint, app, status,
        Dict{String, String}("SEED" => string(SEED), "datapath" => datapath,
            ((k => string(v)) for (k, v) in PARAMSDICT)...))
end

function _simloginit(
    endpoint::String,
    app::String,
    status::String,
    labelsDict::Dict{String, String})::LokiLogger.Logger


    return LokiLogger.Logger(LokiLogger.json, endpoint; 
        labels=Dict{String, String}("host" => gethostname(), "user" => Sys.username(), "lokiLogger" => "LokiLogger.jl", "app" => app, "status" => status,
            ((k => v) for (k, v) in labelsDict)...))
end

mutable struct STLogger
    initLogger::LokiLogger.Logger
    prodLogger::Union{LokiLogger.Logger, Nothing}
    dataLogger::Union{LokiLogger.Logger, Nothing}
end

#Logging der Init-Ereignisse
function logInit(STLogger::SimTreeUtils.STLogger, data::String; level::Logging.LogLevel=Logging.Info)
    _lokiLog(STLogger.initLogger, data, level)
end
#Logging der Produktiv-Ereignisse
function logProd(STLogger::SimTreeUtils.STLogger, data::String; level::Logging.LogLevel=Logging.Info)
    _lokiLog(STLogger.prodLogger, data, level)
end
#Logging von Rohdaten als JSON
function logData(STLogger::SimTreeUtils.STLogger, data::Dict{String, Any}; level::Logging.LogLevel=Logging.Info)
    json = JSON3.write(data)
    
    _lokiLog(STLogger.dataLogger, string(json), level)
end
function logData(STLogger::SimTreeUtils.STLogger, column::String, data::Any; level::Logging.LogLevel=Logging.Info)
    logData(STLogger, Dict{String, Any}(column => data); level)
end

function _lokiLog(logger::LokiLogger.Logger, data::String, level::Logging.LogLevel)
    with_logger(logger) do
        if level == Logging.Info
            @info data
        elseif level == Logging.Debug
            @debug data
        elseif level == Logging.Warn
            @warn data
        elseif level == Logging.Error
            @error data
            
        else
            @error string("INVALID LOGLEVEL: ", level, " | ", data)
        end
    end
end
