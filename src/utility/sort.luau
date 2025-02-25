--!native
--!optimize 2

-- sort.luau
-- sorts the given hash map lexiographically

return function(map : {[string] : any}) : ({string}, {any})
  
    local keys = {}
    local values = {}

    for k, v in map do
        table.insert(keys, k)
    end

    table.sort(keys)

    for i = 1, #keys do
        values[i] = map[keys[i]]
    end

    return keys, values
end