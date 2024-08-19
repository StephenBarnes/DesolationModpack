-- This file removes solar panels and related techs etc., because they are less interesting than shipping around fuel and batteries etc.
-- We also need to adjust the recipe for the solar assembly (for satellites), bc it had solar panels as ingredients.

local Tech = require("code.util.tech")
local Recipe = require("code.util.recipe")

--[[ Originally:
* solar assembly is 3 accumulator + 16 chromium-plate-heavy + 8 solar-array
* solar array is 4 solar-panel + 1 junction-box + 1 revolutionary computer
* solar panel is 1 red circuit + 9 glass + 9 silicon + 18 steel-plate.

So in total, each solar array is 1 junction-box + 1 revolutionary computer + 4 advanced-circuit + 36 glass + 36 silicon + 72 steel-plate.
So in total, each solar assembly is 3 accumulator + 16 chromium-plate-heavy + 8 junction-box + 8 revolutionary computer + 32 advanced-circuit + 288 glass + 288 silicon + 576 steel-plate.
Hm, I don't want to make it an 8-ingredient recipe. Could add some substations or something, maybe.

Probably best to just preserve the total cost of the solar assembly, by making it cost the same ingredients but instead of 8 solar-arrays it's maybe 32 solar "subassemblies", each costing 1/4 the price of a solar array.
So, make solar assembly = 3 accumulator + 16 chromium-plate-heavy + 8 junction-box + 32 solar subassembly.
And then solar subassembly = some blue circuits + 9 glass + 9 silicon + 18 steel plate.

Hm, I don't want to use computers as ingredients. So rather just the blue circuits.
To replace the red circuits, we change the steel plates to chromed plates in the solar subassembly recipe, and halve the amount.
But I think rather don't do that, just remove the red circuits.
]]

Tech.hideTech("ir-solar-energy-1")
Tech.hideTech("ir-solar-energy-2")
Tech.hideTech("solar-panel-equipment")
Tech.removePrereq("space-science-pack", "ir-solar-energy-2")

Recipe.setIngredients("solar-assembly", {
	{"accumulator", 3},
	{"chromium-plate-heavy", 16},
	{"solar-subassembly", 32},
	{"junction-box", 8},
})

-- Create the new "solar subassembly" item, and recipe.
data:extend({
	{
		type = "item",
		name = "solar-subassembly",
		--icons = data.raw.item["solar-array"].icons,
		icon = data.raw.item["solar-panel"].icon,
		icon_size = data.raw.item["solar-panel"].icon_size,
		icon_mipmaps = data.raw.item["solar-panel"].icon_mipmaps,
		subgroup = "ir-intermediates",
		order = "zb2",
		stack_size = 60,
	},
	{
		type = "recipe",
		name = "solar-subassembly",
		order = "zb2",
		category = "crafting",
		enabled = false,
		ingredients = {
			{"processing-unit", 2},
			{"glass", 9},
			{"silicon", 9},
			{"steel-plate", 18},
		},
		result = "solar-subassembly",
		result_count = 1,
		energy_required = 3,
	},
})

Tech.addRecipeToTech("solar-subassembly", "space-science-pack")