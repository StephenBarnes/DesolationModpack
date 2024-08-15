-- This file adds new technologies to extend the endgame a bit.
-- Specifically, we want to:
-- * Add a new "magnum opus" technology that unlocks the recipe to produce the elixir stone, and transmutation recipes.
-- * Add a new "cosmic reckoning" technology, requiring space science, which simply unlocks the final tech.
-- * Add a new "long-range transmaterialisation" technology, researched using elixir stone and space science. When researched, you win the game.

local elixirStoneTech = {
	type = "technology",
	name = "magnum-opus",
	icon = "__Desolation__/graphics/immateria-with-outline-256-128.png",
	icon_size = 256,
	icon_mipmaps = 2,
	order = "099",
	prerequisites = {"ir-arc-furnace-2", "ir-quantum-mining"},
	effects = {
		{type = "unlock-recipe", recipe = "elixir-stone"},
		{type = "unlock-recipe", recipe = "gold-from-lead"},
		{type = "unlock-recipe", recipe = "copper-from-platinum"},
		{type = "unlock-recipe", recipe = "iron-from-nickel"},
		{type = "unlock-recipe", recipe = "tin-from-chromium"},
	},
	unit = data.raw.technology["ir-quantum-mining"].unit,
}

-- TODO add the other two techs

data:extend({elixirStoneTech})