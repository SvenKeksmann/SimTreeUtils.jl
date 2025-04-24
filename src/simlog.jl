
function simlog(logmsg)
    logtime=Dates.Dates.format(now(), "yyyy-mm-dd HH:MM:SS.sss");
    
    logline = string("[", logtime, "] - ", logmsg)
    #logline = string("[", "####", "] - ", logmsg)
    println(logline)
end