-- Control-stage handlers for making the copper and iron offshore pumps require burnable fuel and electricity respectively.
-- See also data/additions/powered-pumps.lua.
-- This code is largely adapted from the BurnerOffshorePump mod by darkfrei.

-- To make burner pumps, we can't use the offshore-pump prototype class, bc it doesn't take energy consumption field.
-- So instead we register duplicate pump entities as assembling machines.
-- Then in control stage (this file), we replace any placed pumps with the new assembling machine.

local replacements = {
	["copper-pump"] = "burner-copper-pump",
	["offshore-pump"] = "electric-offshore-pump",
}

local function onBuiltEntity(event)
	local entity = event.created_entity or event.entity
	local originalName = entity.name
	local replacementName = replacements[originalName]
	if replacementName ~= nil then
		local surface = entity.surface
		local newEntity = surface.create_entity {
			name = replacementName,
			position = entity.position,
			force = entity.force,
			direction = entity.direction,
			fast_replace = true,
			spill = false,
			raise_built = true,
			create_build_effect_smoke = false,
		}

		entity.destroy()

		newEntity.set_recipe("pump-water")
	end
end

return {
	onBuiltEntity = onBuiltEntity,
	onRobotBuiltEntity = onBuiltEntity,
}