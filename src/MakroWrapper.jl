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

macro logValues(var1, var2)
    name1 = string(var1)
    name2 = string(var2)

    esc(quote
        local _val1 = $var1
        local _name1 = $name1

        local _val2 = $var2
        local _name2 = $name2

        dict = Dict{String, Any}(_name1 => _val1, _name2 => _val2)
        SimTreeUtils._logValues(dict)
    end)
end
macro logValues(var)
    name = string(var)

    esc(quote
        local _val = $var
        local _name = $name

        dict = Dict{String, Any}(_name => _val)

        SimTreeUtils._logValues(dict)
    end)
end
function _logValues(data::Dict{String, Any})
    session = SimTreeUtils.GetSession(nothing)
    SimTreeUtils.logData(session, dict; level=Logging.Info)
end
macro saveDuckDB(var)
    name = string(var)

    esc(quote
        local _val = $var
        local _name = $name
        local _type = typeof(_val)
        local tableName = _name


        session = SimTreeUtils.GetSession(nothing)
        table = SimTreeUtils.CreateTable(session, tableName, OrderedDict{String, Type}(_name => _type,
            ((k => typeof(v)) for (k, v) in session.PARAMSDICT)...))
        dict = Dict{String, Any}(_name => _val, 
            ((k => isa(v, String) ? "'$v'" : v) for (k, v) in session.PARAMSDICT)...)
        SimTreeUtils.AddRow(table, dict)
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