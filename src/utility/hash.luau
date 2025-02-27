--!native
--!optimize 2

-- hash.luau
-- hash any data type into a string

-- hash algorithm optimized for this modules use, user must ensure that there is no collisions by providing varying samples
return function(dataType : any) : string
    local hash = "__null__"
    local t = typeof(dataType)

    if t == "string" then
        hash = dataType
    elseif t == "boolean" then
        hash = dataType and "1" or "0"
    elseif t == "number" then
        hash = tostring(dataType) 
    elseif t == "vector3" then
        hash = "/v"..tostring(dataType.X)
    elseif t == "CFrame" then
        hash = "/c"..tostring(dataType.X)
    elseif t == "Color3" then
        hash = "/o"..tostring(dataType.R)
    elseif t == "UDim2" then
        hash = "/u"..tostring(dataType.X.Scale)
    elseif t == "vector2" then
        hash = "/2"..tostring(dataType.X)
    elseif t == "BrickColor" then
        hash = "/b"..tostring(dataType.Color3.R)
    end

    return hash
end
