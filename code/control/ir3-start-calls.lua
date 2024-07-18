-- Calls to IR3 remote interfaces at the start of the game.
local globalParams = require("code.global-params")

local X = {}

local setIr3IntroCutscene = function()
	--game.print("Setting IR3 intro cutscene to "..globalParams.runIntroCutscene)
	--log("Setting IR3 intro cutscene to "..globalParams.runIntroCutscene)
	remote.call("ir-world", "set-intro-cutscene", globalParams.runIntroCutscene)
end

local editWoodInspiration = function()
	local woodTech = remote.call("ir3-inspiration", "get_technology", "ir-basic-wood")
	woodTech.IR_schematic_count_needed = 4
	remote.call("ir3-inspiration", "set_technologies", {["ir-basic-wood"] = woodTech})
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