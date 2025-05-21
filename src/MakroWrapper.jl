#Macro Binding to extract variablename from input-variable
#https://discourse.julialang.org/t/retrieve-variable-name-inside-function/83753/2
macro logValues(args...;session::Union{SimTreeSession, Nothing}=nothing, level::Logging.LogLevel=Logging.Info)
    pairs = [:( $(string(arg)) => $arg ) for arg in args]
    dict = Expr(:call, :Dict, pairs...)

    esc(quote
        session = GetSession(session)
        logData(session, dict, level)
    end)
end