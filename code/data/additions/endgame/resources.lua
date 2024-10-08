-- This file implements some extra materials to extend the endgame a bit.
-- Specifically, we want to:
-- * Add a fluid called "immateria"
-- * Add fissure entities that emit immateria
-- * (In resource-placing.lua, we'll make the immateria fissures get autoplaced on terrain generation.)
-- * Add a new item called "spagyric crystals"
-- * Add a new item called "elixir stone"
-- * Add a new recipe for the supermagnet, which combines spagyric crystals with immateria to produce an elixir stone
-- * Add a new recipe for the supermagnet, which uses elixir stone + stone to produce elixir stone + gold.

local immateriaFluid = {
	type = "fluid",
	name = "immateria",
	icon = "__Desolation__/graphics/immateria-spiral-4mipmaps.png",
	icon_size = 64,
	icon_mipmaps = 4,
	flow_color = {r = 1.0, g = 0.0, b = 0.0},
	base_color = {r = 1.0, g = 0.0, b = 0.0},
	default_temperature = 15,
	gas_temperature = 0,
	subgroup = data.raw.fluid.water.subgroup,
	order = "zzzz-s",
	auto_barrel = false, -- don't create barrelling recipes.
	localised_description = {"fluid-description.immateria"},
}

local spagyricCrystalItem = {
	type = "item",
	name = "spagyric-crystal",
	icon = "__Desolation__/graphics/spagyric-crystals.png",
	icon_size = 64,
	icon_mipmaps = 4,
	stack_size = 100,
	subgroup = data.raw.item["diamond-gem"].subgroup,
	order = "zzz-z-y", -- after charged electrum gem
}

local elixirItem = {
	type = "tool",
	name = "elixir-stone",
	icon = "__Desolation__/graphics/elixir-stone.png",
	icon_size = 64,
	icon_mipmaps = 4,
	stack_size = 100,
	subgroup = data.raw.item["diamond-gem"].subgroup,
	order = "zzz-z-z",
	durability = data.raw.tool["space-science-pack"].durability,
}

-- Make a new recipe category for elixir stone, and add it to the arc furnace's crafting categories.
local elixirRecipeCategory = {
	type = "recipe-category",
	name = "elixir-stone-category",
	order = "z",
}
table.insert(data.raw["assembling-machine"]["arc-furnace"].crafting_categories, "elixir-stone-category")

-- Add a new item subgroup for the elixir stone, and place it underneath IR3's gemstones.
local elixirItemSubgroup = {
	type = "item-subgroup",
	name = "elixir-stone-subgroup",
	group = "ir-processing",
	order = "ca2",
}
local elixirRecipe = {
	type = "recipe",
	name = "elixir-stone",
	category = "elixir-stone-category",
	subgroup = "elixir-stone-subgroup",
	energy_required = 150,
	ingredients = {
		{type = "item", name = "spagyric-crystal", amount = 1},
		{type = "fluid", name = "immateria", amount = 1000}
	},
	results = {
		{type = "item", name = "elixir-stone", amount = 1}
	},
	enabled = false,
	always_show_made_in = true,
	main_product = "elixir-stone",
	order = "zzz-0",
	-- TODO set crafting machine tints
}
elixirRecipe.crafting_machine_tint = data.raw.recipe["chromium-molten-from-ingot"].crafting_machine_tint
elixirRecipe.crafting_machine_tint[1] = {1, 1, 1} -- It doesn't look like this is actually used by the arc furnace.
-- Un-fix the recipe for the supermagnet, since we're now adding alternative recipes.
--data.raw["assembling-machine"]["supermagnet"].fixed_recipe = nil
-- Actually, supermagnet's animation shows it as being for the field-aligned electrum crystal. So rather use the blast furnace.

--log(serpent.block(data.raw.resource["fossil-gas-fissure"]))
local immateriaFissure = table.deepcopy(data.raw.resource["fossil-gas-fissure"])
immateriaFissure.name = "immateria-fissure"
immateriaFissure.icons = {
	{
		icon = "__IndustrialRevolution3Assets1__/graphics/icons/64/generic-fissure.png",
		icon_mipmaps = 4,
		icon_size = 64
	},
	{
		icon = "__Desolation__/graphics/immateria-spiral-4mipmaps.png",
		icon_mipmaps = 4,
		icon_size = 64,
		scale = 0.25,
		shift = {
			0,
			-8
		}
	},
}
immateriaFissure.map_color = {
	r = 1.0,
	g = 0.3,
	b = 0.3,
}
immateriaFissure.localised_name = {
	"entity-name.gas-fissure",
	{ "fluid-name.immateria" },
}
immateriaFissure.localised_description = {"entity-description.immateria-fissure"}
immateriaFissure.minable.results[1].name = "immateria"

local immateriaParticleSource = table.deepcopy(data.raw["particle-source"]["fossil-gas-fissure-smoke"])
immateriaParticleSource.name = "immateria-fissure-smoke"
immateriaParticleSource.smoke[1].name = "immateria-fissure-soft-smoke"

local immateriaSmoke = table.deepcopy(data.raw["trivial-smoke"]["fossil-gas-fissure-soft-smoke"])
immateriaSmoke.name = "immateria-fissure-soft-smoke"
immateriaSmoke.color = {
	a = 0.25,
	r = 0.25,
	g = 0.04,
	b = 0.04,
}

-- IR3 seems to use fake items called eg "fossil-gas-spill-data" to store the pollution spill multiplier, etc.
--log("for item 'fossil-gas-spill-data': "..serpent.block(data.raw.item["fossil-gas-spill-data"]))
--log("for item 'crude-oil-spill-data': "..serpent.block(data.raw.item["crude-oil-spill-data"]))
local immateriaSpillData = table.deepcopy(data.raw.item["fossil-gas-spill-data"])
immateriaSpillData.name = "immateria-spill-data"
immateriaSpillData.localised_name[2] = {"fluid-name.immateria"}
immateriaSpillData.icon = "__Desolation__/graphics/immateria-spiral-4mipmaps.png"
immateriaSpillData.icon_size = 64
immateriaSpillData.icon_mipmaps = 4
immateriaSpillData.fuel_emissions_multiplier = 1.0 -- This field stores pollution multiplier. It's 1 for crude oil, 0.5 for fossil gas.
-- I've checked, this works.

-- Add the spagyrite byproduct to comet ice recipe.
table.insert(data.raw.recipe["comet-ice-processing"].results, {
	type = "item",
	name = "spagyric-crystal",
	amount = 1,
	probability = 0.1,
})
-- Add the spagyrite icon to the recipe icon.
data.raw.recipe["comet-ice-processing"].icons = {
	{
		icon = data.raw.recipe["comet-ice-processing"].icon,
		icon_size = data.raw.recipe["comet-ice-processing"].icon_size,
		icon_mipmaps = data.raw.recipe["comet-ice-processing"].icon_mipmaps,
		scale = 0.5,
	},
	{
		icon = "__Desolation__/graphics/spagyric-crystals.png",
		icon_size = 64,
		icon_mipmaps = 4,
		scale = 0.23,
		shift = {1, 8},
	},
}

data:extend({immateriaFluid, spagyricCrystalItem, elixirItem, elixirRecipeCategory, elixirItemSubgroup, elixirRecipe, immateriaFissure, immateriaParticleSource, immateriaSmoke, immateriaSpillData})

-- Quantum lab should accept elixir stone.
table.insert(data.raw.lab["quantum-lab"].inputs, "elixir-stone")
-- Quantum lab description has the icons of analysis packs it accepts. So append elixir stone icon at the end.
data.raw.lab["quantum-lab"].localised_description = {"", data.raw.lab["quantum-lab"].localised_description, "[img=item/elixir-stone]"}