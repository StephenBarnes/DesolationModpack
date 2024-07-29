-- Calls to IR3 remote interfaces at the start of the game.
local globalParams = require("code.global-params")

function onInitOrLoad()
	-- Disable the intro cutscene when debugging
	remote.call("ir-world", "set-intro-cutscene", globalParams.runIntroCutscene)
end

return {
	onInit = onInitOrLoad,
	onLoad = onInitOrLoad,
}