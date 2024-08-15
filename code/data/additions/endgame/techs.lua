-- This file adds new technologies to extend the endgame a bit.
-- Specifically, we want to:
-- * Add a new "magnum opus" technology that unlocks the recipe to produce the elixir stone, and transmutation recipes.
-- * Add a new "cosmic reckoning" technology, requiring space science, which simply unlocks the final tech.
-- * Add a new "long-range transmaterialisation" technology, researched using elixir stone and space science. When researched, you win the game.

local elixirStoneTech = {
	type = "technology",
	name = "magnum-opus",
	icon = "__Desolation__/graphics/elixir-tech.png",
	icon_size = 256,
	icon_mipmaps = 2,
	order = "099",
	prerequisites = {"ir-arc-furnace", "ir-quantum-mining"},
	effects = {
		{type = "unlock-recipe", recipe = "elixir-stone"},
		{type = "unlock-recipe", recipe = "gold-from-lead"},
		{type = "unlock-recipe", recipe = "copper-from-platinum"},
		{type = "unlock-recipe", recipe = "iron-from-nickel"},
		{type = "unlock-recipe", recipe = "tin-from-chromium"},
	},
	unit = data.raw.technology["ir-quantum-mining"].unit, -- TODO
}

local cosmicReckoningTech = {
	type = "technology",
	name = "cosmic-reckoning",
	icon = "__Desolation__/graphics/immateria-with-outline-256-128.png", -- TODO find an image for this.
	icon_size = 256,
	icon_mipmaps = 2,
	order = "100",
	prerequisites = {"space-science-pack"},
	effects = {},
	unit = data.raw.technology["ir-quantum-mining"].unit, -- TODO
}

local finalTechUnit = table.deepcopy(data.raw.technology["ir-quantum-mining"].unit)
---@diagnostic disable-next-line: need-check-nil
table.insert(finalTechUnit.ingredients, {"elixir-stone", 1})
local longRangeTransmaterialisationTech = {
	type = "technology",
	name = "long-range-transmaterialisation",
	icon = "__Desolation__/graphics/immateria-with-outline-256-128.png", -- TODO find an image for this.
	icon_size = 256,
	icon_mipmaps = 2,
	order = "100",
	prerequisites = {"cosmic-reckoning", "magnum-opus"},
	effects = {
		{
			type = "nothing",
			--recipe = "start-island-scan",
			effect_description = {"effect-description.win-game"},
			icon = "__Desolation__/graphics/earth-effect.png",
			icon_size = 64,
			icon_mipmaps = 2,
		}
	},
	unit = finalTechUnit,
}

data:extend({elixirStoneTech, cosmicReckoningTech, longRangeTransmaterialisationTech})