--!native
--!optimize 2

--schema.luau
--contains the method to build a schema

local types = require(script.Parent.Parent.types)
local store = require(script.Parent.schemastore)
local build = require(script.Parent.Parent.utility.build)
local encoder = require(script.Parent.schemaEncoder)
local decoder = require(script.Parent.schemaDecoder)
local typeRegister = require(script.Parent.Parent.datatypes.typeRegister)
local RunService = game:GetService("RunService")
local diff = require(script.Parent.Parent.utility.diff)

return function(schemaId : string, sample : {[types.key] : any}) : types.schema

    local versionLog = {}

    local count = 0

    for key, dataSample in sample do
        assert(#key < 25, "Key is too large!, key="..key.." schemaId="..schemaId)
        local dataType = typeRegister.fromSample(dataSample)
        assert(dataType, "Could not infer datatype from the given sample, sample="..tostring(dataSample).." schemaId="..schemaId)
        sample[key] = dataType
        count += 1
    end

    assert(count < 2000, "You cannot have more than a 2000 keys!, schemaId="..schemaId)

    local schemaBuffer = store.fetch(schemaId)

    if not schemaBuffer then
        print("First schema load, schemaId=", schemaId)
        schemaBuffer = encoder.meta{
            latestVersion = game.PlaceVersion,
            base = sample,
        }
        store.save(schemaId, schemaBuffer)
    else
        print("Schema found in data base, loading..., schemaId=", schemaId)
        local meta, metaSize = decoder.meta(schemaBuffer)
        local changeLog = decoder.changeLog(schemaBuffer, metaSize)
        local latest = build(meta.base, changeLog)
        local latestVersion = meta.latestVersion

        if latestVersion > game.PlaceVersion or RunService:IsStudio() then
            print("Server is ahead or Studio, checking for changes to append... , schemaId=", schemaId)
            local newChanges = diff(latest, sample)
            if #newChanges < 1 then
                print("No changes dedected, sample untouched, schemaId="..schemaId)
            else
                print("Changes dedected, appending changes..., schemaId="..schemaId)
                for _, change in newChanges do
                    encoder.append(schemaBuffer, change)
                    table.insert(changeLog, change)
                end
                print(#newChanges, " changes appended to schema, schemaId="..schemaId)
                buffer.writeu32(schemaBuffer, 0, game.PlaceVersion)
                store.save(schemaId, schemaBuffer)
            end
            versionLog[#changeLog] = sample   
        elseif latestVersion < game.PlaceVersion then
            print("Outdated server, updating sample to latest, schemaId=", schemaId)
            versionLog[#changeLog] = latest
        elseif latestVersion == game.PlaceVersion then
            print("Server up to data not checking for changes... , schemaId=", schemaId)
        end

    end

    return{

    }
end
