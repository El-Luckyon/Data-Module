--!strict
--!native
--!optimize 2

local utility = script.utility
local logger = require(utility.logger)

local main = logger.new("[DATA-STORE]", "INFO")

main:debugf("Hello from debug %s", "Lol")
main:printf("LOOOOL")

return table.freeze{
    logger = logger
}