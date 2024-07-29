-- This file implements some extra materials to extend the endgame a bit.
-- Specifically, we want to:
-- * Add a fluid called "immateria"
-- * Add fissure entities that emit immateria
-- * (In resource-placing.lua, we'll make the immateria fissures get autoplaced on terrain generation.)
-- * Add a new item called "spagyric crystals"
-- * Add a new item called "elixir stone"
-- * Add a new recipe for the supermagnet, which combines spagyric crystals with immateria to produce an elixir stone
-- * Add a new recipe for the supermagnet, which uses elixir stone + stone to produce elixir stone + gold.
-- * Add a new technology that unlocks this recipe to produce the elixir stone, and to transmute gold

local immateriaFluid = {
	type = "fluid",
	name = "immateria",
	icon = "__Desolation__/graphics/immateria-no-outline-4mipmaps.png",
	icon_size = 64,
	icon_mipmaps = 4,
	flow_color = {r = 1.0, g = 0.0, b = 0.0},
	base_color = {r = 1.0, g = 0.0, b = 0.0},
	default_temperature = 15,
	gas_temperature = 0,
	subgroup = data.raw.fluid.water.subgroup,
	order = "zzzz-s",
	auto_barrel = false, -- don't create barrelling recipes.
}
-- TODO need to make IR3 create pollution when this is flushed, like the other gases.

local elixirStoneTech = {
	type = "technology",
	name = "magnum-opus",
	icon = "__Desolation__/graphics/immateria-with-outline-256-128.png",
	icon_size = 256,
	icon_mipmaps = 2,
	order = "099",
	prerequisites = {"ir-quantum-mining"},
	effects = {
		{type = "unlock-recipe", recipe = "elixir-stone"},
		{type = "unlock-recipe", recipe = "gold-from-stone"},
	},
	unit = data.raw.technology["ir-quantum-mining"].unit,
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
	type = "item",
	name = "elixir-stone",
	icon = "__Desolation__/graphics/elixir-stone.png",
	icon_size = 64,
	icon_mipmaps = 4,
	stack_size = 100,
	subgroup = data.raw.item["diamond-gem"].subgroup,
	order = "zzz-z-z",
}

local elixirRecipe = {
	type = "recipe",
	name = "elixir-stone",
	category = data.raw.recipe["electrum-gem-charged"].category,
	subgroup = data.raw.recipe["electrum-gem-charged"].subgroup,
	energy_required = 60,
	ingredients = {
		{type = "item", name = "spagyric-crystal", amount = 1},
		{type = "fluid", name = "immateria", amount = 100}
	},
	results = {
		{type = "item", name = "elixir-stone", amount = 1}
	},
	enabled = false,
	always_show_made_in = true,
	main_product = "elixir-stone",
}

local goldRecipe = {
	type = "recipe",
	name = "gold-from-stone",
	localised_name = {"recipe-name.gold-from-stone"},
	category = data.raw.recipe["electrum-gem-charged"].category,
	subgroup = data.raw.recipe["electrum-gem-charged"].subgroup,
	energy_required = 2,
	ingredients = {
		{type = "item", name = "elixir-stone", amount = 1},
		{type = "item", name = "stone", amount = 10}
	},
	results = {
		{type = "item", name = "gold-ore", amount = 10},
		{type = "item", name = "elixir-stone", amount = 1},
	},
	enabled = false,
	always_show_made_in = true,
	main_product = "gold-ore",
	icons = {
		{ icon = "__Desolation__/graphics/empty_icon.png", icon_size = 64, icon_mipmaps = 4, scale = 0.5 },
		{ icon = data.raw.item["gold-ore"].icon, icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {7, 7} },
		{ icon = "__Desolation__/graphics/elixir-stone.png", icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {0, -7} },
		{ icon = data.raw.item["stone"].icon, icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {-7, 7} },
	},
}

data:extend({immateriaFluid, elixirStoneTech, spagyricCrystalItem, elixirItem, elixirRecipe, goldRecipe})