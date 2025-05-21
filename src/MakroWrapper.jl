#Macro Binding to extract variablename from input-variable
#https://discourse.julialang.org/t/retrieve-variable-name-inside-function/83753/2
#macro logValues(vars...)
    #expr = Expr(:call, :Dict)
    #for i in 1:length(vars)
    #    push!(expr.args, :($(QuoteNode(vars[i])) => $(esc(vars[i]))))
    #end
    #println(expr)

    #pairs = [:( $(ParseData(string(arg), arg)) => $arg ) for arg in args]
    
    #dict = Dict{String, String}(:( ($(string(arg)) => $arg ) for arg in args))

    #println(pairs)
    #dict_expr = Expr(:call, :Dict, pairs)
    #println(dict_expr)
    #println(typeof(dict_expr))

    #esc(quote
    #    println($dict_expr)
    #    println(typeof($dict_expr))
    #    session = SimTreeUtils.GetSession(nothing)
    #    SimTreeUtils.logInit(session, dict, Logging.Info)
    #end)
#end
#;session::Union{SimTreeUtils.SimTreeSession, Nothing}=nothing, level::Logging.LogLevel=Logging.Info

macro logValues(var)
    name = string(var)

    esc(quote
        local _val = $var
        local _name = $name

        dict = Dict{String, Any}(_name => _val)

        session = SimTreeUtils.GetSession(nothing)
        SimTreeUtils.logData(session, dict; level=Logging.Info)
    
    end)
end
macro saveDuckDB(var)
    name = string(var)

    esc(quote
        local _val = $var
        local _name = $name
        local _type = typeof(_val)

        #dict = Dict{String, Any}(_name => _val)

        session = SimTreeUtils.GetSession(nothing)
        table = SimTreeUtils.CreateTable(session, _name, Dict{String, Type}(_name => _type,
            ((k => typeof(v)) for (k, v) in session.PARAMSDICT)...))
        SimTreeUtils.AddRow(table, [_val, ((isa(v, String) ? "\"$v\"" : v) for (k, v) in session.PARAMSDICT)...])
    end)
end

#https://discourse.julialang.org/t/macro-to-convert-list-of-variables-to-dict-keyed-by-variable-name/8755/2
macro makedict(args...)
    expr = Expr(:call, :Dict)
    for i in 1:length(args)
        push!(expr.args, :($(QuoteNode(args[i])) => $(esc(args[i]))))
    end
    return expr
end