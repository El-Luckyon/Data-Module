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

local locked = false

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

local function move(newCursor : number)
    cursor = newCursor
end

local function lock()
    if locked then 
        repeat
             task.wait() 
        until not locked 
    end
    locked = true
end

local function unlock()
    locked = false
end

local function getCursor()
    return cursor
end

local function writeCopy(v : buffer)
    local fieldSize = buffer.len(v)
    mul_realloc(fieldSize)
    buffer.copy(buff, cursor, v)
    cursor += fieldSize
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
    mul_realloc(fieldSize + 4)
    raw_write_u32(buff, cursor, fieldSize)
    cursor += 4
    raw_write_str(buff, cursor, v, fieldSize)
    cursor += fieldSize
end

local function writeShortString(v : string)
    local fieldSize = #v 
    mul_realloc(fieldSize + 1)
    raw_write_u8(buff, cursor, fieldSize)
    cursor += 1
    raw_write_str(buff, cursor, v, fieldSize)
    cursor += fieldSize
end

local function writeStaticString(v : string)
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

-----------------------------------------------------------
-- Unchecked write functions (no reallocation check)
-- These simply write directly at the current cursor using
-- the cached raw functions.
-----------------------------------------------------------

local function uncheckedWriteu8(v : number)
    raw_write_u8(buff, cursor, v)
    cursor += 1
end

local function uncheckedWriteu16(v : number)
    raw_write_u16(buff, cursor, v)
    cursor += 2
end

local function uncheckedWriteu32(v : number)
    raw_write_u32(buff, cursor, v)
    cursor += 4
end

local function uncheckedWritei8(v : number)
    raw_write_i8(buff, cursor, v)
    cursor += 1
end

local function uncheckedWritei16(v : number)
    raw_write_i16(buff, cursor, v)
    cursor += 2
end

local function uncheckedWritei32(v : number)
    raw_write_i32(buff, cursor, v)
    cursor += 4
end

local function uncheckedWritef32(v : number)
    raw_write_f32(buff, cursor, v)
    cursor += 4
end

local function uncheckedWritef64(v : number)
    raw_write_f64(buff, cursor, v)
    cursor += 8
end

local function uncheckedWriteString(v : string)
    local fieldSize = #v
    raw_write_u32(buff, cursor, fieldSize)
    cursor += 4
    raw_write_str(buff, cursor, v, fieldSize)
    cursor += fieldSize
end

local function uncheckedWriteShortString(v : string)
    local fieldSize = #v
    raw_write_u8(buff, cursor, fieldSize)
    cursor += 1
    raw_write_str(buff, cursor, v, fieldSize)
    cursor += fieldSize
end

local function uncheckedWritebool(v : boolean)
    raw_write_u8(buff, cursor, (v and 1) or 0)
    cursor += 1
end

-----------------------------------------------------------
-- WriteInplaceAt functions
-- These functions take a second argument "pos" and write the value
-- at that buffer offset without modifying the module’s global cursor.
-----------------------------------------------------------

local function writeInplaceu8(v : number, pos : number)
    raw_write_u8(buff, pos, v)
end

local function writeInplaceu16(v : number, pos : number)
    raw_write_u16(buff, pos, v)
end

local function writeInplaceu32(v : number, pos : number)
    raw_write_u32(buff, pos, v)
end

local function writeInplacei8(v : number, pos : number)
    raw_write_i8(buff, pos, v)
end

local function writeInplacei16(v : number, pos : number)
    raw_write_i16(buff, pos, v)
end

local function writeInplacei32(v : number, pos : number)
    raw_write_i32(buff, pos, v)
end

local function writeInplacef32(v : number, pos : number)
    raw_write_f32(buff, pos, v)
end

local function writeInplacef64(v : number, pos : number)
    raw_write_f64(buff, pos, v)
end

local function writeInplaceString(v : string, pos : number)
    local fieldSize = #v
    raw_write_u32(buff, pos, fieldSize)
    pos = pos + 4
    raw_write_str(buff, pos, v, fieldSize)
end

local function writeInplaceShortString(v : string, pos : number)
    local fieldSize = #v
    raw_write_u8(buff, pos, fieldSize)
    pos = pos + 1
    raw_write_str(buff, pos, v, fieldSize)
end

local function writeInplacebool(v : boolean, pos : number)
    raw_write_u8(buff, pos, (v and 1) or 0)
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
    writeShortString = writeShortString,
    writestaticString = writeStaticString,
    
    -- Unchecked write functions (no reallocation check)
    uncheckedWriteu8    = uncheckedWriteu8,
    uncheckedWriteu16   = uncheckedWriteu16,
    uncheckedWriteu32   = uncheckedWriteu32,
    uncheckedWritei8    = uncheckedWritei8,
    uncheckedWritei16   = uncheckedWritei16,
    uncheckedWritei32   = uncheckedWritei32,
    uncheckedWritef32   = uncheckedWritef32,
    uncheckedWritef64   = uncheckedWritef64,
    uncheckedWriteString = uncheckedWriteString,
    uncheckedWritebool  = uncheckedWritebool,
    uncheckedWriteShortString = uncheckedWriteShortString,
    
    -- WriteInplaceAt functions (write at a specified offset without modifying global cursor)
    writeInplaceu8    = writeInplaceu8,
    writeInplaceu16   = writeInplaceu16,
    writeInplaceu32   = writeInplaceu32,
    writeInplacei8    = writeInplacei8,
    writeInplacei16   = writeInplacei16,
    writeInplacei32   = writeInplacei32,
    writeInplacef32   = writeInplacef32,
    writeInplacef64   = writeInplacef64,
    writeInplaceString = writeInplaceString,
    writeInplacebool  = writeInplacebool,
    writeInplaceShortString = writeInplaceShortString,
    
    copy = writeCopy,
    pop        = pop,
    move       = move,
    realloc    = realloc,
    mul_realloc = mul_realloc,
    
    lock = lock,
    unlock = unlock,
    cursor = getCursor,
}
