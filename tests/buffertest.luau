--!native
--!optimize 2

local writer = require(game.ServerScriptService.DataModule.buffers.write)

local ITER = 100000


local function benchmarkAvg(label: string, f, ...)
    local total = 0
    local args = {...}
    for i = 1, ITER do
        local startTime = os.clock()
        f(table.unpack(args))
        total = total + (os.clock() - startTime)
        writer.move(0)
    end
    local avg = total / ITER
    print(label .. " avg: " .. string.format("%.16f", avg) .. " sec")
end

------------------------------------
-- Safe Write Benchmarks
------------------------------------
benchmarkAvg("writeu8", writer.writeu8, 255)
benchmarkAvg("writeu16", writer.writeu16, 65535)
benchmarkAvg("writeu32", writer.writeu32, 4294967295)
benchmarkAvg("writei8", writer.writei8, -128)
benchmarkAvg("writei16", writer.writei16, -32768)
benchmarkAvg("writei32", writer.writei32, -2147483648)
benchmarkAvg("writef32", writer.writef32, 3.14)
benchmarkAvg("writef64", writer.writef64, 2.718281828459045)
benchmarkAvg("writebool (true)", writer.writebool, true)
benchmarkAvg("writeString (short)", writer.writeString, "Hello")
benchmarkAvg("writeString (long)", writer.writeString, string.rep("A", 512))

------------------------------------
-- Rewrite Benchmarks
------------------------------------
benchmarkAvg("rewriteu8", writer.rewriteu8, 127)
benchmarkAvg("rewriteu16", writer.rewriteu16, 32767)
benchmarkAvg("rewriteu32", writer.rewriteu32, 2147483647)
benchmarkAvg("rewritei8", writer.rewritei8, -64)
benchmarkAvg("rewritei16", writer.rewritei16, -16384)
benchmarkAvg("rewritei32", writer.rewritei32, -1073741824)
benchmarkAvg("rewritef32", writer.rewritef32, 1.618)
benchmarkAvg("rewritef64", writer.rewritef64, 0.5772156649)
benchmarkAvg("rewritebool (true)", writer.rewritebool, true)
benchmarkAvg("rewriteString (short)", writer.rewriteString, "World")
benchmarkAvg("rewriteString (long)", writer.rewriteString, string.rep("B", 512))

return nil
