--!native
--!optimize 2

-- schemastore.luau
-- this file contains method related to loading / saving schema from datastores

local DatastoreService = game:GetService("DataStoreService")
local datastore = DatastoreService:GetDataStore("_____Schema_____store_____")

-- Schema Buffer Structure
--[[
    [1] Meta
        [1] LatestVersion
        [2] SizeOfBaseKeyset
        [3] BaseKeyset
        [4] SizeOfBaseSamples
        [5] BaseSamples
    [2] Change
        [1] SizeOfChange
        [2] action
        [3] key
        [4] sample
    ...
]]

local function fetch(id : string) : buffer?
    local success, result = pcall(function()
        return datastore:GetAsync(id)
    end)

    if not success then
        warn(result)
        error("Fetch failed, failed to connect with schema store, id="..id)
    end

    return result
end

local function save(id : string, value : buffer)
    local success, result = pcall(function()
        return datastore:SetAsync(id, value)
    end)

    if not success then
        warn(result)
        error("Save failed, failed to connect with schema store, id="..id)
    end
end

return table.freeze{
    save = save,
    fetch = fetch,
}
