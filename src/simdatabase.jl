mutable struct stDataTable
    database::SimTreeUtils.SimTreeSession
    tableName::String
    columns::Dict{String, Type}
end

#function OpenDatabase(session::SimTreeSession, datapath::String, dbname::String)
#    session.duckDBfile = "$datapath/$dbname.duckdb"
#    session.duckDBcon = DBInterface.connect(DuckDB.DB, dbFile)
#
#    return stDataBase(dbFile, con, "")
#end
#function OpenInMemoryDB()::stDataBase
#    dbFile = ":memory:"
#    con = DBInterface.connect(DuckDB.DB, dbFile)
#
#    return stDataBase(dbFile, con, "")
#end
function CloseDataBase(session::SimTreeUtils.SimTreeSession)
    if session.duckDBfile == ":memory:"
        @error "Not implemented!"
        return
        #if datapath=="" || dbname==""
        #    @error "InMemory-Data will be Lost!"
        #else
        #    session.duckDBfile = "$(session.SIMTREE_RESULTS_PATH))/$(session.app).duckdb"
        #    DBInterface.execute(session.duckDBcon, "ATTACH '$(session.duckDBfile)'")
        #    DBInterface.execute(session.duckDBcon, "COPY FROM DATABASE memory TO $(session.app))")
        #    DBInterface.execute(session.duckDBcon, "DETACH $(session.app)")
        #end
    end
    DBInterface.close(session.duckDBcon)
    session.duckDBcon = nothing
end

function CreateBaseTable(session::SimTreeUtils.SimTreeSession)

    CreateTable(session, "base", 
        Dict{String, Type}("SEED" => Int,
        "datapath" => String,
        ((k => typeof(v)) for (k, v) in session.PARAMSDICT)...))
end

const julia_to_sql = Dict(
    Int32   => "INTEGER",
    Int64   => "INTEGER",
    Float32 => "REAL",
    Float64 => "REAL",
    String  => "TEXT",
    Bool    => "BOOLEAN",
    Missing => "NULL"
)

function CreateTable(session::SimTreeUtils.SimTreeSession,
    tableName::String,
    columns::Dict{String, Type})::stDataTable

    createColumns = join(["$k $(get(julia_to_sql, v, "TEXT"))" for (k, v) in columns], ", ")

    DBInterface.execute(session.duckDBcon, "CREATE TABLE IF NOT EXISTS $tableName ($createColumns)")

    datatable = stDataTable(session, tableName, columns)
    #Alter Table & Create new Columns, if TABLE exists
    for (k, v) in columns
        datatable = AddTableColumn(datatable, k, v)
    end
    return datatable
end

function AddTableColumn(table::stDataTable, column::String, columntype::Type)::stDataTable
    sqltype = get(julia_to_sql, columntype, "TEXT")

    DBInterface.execute(table.session.duckDBcon, "ALTER TABLE $(table.tableName) ADD COLUMN IF NOT EXISTS $column $sqltype")

    if !haskey(table.columns, column)
        table.columns[column] = columntype
    end
    return table
end

function AddRow(table::stDataTable, data::Vector)
    columns = join([v for (v) in data], ", ")
    DBInterface.execute(table.session.duckDBcon, "INSERT INTO $(table.tableName) VALUES($columns)")
end

#Aufruf SelectData mit Open/Close-DB
#function SelectData(session::SimTreeUtils.SimTreeSession, table::String; limit::Integer=8, Columns::String="*")::DataFrame
#    #database = OpenDatabase(datapath::String, dbname::String)
#    data = SelectData(session, table; limit, Columns)
#    CloseDataBase(session)
#    return data
#end
function SelectData(session::SimTreeUtils.SimTreeSession, table::String; limit::Integer=8, Columns::String="*")::DataFrame
    return DBInterface.execute(session.duckDBcon, "SELECT $(Columns) FROM $(table) LIMIT $(limit);") |> DataFrames.DataFrame
end

#Aufruf ViewDBSchema mit Open/Close-DB
#function ViewDBSchema(session::SimTreeUtils.SimTreeSession)
#    #database = OpenDatabase(datapath::String, dbname::String)
#    ViewDBSchema(session)
#    CloseDataBase(session)
#end
function ViewDBSchema(session::SimTreeUtils.SimTreeSession)
    tables = DBInterface.execute(session.duckDBcon, "SHOW ALL TABLES") |> DataFrame
    println(tables)
    for tableRow in eachrow(tables)
        table = string(tableRow[:name])
        if tableRow[:temporary]
            println("Skip temporary Table '$table")
        else
            println("Show Table '$table")
            
            schema = DBInterface.execute(session.duckDBcon, "DESCRIBE $(table)") |> DataFrame
            println(schema)

            println(SelectData(session, table))
        end
    end
end

#Temporary easy plotting function
function plotXY(session::SimTreeUtils.SimTreeSession, table::String, colX::String, colY::Matrix{String}; limit::Integer=8)
    #database = OpenDatabase(datapath::String, dbname::String)
    x = SelectData(session, table; limit, Columns=colX)
    y = SelectData(session, table; limit, Columns=join(colY, ", "))
    CloseDataBase(session)
    
    Plots.plot(Matrix(x), Matrix(y), title="$(session.app)/$table", labels=colY, xlabel="$colX")
end
