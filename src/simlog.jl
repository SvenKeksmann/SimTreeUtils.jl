function simlogint() 
    return LokiLogger.Logger(LokiLogger.json, "http://localhost:3100"; labels=Dict("host" => gethostname(), "app" => "LokiLogger.jl"))
end