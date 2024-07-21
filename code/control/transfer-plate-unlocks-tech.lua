-- IR3's inventory-transfer plates are really nice.
-- But I avoided using them for most of my time playing IR3, and I worry most people will probably do the same.
-- So I'm going to make using them mandatory to unlock an early tech, maybe logistics 1.

-- TODO also change the description and the manifesto page to more of a step-by-step explanation.

-- Couldn't find an easy hook / whatever in IR3 to do this.
-- There's a script event ir-transfer-plate, but it gets called when walking onto the plate, not when items are actually transferred.
-- So, a bit of a kludge: check whether inventory changes in the same tick.
-- When player steps onto a plate, we record the tick. Then when inventory changes, check if it's still the same tick.

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

------------------------------------------------------------------------

local function onInitOrLoad()
	local transferPlateEventId = remote.call("ir-events", "get-event-id", "on_transfer_plate_or_hotkey")
	script.on_event(transferPlateEventId, onTransferPlateOrHotkey)
end

return {
	onInit = onInitOrLoad,
	onLoad = onInitOrLoad,
}