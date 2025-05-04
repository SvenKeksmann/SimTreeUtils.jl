function simloginit(app;endpoint="http://netlabdesk5:3100") 
    return LokiLogger.Logger(LokiLogger.json, endpoint; labels=Dict("host" => gethostname(), "app" => app, "lokiLogger" => "LokiLogger.jl"))
end