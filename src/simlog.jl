
function simlog(logmsg)
    #logtime=Dates.Dates.format(now(), "yyyy-mm-dd HH:MM:SS.sss");
    
    #logline = string("[", logtime, "] - ", logmsg)
    #logline = string("[", "####", "] - ", logmsg)
    #println(logline)

    #logger = LokiLogger.Logger(LokiLogger.json, "http://localhost:3100";
    #    labels=Dict("datacenter" => "eu-north", "app" => "SimTreeUtils"))
end

function simlogint() 
    return LokiLogger.Logger(LokiLogger.json, "http://localhost:3100"; labels=Dict("host" => gethostname(), "app" => "LokiLogger.jl"))
end