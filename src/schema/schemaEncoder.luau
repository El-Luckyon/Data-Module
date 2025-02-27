--!native
--!optimize 2

-- schemaEncoder.luau
-- Encoding for schema and schema Meta

local writer = require(script.Parent.Parent.buffers.write)
local types = require(script.Parent.Parent.types)

--[[
TODO: implement constraint checks!
    MaxChangeSize = 255
    MaxBaseKeySize = 2^16 - 1
    MaxBaseSampleSiz = 2^16 - 1
]]

-----------------------------------------------
-- Cached Writer Method
-----------------------------------------------
local move = writer.move
local lock = writer.lock
local unlock = writer.unlock
local writeInplaceu16 = writer.writeInplaceu16
local uncheckedWriteu32 = writer.uncheckedWriteu32
local writeu8 = writer.writeu8
local writeShortString = writer.writeShortString
local writeStaticString = writer.writestaticString
local cursor = writer.cursor
local pop = writer.pop
local copy = writer.copy

local function writeMeta(meta : types.schemaMeta) : buffer
    lock()
    uncheckedWriteu32(meta.latestVersion)
    move(4)
    for key, dataType in meta.base do
        writeShortString(key)
        writeStaticString(dataType.id)
    end
    writeInplaceu16(cursor() - 4, 2)
    local metaBuffer = pop()
    unlock()
    return metaBuffer
end

local actionCodes = { ADDED = 0, REMOVED = 1, CHANGED = 2 }

local function appendChange(buff : buffer, change : types.change) : buffer
    local action = change.action
    local dataType = change.dataType
    lock()
    copy(buff)
    writeu8(actionCodes[action])
    writeShortString(change.key)
    writeStaticString(dataType.id)
    buff = pop()
    unlock()
    return buff
end

return table.freeze{
    meta = writeMeta,
    append = appendChange,
}