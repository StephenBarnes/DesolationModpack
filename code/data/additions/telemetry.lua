-- This file adds the telemetry tech, and the "telemetry unit" item.

local telemetryTech = {
	type = "technology",
	name = "telemetry",
	icon = "__Desolation__/graphics/telemetry-tech-256-128.png",
	icon_size = 256,
	icon_mipmaps = 2,
	prerequisites = {"ir-electronics-1", "ir-bronze-telescope"},
	effects = {
		{
			type = "unlock-recipe",
			recipe = "telemetry-unit"
		}
	},
	unit = data.raw.technology["ir-radar"].unit,
}

local telemetryItem = {
	type = "item",
	name = "telemetry-unit",
	icon = "__Desolation__/graphics/telemetry-unit-4mipmaps.png",
	icon_size = 64,
	icon_mipmaps = 4,
	subgroup = "intermediate-product",
	order = "a", -- TODO
	stack_size = 20,
}

local telemetryUnitRecipe = {
	type = "recipe",
	name = "telemetry-unit",
	enabled = false,
	energy_required = 10,
	ingredients = {
		{"iron-plate", 2}, -- instead of a small frame
		{"iron-rivet", 1},
		{"electronic-circuit", 2},
		{"copper-cable", 1},
	},
	order = "a", -- TODO
	result = "telemetry-unit",
}

-- TODO add as ingredient for airship station
-- TODO add as ingredient for roboports, rockets, rocket turrets, searchlights, roboport equipment, laser turret, combat bots, spidertron, deep space miner, artillery turret, artillery cannon, maybe more.
-- TODO add as ingredient in rocket control unit
-- TODO add as ingredient in airships, and maybe other vehicles
-- TODO add as ingredient in the logistic and construction bots
-- TODO maybe get an alternative icon for the tech, or the item?

data:extend({telemetryTech, telemetryItem, telemetryUnitRecipe})

-- Adjust recipe for radar to include this.
data.raw.recipe["radar"].ingredients = {
	{"iron-frame-small", 1},
	{"iron-plate", 2}, -- for the "dish"
	{"telemetry-unit", 1},
	{"copper-coil", 2}, -- iron core EM coil
	{"copper-cable-heavy", 1}, -- heavy copper cable - requires rubber.
}
data.raw.recipe["radar"].energy_required = 10 -- bc 1 second seems too little.