-- Calls to IR3 remote interfaces at the start of the game.
local globalParams = require("code.global-params")

local setIr3IntroCutscene = function()
	--game.print("Setting IR3 intro cutscene to "..globalParams.runIntroCutscene)
	--log("Setting IR3 intro cutscene to "..globalParams.runIntroCutscene)
	remote.call("ir-world", "set-intro-cutscene", globalParams.runIntroCutscene)
end

function onInitOrLoad()
	setIr3IntroCutscene()
	-- Other stuff
	--editWoodInspiration()
end

return {
	onInit = onInitOrLoad,
	onLoad = onInitOrLoad,
}