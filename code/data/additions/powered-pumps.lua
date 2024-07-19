-- Make the pumps require steam or electricity.

-- Looking at the offshore-pump prototype API, and this mod: https://mods.factorio.com/mod/BurnerOffshorePump
-- Used some code from that mod by darkfrei. It's MIT licensed.
-- It seems there's no way to make normal pumps require electricity or burnable fuel.
-- So instead, we have to make new entities that replace those as soon as they're placed. The new entities are registered as assembling-machines.
-- (Minor issue: this isn't compatible with blueprints. However, not a big problem since landfill / waterfill will be expensive, so you'll probably manually place pumps anyway.)

-- Entity copper-pump should require burnable fuel.
-- Entity offshore-pump should require electricity.

-- Create a recipe and recipe category for pumping water.
local pumpWaterRecipeCategory = { name = "pumping-water", type = "recipe-category" }
local pumpWaterRecipe = {
	type = "recipe",
	name = "pump-water",
	category = "pumping-water",
	hidden = true,
	enabled = true,
	hide_from_stats = false, -- Darkfrei is using false here, so assuming that's good.
	icon = "__base__/graphics/icons/fluid/water.png",
	icon_size = 64,
	icon_mipmaps = 4,
	subgroup = "fluid-recipes",
	order = "a",
	ingredients = {},
	results = {{type = "fluid", name = "water", amount = 300}},
	energy_required = 1,
}

-- Create assembling machine that replaces the copper-pump.
local copperPumpAssemblingMachine = {
	type = "assembling-machine",
	name = "burner-copper-pump",
	icon = data.raw["offshore-pump"]["copper-pump"].icon,
	icon_size = data.raw["offshore-pump"]["copper-pump"].icon_size,
	icon_mipmaps = data.raw["offshore-pump"]["copper-pump"].icon_mipmaps,
	max_health = data.raw["offshore-pump"]["copper-pump"].max_health,
	resistances = data.raw["offshore-pump"]["copper-pump"].resistances,
	minable = data.raw["offshore-pump"]["copper-pump"].minable,
	flags = {"placeable-player", "placeable-off-grid"}, -- TODO what does the off-grid flag do?
	dying_explosion = data.raw["offshore-pump"]["copper-pump"].dying_explosion,
	collision_box = data.raw["offshore-pump"]["copper-pump"].collision_box,
	selection_box = data.raw["offshore-pump"]["copper-pump"].selection_box,
	vehicle_impact_sound = data.raw["offshore-pump"]["copper-pump"].vehicle_impact_sound,
	working_sound = data.raw["offshore-pump"]["copper-pump"].working_sound,
	fluid_boxes = {data.raw["offshore-pump"]["copper-pump"].fluid_box},
	picture = data.raw["offshore-pump"]["copper-pump"].picture,
	placeable_by = {item = "copper-pump", count = 1}, -- So picker works correctly.
	corpse = data.raw["offshore-pump"]["copper-pump"].corpse,
	water_reflection = data.raw["offshore-pump"]["copper-pump"].water_reflection,
	created_smoke = data.raw["offshore-pump"]["copper-pump"].created_smoke,
	animation = data.raw["offshore-pump"]["copper-pump"].graphics_set.animation,
	localised_description = {"entity-description.copper-pump"},
	localised_name = {"entity-name.copper-pump"},
	crafting_categories = {"pumping-water"},
	crafting_speed = 1,
	fixed_recipe = "pump-water",

	energy_source = {
		type = "burner",
		fuel_categories = {"chemical", "coke"}, -- Same as furnaces.
		effectivity = 1,
		fuel_inventory_size = 1,
		emission_per_minute = 3,
	},
	energy_usage = "600kW", -- This means it's about 15 crushed coal to fill an entire big tank (25k water).
}

data:extend({pumpWaterRecipeCategory, pumpWaterRecipe, copperPumpAssemblingMachine})