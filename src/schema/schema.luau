--!native
--!optimize 2

--schema.luau
--contains the method to build a schema

local types = require(script.Parent.Parent.types)
local sort = require(script.Parent.Parent.utility.sort)

return function(schemaId : string, sample : {[types.key] : any}) : types.schema

    local currentKeys, currentValue = sort(sample)

    return{

    }
end
