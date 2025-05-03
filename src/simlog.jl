function simloginit() 
    return LokiLogger.Logger(LokiLogger.json, "http://netlabdesk5:3100"; labels=Dict("host" => gethostname(), "app" => "LokiLogger.jl"))
end