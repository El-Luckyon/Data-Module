--!native
--!optimize 2

-- schemastore.luau
-- this file contains method related to loading / saving schema from datastores

local DatastoreService = game:GetService("DataStoreService")
local datastore = DatastoreService:GetDataStore("_____Schema_____store_____")


local types = require(script.Parent.Parent.types)

local function read()
    
end

local function write()

end

local function fetch(id : string) : (types.schema, types.schemaMeta)
    
end

local function save(id : string, value : types.schema, meta : types.schemaMeta)

end
