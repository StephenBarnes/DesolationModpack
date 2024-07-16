-- See the other file, control/transfer-plate-unlocks-tech.lua.
-- This file is to modify the logistics tech so that you can't obtain it with normal research.
-- We want to create an unobtainable item to use as the science pack, similar to how the IR3 Inspiration mod does it.

data:extend({
	{
		type = "tool",
		name = "Desolation-transfer-plate-unlocks-tech",
		icons = {
			{
				icon = "__IndustrialRevolution3Inspiration__/graphics/icons/64/inspiration.png",
				icon_size = 64,
				icon_mipmaps = 4,
				scale = 0.5,
				shift = {0, 0},
			},
			{
				icon = "__IndustrialRevolution3Assets1__/graphics/icons/64/transfer-plate-2x2.png",
				icon_size = 64,
				icon_mipmaps = 4,
				scale = 0.25,
				shift = {-7, -7},
			},
		},
		subgroup = "other",
		order = "a",
		stack_size = 1,
		durability = 1,
	},
})
data.raw.technology.logistics.unit = {
	ingredients = {
		{"Desolation-transfer-plate-unlocks-tech", 1},
	},
	time = 1,
	count = 1,
}

-- So now we also need to move the recipe for transfer plates to tin 2, and remove it from logistics tech.
local Tech = require("code.util.tech")
Tech.removeRecipeFromTech("transfer-plate-2x2", "logistics")
Tech.removeRecipeFromTech("transfer-plate", "logistics") -- This is the 3x3 transfer plate.
Tech.addRecipeToTech("transfer-plate-2x2", "ir-basic-research")
Tech.addRecipeToTech("transfer-plate", "ir-basic-research")