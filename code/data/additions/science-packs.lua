-- This file creates new recipes for the science packs, etc.
-- This is separate from tech.lua, because I want this to run before data-final-fixes, so we get scrapping and containerization recipes.

local Tech = require("code.util.tech")

-- Table of IDs so I can write rules more intuitively.
local id = {
	mechanicsKit = "automation-science-pack", -- red
	electronicsKit = "logistic-science-pack", -- green
	fluidicsKit = "chemical-science-pack", -- blue
	chemistryKit = "utility-science-pack", -- yellow
	hermeticsKit = "production-science-pack", -- purple
	cosmologyKit = "space-science-pack", -- white
	ballisticsKit = "military-science-pack", -- black
}

-- Register a new "glass bottle" item and recipe.
-- Icon taken from: https://mods.factorio.com/mod/science-bottles
local addGlassBottle = false -- Temporarily disabling bc science pack rework hasn't been done yet, maybe never.
if addGlassBottle then
	data:extend({
		{
			type = "item",
			name = "glass-bottle",-- Glass bottle recipe unlocked by tech glass working (ir-glass-milestone).,
			stack_size = 50,
			icon = "__Desolation__/graphics/bottle.png",
			icon_size = 64,
			icon_mipmaps = 4,
			subgroup = "analysis",
			order = "a",
		},
		{
			type = "recipe",
			name = "glass-bottle",
			icon = "__Desolation__/graphics/bottle.png",
			icon_size = 64,
			icon_mipmaps = 4,
			subgroup = "analysis",
			order = "a",
			category = "crafting",
			enabled = false,
			ingredients = {
				{"glass", 1},
			},
			result = "glass-bottle",
			result_count = 1,
			energy_required = 1.0,
		},
	})

	Tech.addRecipeToTech("glass-bottle", "ir-glass-milestone")
end
-- Molten glass doesn't exist, so no need for recipes for casting it into bottles.