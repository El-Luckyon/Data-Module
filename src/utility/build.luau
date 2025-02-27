--!native
--!optimize 2

-- build.luau
-- builds a key & data table from changelog and base data

local types = require(script.Parent.Parent.types)

return function(map : {[types.key] : types.dataType<any>}, changeLog : types.changeLog, version : number?)
    version = version or #changeLog

    for i = 1, version :: number do
        local change = changeLog[i]
        local action = change.action
        local key = change.key
        local dataType = change.dataType

        if action == "REMOVED" then
            map[key] = nil
        elseif action == "ADDED" or action == "CHANGED" then
            map[key] = dataType
        end 
    end

    return map
end
