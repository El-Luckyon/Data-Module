--!native
--!optimize 2

--group.luau
--this file contains everything about groups

local types = require(script.Parent.Parent.types)
local schema = require(script.Parent.Parent.schema.schema)

--[[
    function: group
    paramerters : name : string, sample : any
    returns :
    * new : (id) -> container
    * del : (id) -> (), 
    * get : (id, key?) -> any? 
    * set : (id, data) -> ()
]]
return function<T>(name : string, sample : T, defaultData : T) : types.Group<T>

    if typeof(sample) ~= "table" then
        error("Your sample is not a table, please provide a table", 2)
    end

    local collection = {}
    local schema

    local sortedKeys = {}

    local function get()
        
    end

    local function set()
        
    end

    local function new(uuid)
        if collection[uuid] then
            error("This uuid already exsists in the group, group="..name.." uuid="..uuid, 2)
        end
    end

    local function del()
        
    end

    return table.freeze{
        set = set,
        get = get,
        del = del,
        new = new,
    }
end
