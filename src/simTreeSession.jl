mutable struct SimTreeSession
    app::String
    SIMTREE_RESULTS_PATH::Union{String, Nothing}
    PARAMSDICT::Union{Dict{String, Any}, Nothing}
    SEED::Union{Int, Nothing}
    datapath::Union{String, Nothing}

    lokiInit::LokiLogger.Logger
    lokiProd::Union{LokiLogger.Logger, Nothing}
    lokiData::Union{LokiLogger.Logger, Nothing}
    
    duckDBfile::Union{String, Nothing}
    duckDBcon::Union{DBInterface.Connection, Nothing}
end

function InitializeSession(app::String)::SimTreeUtils.SimTreeSession
    session = SimTreeUtils.SimTreeSession(app, nothing, nothing, nothing, nothing, 
        simloginit(app), nothing, nothing,
        nothing, nothing)

    return SaveSession(session)
end

function PrepareSession(session::SimTreeUtils.SimTreeSession, SIMTREE_RESULTS_PATH::String, PARAMSDICT::Dict{String, Any}, SEED::Int, datapath::String)
    session.SIMTREE_RESULTS_PATH = SIMTREE_RESULTS_PATH
    session.PARAMSDICT = PARAMSDICT
    session.SEED = SEED
    session.datapath = datapath

    session.lokiProd = simloginit(session, "prod")
    session.lokiData = simloginit(session, "data")

    session.duckDBfile = "$SIMTREE_RESULTS_PATH/$(session.app)).duckdb"
    session.duckDBcon = DBInterface.connect(DuckDB.DB, session.duckDBfile)
    #CreateBaseTable(OpenDatabase(SIMTREE_RESULTS_PATH, "database"), PARAMSDICT, SEED, datapath)

    SaveSession(session)
end

function CloseSession(session::SimTreeUtils.SimTreeSession)
    CloseDataBase(session)

    SaveSession(session)
end

function SaveSession(session::SimTreeUtils.SimTreeSession)::SimTreeUtils.SimTreeSession
    Base.task_local_storage("session", session)
    return session
end

function GetSession()::SimTreeUtils.SimTreeSession
    session = Base.task_local_storage("session")
    session === nothing && @error "No active Session found!"
    return session
end
function GetSession(session::Union{SimTreeUtils.SimTreeSession, Nothing})::SimTreeUtils.SimTreeSession
    if session == nothing
        return GetSession()
    end
    return session
end

