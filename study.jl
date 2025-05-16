function basicsimu(STLogger::SimTreeUtils.STLogger, database::SimTreeUtils.stDataBase, pardict,seed,datapath)
    #SimTreeUtils.logInit(STLogger, "info")
    #SimTreeUtils.logInit(STLogger, "debug"; level=Logging.Debug)
    #SimTreeUtils.logInit(STLogger, "warn"; level=Logging.Warn)
    #SimTreeUtils.logInit(STLogger, "error"; level=Logging.Error)

    #SimTreeUtils.logProd(STLogger, "info")
    #SimTreeUtils.logProd(STLogger, "debug"; level=Logging.Debug)
    #SimTreeUtils.logProd(STLogger, "warn"; level=Logging.Warn)
    #SimTreeUtils.logProd(STLogger, "error"; level=Logging.Error)

    #SimTreeUtils.logData(STLogger, "info", 0)
    #SimTreeUtils.logData(STLogger, "debug", 1; level=Logging.Debug)
    #SimTreeUtils.logData(STLogger, "warn", 2; level=Logging.Warn)
    #SimTreeUtils.logData(STLogger, "error", 3; level=Logging.Error)

    @debug "Start SIM"
    SimTreeUtils.logProd(STLogger, "Start Simulation"; level=Logging.Debug)
    #######################################################################

    testtable = SimTreeUtils.CreateTable(database, "SIN_COS_Basic", 
        Dict{String, Type}("index" => Int32, "pi" => Float32))
    testtable = SimTreeUtils.AddTableColumn(testtable, "sin", Float32)
    testtable = SimTreeUtils.AddTableColumn(testtable, "cos", Float32)

    i_steps = 2^8
    #Calculate sin/cos from 0->2pi in isteps iterations
    for i in 0:i_steps
        x = (2 / i_steps) * i
        #if seed == 1
            sin = sinpi(x)
        #else
            cos = cospi(x)
        #end

        #@info string("{\"sin\": ", sin, ", \"cos\": ", cos, "}")
        SimTreeUtils.logData(STLogger, Dict{String, Any}("pi" => x, "sin" => sin, "cos" => cos, "string" => "Hallo Welt!"))# , "index" => i))
        
        #logVal("banana",myVal)
        #SimTreeUtils.logData(STLogger, "index", i)
        SimTreeUtils.AddRow(testtable, [i, x, sin, cos])
    end
    myVal = 1
    myVal2 = 1.2
    myVal3 = "1,3"
    @logVal(myVal)
    @logVal(myVal2)
    @logVal(myVal3)
    @logVal myVal
    @logVal myVal2
    @logVal myVal3

    #######################################################################
    SimTreeUtils.logProd(STLogger, "End Simulation"; level=Logging.Debug)
    @debug "END SIM"

    return pardict

end

#Macro Binding to extract variablename from input-variable
#https://discourse.julialang.org/t/retrieve-variable-name-inside-function/83753/2
macro logVal(expr)
    Logval(expr, eval(expr))
end

function Logval(name, value)
    @info string(name, " - ", value, " - ", typeof(value))
    SimTreeUtils.logInit(STLogger, string(name), value)
end


function main()
    SimTreeUtils.stsimulate("Study.jl", basicsimu,savefile=true)
end
