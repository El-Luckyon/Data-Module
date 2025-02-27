--!native
--!optimize 2

-- diff.luau
-- diff alogrithm to infer changes in schema

local types = require(script.Parent.Parent.types)


return function(old : types.map<any>, new : types.map<any>) : types.changeLog
    local changeLog = {}

    for key, dataType in old do        
        local newDataType = new[key]

        if not newDataType then
            table.insert(changeLog, {
                dataType = dataType.id,
                action = "REMOVED",
                key = key,
            })
        elseif newDataType.id ~= dataType.id then 
            table.insert(changeLog, {
                dataType = newDataType.id,
                action = "CHANGED",
                key = key,
            })
        end
    end

    for key, datatype in new do        
        local oldDataType = old[key]

        if not oldDataType then
            table.insert(changeLog, {
                dataType = datatype.id,
                action = "ADDED",
                key = key,
            })
        end
    end

    return changeLog
end
