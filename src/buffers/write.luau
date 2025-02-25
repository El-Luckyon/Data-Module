--!native
--!optimize 2

-- writer.luau
-- writes multiple data to a buffer and once writing is completed can pop the packed buffer

local DEFAULT_SIZE = 512

local buff : buffer = buffer.create(DEFAULT_SIZE)
local cursor : number = 0
local size : number = DEFAULT_SIZE

local create = buffer.create
local copy   = buffer.copy

local function realloc(bytes: number)
    if cursor + bytes < size then 
        return
    end

    size = size * 2
    local newBuff = create(size)
    copy(newBuff, 0, buff, 0, cursor)
    buff = newBuff
end

local function mul_realloc(bytes: number)
    while cursor + bytes >= size do
        size = size * 2
    end

    local newBuffer = buffer.create(size)
    buffer.copy(newBuffer, 0, buff)
    buff = newBuffer
end

local function pop()
    local newBuffer = create(cursor)
    copy(newBuffer, 0, buff, 0, cursor)
    cursor = 0
    return newBuffer
end

-----------------------------------------------------------
-- Cached (raw) write functions from the buffer API.
-----------------------------------------------------------
local raw_write_u8  = buffer.writeu8
local raw_write_u16 = buffer.writeu16
local raw_write_u32 = buffer.writeu32
local raw_write_i8  = buffer.writei8
local raw_write_i16 = buffer.writei16
local raw_write_i32 = buffer.writei32
local raw_write_f32 = buffer.writef32
local raw_write_f64 = buffer.writef64
local raw_write_str = buffer.writestring

-----------------------------------------------------------
-- Safe write functions (with reallocation check)
-----------------------------------------------------------

local function writeu8(v : number)
    realloc(1)
    raw_write_u8(buff, cursor, v)
    cursor += 1
end

local function writeu16(v : number)
    realloc(2)
    raw_write_u16(buff, cursor, v)
    cursor += 2
end

local function writeu32(v : number)
    realloc(4)
    raw_write_u32(buff, cursor, v)
    cursor += 4
end

local function writei8(v : number)
    realloc(1)
    raw_write_i8(buff, cursor, v)
    cursor += 1
end

local function writei16(v : number)
    realloc(2)
    raw_write_i16(buff, cursor, v)
    cursor += 2
end

local function writei32(v : number)
    realloc(4)
    raw_write_i32(buff, cursor, v)
    cursor += 4
end

local function writef32(v : number)
    realloc(4)
    raw_write_f32(buff, cursor, v)
    cursor += 4
end

local function writef64(v : number)
    realloc(8)
    raw_write_f64(buff, cursor, v)
    cursor += 8
end

local function writeString(v : string)
    local fieldSize = #v
    mul_realloc(fieldSize)
    raw_write_str(buff, cursor, v, fieldSize)
    cursor += fieldSize
end

local function writebool(v : boolean)
    realloc(1)
    raw_write_u8(buff, cursor, (v and 1) or 0)
    cursor += 1
end

local function move(newCursor : number)
    cursor = newCursor
end

-----------------------------------------------------------
-- Rewrite functions (no reallocation check)
-- These write directly at the current cursor using the
-- cached (raw) write functions.
-----------------------------------------------------------

local function rewriteu8(v : number)
    raw_write_u8(buff, cursor, v)
    cursor += 1
end

local function rewriteu16(v : number)
    raw_write_u16(buff, cursor, v)
    cursor += 2
end

local function rewriteu32(v : number)
    raw_write_u32(buff, cursor, v)
    cursor += 4
end

local function rewritei8(v : number)
    raw_write_i8(buff, cursor, v)
    cursor += 1
end

local function rewritei16(v : number)
    raw_write_i16(buff, cursor, v)
    cursor += 2
end

local function rewritei32(v : number)
    raw_write_i32(buff, cursor, v)
    cursor += 4
end

local function rewritef32(v : number)
    raw_write_f32(buff, cursor, v)
    cursor += 4
end

local function rewritef64(v : number)
    raw_write_f64(buff, cursor, v)
    cursor += 8
end

local function rewriteString(v : string)
    local fieldSize = #v
    raw_write_str(buff, cursor, v, fieldSize)
    cursor += fieldSize
end

local function rewritebool(v : boolean)
    raw_write_u8(buff, cursor, (v and 1) or 0)
    cursor += 1
end

-----------------------------------------------------------
-- Export the functions
-----------------------------------------------------------

return table.freeze{
    -- Safe writes (with reallocation)
    writeu8    = writeu8,
    writeu16   = writeu16,
    writeu32   = writeu32,
    writei8    = writei8,
    writei16   = writei16,
    writei32   = writei32,
    writef32   = writef32,
    writef64   = writef64,
    writeString = writeString,
    writebool  = writebool,
    
    -- Rewrite functions (no reallocation)
    rewriteu8    = rewriteu8,
    rewriteu16   = rewriteu16,
    rewriteu32   = rewriteu32,
    rewritei8    = rewritei8,
    rewritei16   = rewritei16,
    rewritei32   = rewritei32,
    rewritef32   = rewritef32,
    rewritef64   = rewritef64,
    rewriteString = rewriteString,
    rewritebool  = rewritebool,
    
    pop        = pop,
    move       = move,
    realloc    = realloc,
    mul_realloc = mul_realloc,
}
