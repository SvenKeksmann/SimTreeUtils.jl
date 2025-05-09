mutable struct stDataBase
    dbFile::String
    con::DBInterface.Connection
    simulationprefix::String
end
mutable struct stDataTable
    database::stDataBase
    tableName::String
    columns::Dict{String, Type}
end

function OpenDatabase(datapath::String, dbname::String)
    dbFile = "$datapath/$dbname.duckdb"
    con = DBInterface.connect(DuckDB.DB, dbFile)

    return stDataBase(dbFile, con, "")
end

function CloseDataBase(database::stDataBase)
    DBInterface.close(database.con)
end

function CreateBaseTable(
    database::stDataBase,
    PARAMSDICT::Dict{String, Any},
    SEED::Int,
    datapath::String)::stDataBase

    CreateTable(database, "base", 
        Dict{String, Type}("SEED" => Int,
        "datapath" => String,
        ((k => typeof(v)) for (k, v) in PARAMSDICT)...))

    database.simulationprefix = ""
    return database
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

function CreateTable(database::stDataBase,
    tableName::String,
    columns::Dict{String, Type})::stDataTable

    createColumns = join(["$k $(get(julia_to_sql, v, "TEXT"))" for (k, v) in columns], ", ")

    DBInterface.execute(database.con, "CREATE TABLE IF NOT EXISTS $tableName ($createColumns)")

    datatable = stDataTable(database, tableName, columns)
    #Alter Table & Create new Columns, if TABLE exists
    for (k, v) in columns
        datatable = AddTableColumn(datatable, k, v)
    end
    return datatable
end

function AddTableColumn(table::stDataTable, column::String, columntype::Type)::stDataTable
    sqltype = get(julia_to_sql, columntype, "TEXT")

    DBInterface.execute(table.database.con, "ALTER TABLE $(table.tableName) ADD COLUMN IF NOT EXISTS $column $sqltype")

    if !haskey(table.columns, column)
        table.columns[column] = columntype
    end
    return table
end

function AddRow(table::stDataTable, data::Vector)
    #frame = DataFrame(;[Symbol(k)=>v for (k,v) in data]...)

    columns = join([v for (v) in data], ", ")
    DBInterface.execute(table.database.con, "INSERT INTO $(table.tableName) VALUES($columns)")
end

function SelectData(datapath::String, dbname::String, table::String; limit::Integer=8)::DataFrame
    database = OpenDatabase(datapath::String, dbname::String)
    data = SelectData(database, table, limit)
    CloseDataBase(database)
    display(data)
    return data
end
function SelectData(database::stDataBase, table::String; limit::Integer=8)::DataFrame
    return DBInterface.execute(database.con, "SELECT * FROM $(table) LIMIT $(limit);") |> DataFrames.DataFrame
end

function ViewDBSchema(datapath::String, dbname::String)
    database = OpenDatabase(datapath::String, dbname::String)
    ViewDBSchema(database)
    CloseDataBase(database)
end
function ViewDBSchema(database::stDataBase)
    tables = DBInterface.execute(database.con, "SHOW ALL TABLES") |> DataFrame
    println(tables)
    for tableRow in eachrow(tables)
        table = string(tableRow[:name])
        if tableRow[:temporary]
            println("Skip temporary Table '$table")
        else
            println("Show Table '$table")
            
            schema = DBInterface.execute(database.con, "DESCRIBE $(table)") |> DataFrame
            println(schema)
        end
    end
end