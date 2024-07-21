-- This script is to notify players that they forgot to use the correct mapgen preset.

local function registerRepeatingMessage()
	script.on_nth_tick(60 * 15, function(event)
		game.print({"Desolation-message.incorrect-mapgen-preset"})
	end)
end

local function onPlayerCreated(event)
	local player = game.players[event.player_index]
	local surface = player.surface
	if surface.map_gen_settings.property_expression_names["elevation"] ~= "Desolation-islands-elevation" then
		registerRepeatingMessage()
	end
end

return {
	onPlayerCreated = onPlayerCreated,
}