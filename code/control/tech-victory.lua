local globalParams = require("code.global-params")

local function onResearchFinished(event)
	local tech = event.research
	local force = event.research.force
	if tech.name == "long-range-transmaterialisation" then
		if globalParams.victoryOnFinalTech then
			if game.tick > globalParams.victoryMinTicks then
				game.set_game_state {
					game_finished = true,
					player_won = true,
					can_continue = true,
					victorious_force = force,
				}
			else
				force.print("(Would have won due to finishing final tech, but it's very early in the game, assuming sandbox or testing.)")
				log("WARNING: Would have won due to finishing final tech, but it's very early in the game, assuming sandbox or testing.")
			end
		end
	end
end

return {
	onResearchFinished = onResearchFinished,
}