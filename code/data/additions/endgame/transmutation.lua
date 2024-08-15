-- This file adds new transmutation recipes, to make the elixir stone more useful and to fit with the alchemy theme.

-- I don't want to make it just stone => gold, bc that removes the challenge of finding gold.
-- So, maybe make it produce or consume multiple ingredients. Or add alternatives to convert primary minerals to secondary, or something.

-- Could make all of them convert a secondary mineral to a primary mineral, following the lead-to-gold example. Maybe cyclic around the 4 main minerals.
-- Those 4 main mineral pairs are: tin/lead, gold/platinum, iron/chromium, copper/nickel.
-- Could name lead-to-gold "chrysopoeia", and then use 3 of the 4 magnum opus names for the other 3 recipes.
-- Maybe make this turn the pure secondary mineral into the crushed ore, which can then be purified again.
-- Make these recipes cyclic, to allow a sort of "amplification" of mined ores. But not infinite generation.

-- Note ore washers allow 2x modules. If it has 2x prod 3 modules, it has 20% bonus.
-- The recipes currently are:
-- * cold (washing 1): 1 crushed ore => 1 pure primary + 10% of 1 pure secondary.
-- * hot (washing 2): 1 crushed ore => 1 pure primary + 50% of 1 pure secondary.
-- So, with 2x prod 3 mods, this is 1 crushed ore => 1.2 pure primary + 0.6 pure secondary.
-- So, we could make the transmutations go 1 pure secondary => 1.5 crushed ore.

-- The transmutations could be:
-- lead=>gold (chrysopoeia, white to yellow)
-- plat=>copper (purple to orange)
-- nickel=>iron (green to cyan)
-- chromium=>tin (red to blue)

local function makeTransmutation(a, b)
	return {
		type = "recipe",
		name = b.."-from-"..a,
		localised_name = {"recipe-name."..b.."-from-"..a},
		--category = data.raw.recipe["electrum-gem-charged"].category,
		category = "crafting", -- so it's hand-craftable
		subgroup = data.raw.recipe["electrum-gem-charged"].subgroup,
		order = "zzz-z-z2",
		energy_required = 5,
		ingredients = {
			{type = "item", name = "elixir-stone", amount = 1},
			{type = "item", name = a.."-pure", amount = 1}
		},
		results = {
			{type = "item", name = b.."-crushed", amount_min = 1, amount_max = 2},
			{type = "item", name = "elixir-stone", amount = 1},
		},
		enabled = false,
		--always_show_made_in = true,
		main_product = b.."-crushed",
		allow_as_intermediate = false,
		allow_decomposition = false,
		icons = {
			{ icon = "__Desolation__/graphics/empty_icon.png", icon_size = 64, icon_mipmaps = 4, scale = 0.5 },
			{ icon = data.raw.item[b.."-crushed"].icon, icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {7, 7} },
			{ icon = "__Desolation__/graphics/elixir-stone.png", icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {0, -7} },
			{ icon = data.raw.item[a.."-pure"].icon, icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {-7, 7} },
		},
	}
end

data:extend({
	makeTransmutation("lead", "gold"),
	makeTransmutation("platinum", "copper"),
	makeTransmutation("nickel", "iron"),
	makeTransmutation("chromium", "tin"),
})