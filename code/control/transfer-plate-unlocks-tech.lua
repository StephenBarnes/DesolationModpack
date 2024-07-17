-- IR3's inventory-transfer plates are really nice.
-- But I avoided using them for most of my time playing IR3, and I worry most people will probably do the same.
-- So I'm going to make using them mandatory to unlock an early tech, maybe logistics 1.

-- TODO also change the description and the manifesto page to more of a step-by-step explanation.

-- Couldn't find an easy hook / whatever in IR3 to do this.
-- There's a script event ir-transfer-plate, but it gets called when walking onto the plate, not when items are actually transferred.
-- So, a bit of a kludge: check whether inventory changes in the same tick.
-- When player steps onto a plate, we record the tick. Then when inventory changes, check if it's still the same tick.

local function onScriptEvent(event)
	if event.effect_id == "ir-transfer-plate" then
		global.lastTransferPlateTick = game.tick
	end
end

local function triggerInspiration(force)
	force.technologies["logistics"].researched = true
	-- Do the same stuff as IR3 Inspiration mod.
	force.print(
		{
			"gui.schematic-inspiration", -- defined in IR3 Inspiration mod
			"[img=technology/logistics]",
			game.technology_prototypes.logistics.localised_name
		},
		{sound = defines.print_sound.never})
	force.play_sound({path = "inspiration-chime"})
	for _,player in pairs(force.players) do
		if player and player.valid then
			remote.call("ir-utils", "fading-flying-text-player", player, "[img=inspiration]")
		end
	end
end

local function onPlayerMainInventoryChanged(event)
	if game.tick == global.lastTransferPlateTick then
		local player = game.players[event.player_index]
		if player ~= nil and player.valid and player.force ~= nil and player.force.valid then
			if (player.force.technologies["ir-basic-research"].researched
				and not player.force.technologies["logistics"].researched) then
				triggerInspiration(player.force)
			end
		end
	end
end

------------------------------------------------------------------------

local function register()
	script.on_event(defines.events.on_script_trigger_effect, onScriptEvent)
	-- Looks like it can't be filtered for effect_id.

	script.on_event(defines.events.on_player_main_inventory_changed, onPlayerMainInventoryChanged)
end

local function onInitOrLoad()
	if global.lastTransferPlateTick == nil then
		global.lastTransferPlateTick = -1000
	end
end

return {
	register = register,
	onInit = onInitOrLoad,
	onLoad = onInitOrLoad,
}