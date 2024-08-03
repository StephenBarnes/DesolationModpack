-- This file creates tech, item, and recipe for the ocean scanner capsule.

data:extend({
	{
		type = "capsule",
		name = "ocean-scanner",
		icon = "__Desolation__/graphics/ocean-scanner.png",
		icon_size = 64,
		icon_mipmaps = 4,
		--subgroup = "capsule",
		order = "a",
		stack_size = 20,
		capsule_action = {
			type = "throw",
			uses_stack = false, -- Rather remove the item by script, if thrown into valid tile.
			attack_parameters = {
				type = "projectile",
				range = 10,
				cooldown = 120,
				ammo_type = {
					category = "capsule",
					target_type = "position",
				},
			},
		},
	},
	{
		type = "recipe",
		name = "ocean-scanner",
		subgroup = data.raw.recipe["radar"].subgroup,
		category = data.raw.recipe["radar"].category,
		order = "zz1",
		enabled = false,
		ingredients = {
			{"steel-plate-heavy", 4},
			{"programmable-speaker", 1},
			{"telemetry-unit", 1},
		},
		result = "ocean-scanner",
	},
	{
		type = "technology",
		name = "ocean-scanner",
		icon = "__Desolation__/graphics/ocean-scanner.png",
		icon_size = 256,
		icon_mipmaps = 2,
		prerequisites = {"water_transport", "telemetry"},
		unit = {
			count = 100,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
			},
			time = 30,
		},
		effects = {
			{
				type = "unlock-recipe",
				recipe = "ocean-scanner",
			},
		},
	},
	{
		type = "sound",
		name = "ocean-scanner-plop",
		filename = "__core__/sound/mine-fish.ogg",
	},
	{
		type = "sound",
		name = "ocean-scanner-radar",
		filename = "__base__/sound/radar.ogg",
	},
})