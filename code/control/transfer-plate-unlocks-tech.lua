-- IR3's inventory-transfer plates are really nice.
-- But I avoided using them for most of my time playing IR3, and I worry most people will probably do the same.
-- So I'm going to make using them mandatory to unlock an early tech, maybe logistics 1.

-- TODO also change the description and the manifesto page to more of a step-by-step explanation.

local function onTransferPlateOrHotkey(event)
	if event.identity ~= "transfer-plate" then return end
	local player = game.players[event.player_index]
	if player ~= nil and player.valid and player.force ~= nil and player.force.valid then
		if (player.force.technologies["ir-basic-research"].researched
			and not player.force.technologies["logistics"].researched) then
			remote.call("ir3-inspiration", "trigger_technology", nil, "logistics", player.force)
		end
	end
end

local function onInitOrLoad()
	local transferPlateEventId = remote.call("ir-events", "get-event-id", "on_transfer_plate_or_hotkey")
	script.on_event(transferPlateEventId, onTransferPlateOrHotkey)
end

return {
	onInit = onInitOrLoad,
	onLoad = onInitOrLoad,
}