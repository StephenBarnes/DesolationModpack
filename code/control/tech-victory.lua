local globalParams = require("code.global-params")

local function victory(force)
	global.finished = true
	if remote.interfaces["better-victory-screen"] and remote.interfaces["better-victory-screen"]["trigger_victory"] then
		remote.call("better-victory-screen", "trigger_victory", force, false, {"Desolation-message.game-victory"}, {"Desolation-message.game-lost"})
		-- Documentation: https://github.com/heinwessels/factorio-better-victory-screen/blob/main/mod-page/compatibility.md
	else
		log("ERROR: BetterVictoryScreen interface not found. Falling back on vanilla victory screen.")
		game.set_game_state {
			game_finished = true,
			player_won = true, -- I think this param is true if ANY player won, not necessarily the client running this code. No docs.
			can_continue = true,
			victorious_force = force,
		}
	end
end

local function onResearchFinished(event)
	local tech = event.research
	local force = event.research.force
	if force.name == "enemy" or force.name == "ir-sims" then return end
		-- The force ir-sims gets all techs researched when user opens manifesto for the first time in a game.
	if game.finished or game.finished_but_continuing or global.finished then return end

	if tech.name == "long-range-transmaterialisation" then
		if globalParams.victoryOnFinalTech then
			if game.tick > globalParams.victoryMinTicks then
				log("Victory for force "..(force.name or "nil").." due to researching final tech.")
				victory(force)
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