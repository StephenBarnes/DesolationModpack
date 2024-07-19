-- This file just exists to notify people that the searchlight assault scenario doesn't really work with this modpack.

local function endPrisonBreakScenario()
	game.print({"Desolation-message.searchlight-assault-scenario-not-supported"})
	game.show_message_dialog {
		text = {"Desolation-message.searchlight-assault-scenario-not-supported"},
	}
	game.set_game_state {
		game_finished = true,
		player_won = false,
		can_continue = false,
	}
end

local function onGameCreatedFromScenario(event)
	--log("SABBB "..serpent.block(script.level))
	if string.match(script.level.level_name, "prisonbreak") or string.match(script.level.mod_name, "SearchlightAssault") then
		log("Found Searchlight Assault scenario. Notifying player and then ending it.")
		script.on_event(defines.events.on_player_created, endPrisonBreakScenario)
	end
end

local function register()
	script.on_event(defines.events.on_game_created_from_scenario, onGameCreatedFromScenario)
end

return {
	register = register,
}