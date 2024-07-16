-- Calls to IR3 remote interfaces at the start of the game.
local globalParams = require("code.global-params")

local X = {}

local setIr3IntroCutscene = function()
	remote.call("ir-world", "set-intro-cutscene", globalParams.runIntroCutscene)
end

function X.register()
	script.on_init(setIr3IntroCutscene)
end

return X