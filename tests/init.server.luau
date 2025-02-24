local DataModule = require(game.ServerScriptService.DataModule)

local init = DataModule.logger.new("[INIT]", "DEBUG")
init:debugf("HELLO WORLD place id = %d", game.PlaceId)