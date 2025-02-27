--!native
--!optimize 2

-- schemaDecoder.luau
-- decoding of schema meta and changes

local types = require(script.Parent.Parent.types)
local typeRegister = require(script.Parent.Parent.datatypes.typeRegister)
local find = typeRegister.find

---------------------------------------------------
-- Cached Read methods from buffer API.
---------------------------------------------------
local readu16 = buffer.readu16
local readString = buffer.readstring
local readu8 = buffer.readu8

local function decodeMeta(schema : buffer) : (types.schemaMeta, number)
    local map = {}
    local version = readu16(schema, 0)
    
    local keySize = readu16(schema, 2)
    local cursor = 4

    while keySize > cursor  do
        local keyLength = readu16(schema, cursor)
        cursor += 2
        local key = readString(schema, cursor, keyLength)
        cursor += keyLength
        local dataId = readString(schema, cursor, 3)
        cursor += 3
        local dataType = find(dataId)
        if not dataType then 
            warn("Unable to find data type while decoding base, id="..dataId)
            continue
        end
        map[key] = dataType
    end

    return{
        latestVersion = version,
        base = map,
    }, cursor
end

local actionCodes = {[0] = "ADDED", [1] = "REMOVED", [2] = "CHANGED"}

local function createChangeLog(schema, metaSize)
    local schemaLen = buffer.len(schema)
    local cursor = metaSize
    local changeLog = {}

    while schemaLen > cursor do
        local action = readu8(schema, cursor)
        cursor += 1
        local keySize = readu8(schema, cursor)
        cursor += 1
        local key = readString(schema, cursor, keySize)
        cursor += keySize
        local dataId = readString(schema, cursor, 3)
        cursor += 3
        local dataType = find(dataId)
        assert(dataType, "unable to find datatype while creating changeLog, dataId="..dataId)
        table.insert(changeLog, {
            key = key,
            action = actionCodes[action],
            dataType = dataType,
        })
    end

    return changeLog
end


return table.freeze{
    meta = decodeMeta,
    changeLog = createChangeLog,
}