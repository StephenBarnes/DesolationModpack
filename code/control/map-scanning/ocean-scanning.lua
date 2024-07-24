-- Control-stage handlers for the ocean scanner pods.

local function reportIncorrectTile(player)
	player.create_local_flying_text{
		text = {"Desolation-message.scan-ocean-incorrect-tile"},
		create_at_cursor = true,
		time_to_live = 60,
	}
end

local function onCapsuleThrown(event)
	--game.print("Capsule thrown")
	if event.item.name ~= "ocean-scanner" then return end
	local tile = game.surfaces[1].get_tile(event.position.x, event.position.y)
	if tile.name ~= "deepwater" then
		reportIncorrectTile(game.players[event.player_index])
		return
	end
	game.play_sound{path = "ocean-scanner-plop", position = event.position}
	game.play_sound{path = "ocean-scanner-radar", position = event.position, volume_modifier = 0.6}
	game.players[event.player_index].force.print({"Desolation-message.scan-ocean-start"})
	-- TODO remove an item from the stack.
	-- TODO initiate the scan.
end

-- Use updateScanOnce with minLandTiles = nil, maxLandTiles = 30.

return {
	onCapsuleThrown = onCapsuleThrown,
}