--!native
--!optimize 2

-- typeRegister.luau
-- registry of all data types.

local types = require(script.Parent.Parent.types)
local hashfunction = require(script.Parent.Parent.utility.hash)

local dataTypeRecord : {[string] : types.dataType<any>} = {}
local sampleRecord : {[string] : types.dataType<any>} = {}

local function createType<T>(id : string, sample : T, encode : types.write<T>, decode : types.read<T>) : T 
    assert(#id <= 3, "your data type id must be <= 3, id="..id)
    local dataType : types.dataType<T> = {
        id = id,
        sample = sample,
        read = decode,
        write = encode,
    }
    local hash = hashfunction(sample)
    assert(not sampleRecord[hash], "You have provided same samples for 2 data types, sample="..tostring(sample))
    dataTypeRecord[id] = dataType
    sampleRecord[hash] = dataType
    return sample
end

local function findTypeById(id : string) : types.dataType<any>?
    return dataTypeRecord[id]
end

local function findTypeBySample<T>(sample : T) : types.dataType<T>?
    local hash = hashfunction(sample)
    return sampleRecord[hash]
end

return table.freeze{
    find = findTypeById,
    fromSample = findTypeBySample,
    new = createType,
}