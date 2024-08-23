-- This file tweaks the loaders and bundlers added by IR3 loaders and stacking mod.

local Tech = require("code.util.tech")
local Recipe = require("code.util.recipe")

-- Change fast inserters to require red circuits, and stack inserters to require blue circuits, since logistics is generally harder and I want to encourage using the loaders.
-- IR3 has steel motor => fast inserter => stack inserter and automation 3. But there's no conflicts making it depend on red circuits, plus it matches the prereqs of the iron tier.
Tech.setPrereqs("ir-inserters-2", {"electric-engine", "ir-electronics-2"})
Recipe.substituteIngredient("fast-inserter", "electronic-circuit", "advanced-circuit")
Recipe.substituteIngredient("filter-inserter", "electronic-circuit", "advanced-circuit")
-- IR3 has electroplating (and inserters-2) leading to inserters-3 (stack inserter). I'll change it to blue circuits (ir-electronics-3).
Tech.setPrereqs("ir-inserters-3", {"ir-electronics-3"})
Recipe.substituteIngredient("stack-inserter", "advanced-circuit", "processing-unit")
Recipe.substituteIngredient("stack-filter-inserter", "advanced-circuit", "processing-unit")

Tech.addTechDependency("ir-iron-motor", "logistics-2")

-- I don't want IR3 bundlers/loaders to have separate techs, rather just put them in a corresponding logistics tech or motor tech.
-- I also want to remove the circuit requirement for beltboxes and loaders. Keep them for inserters, which seem like they need more actual intelligence. I want beltboxes to be cheap, since they're limited to just ingots, and we want to encourage using beltboxes.

Tech.hideTech("ir3-beltbox-steam")
Tech.hideTech("ir3-loader-steam")
Tech.addRecipeToTech("ir3-beltbox-steam", "logistics")
Tech.addRecipeToTech("ir3-loader-steam", "logistics")

Tech.hideTech("ir3-beltbox")
Tech.hideTech("ir3-loader")
Tech.addRecipeToTech("ir3-beltbox", "ir-steam-power") -- electricity tech
Tech.addRecipeToTech("ir3-loader", "ir-steam-power") -- electricity tech
Recipe.removeIngredient("ir3-beltbox", "electronic-circuit")
Recipe.removeIngredient("ir3-loader", "electronic-circuit")
Recipe.setIngredients("ir3-beltbox", {
	{"iron-frame-small", 1},
	{"iron-piston", 2},
	{"iron-gear-wheel", 4},
})

Tech.hideTech("ir3-fast-beltbox")
Tech.hideTech("ir3-fast-loader")
Tech.addRecipeToTech("ir3-fast-beltbox", "logistics-2")
Tech.addRecipeToTech("ir3-fast-loader", "logistics-2")
Recipe.removeIngredient("ir3-fast-beltbox", "electronic-circuit")
Recipe.removeIngredient("ir3-fast-loader", "electronic-circuit")

Tech.hideTech("ir3-express-beltbox")
Tech.hideTech("ir3-express-loader")
Tech.addRecipeToTech("ir3-express-beltbox", "logistics-3")
Tech.addRecipeToTech("ir3-express-loader", "logistics-3")
Recipe.removeIngredient("ir3-express-beltbox", "advanced-circuit")
Recipe.removeIngredient("ir3-express-loader", "advanced-circuit")

-- Move the bundlers to the next row, so we don't have an overlong row.
local function setSubgroupOrder(itemName, subgroup, order)
	data.raw.item[itemName].subgroup = subgroup
	data.raw.item[itemName].order = order
end
for i, val in pairs({"beltbox-steam", "beltbox", "fast-beltbox", "express-beltbox"}) do
	setSubgroupOrder("ir3-"..val, "containerization", "0"..i)
end

-- Change the icon for IR3 steam loader. (Originally to distinguish from AAI loaders which were also in, but I've since removed them; keeping this though.)
data.raw.item["ir3-loader-steam"].icons = {
	data.raw.item["ir3-loader-steam"].icons[1] or data.raw.item["ir3-loader-steam"].icon,
	{
		icon = "__IndustrialRevolution3Assets1__/graphics/icons/64/steam.png",
		icon_size = 64,
		icon_mipmaps = 4,
		scale = 0.25,
		shift = {-7, 10},
	},
}
-- Could add electric lines to the unlubricated loaders, but I think it looks better without them.
--if false then
--	for _, val in pairs({"loader", "fast-loader", "express-loader"}) do
--		data.raw.item["ir3-"..val].icons = {
--			data.raw.item["ir3-"..val].icons[1] or data.raw.item["ir3-"..val].icon,
--			{
--				icon = "__IndustrialRevolution3Assets1__/graphics/icons/64/heating-overlay-electric.png",
--				icon_size = 64,
--				icon_mipmaps = 4,
--				scale = 0.25,
--				shift = {-7, 10},
--			},
--		}
--	end
--end

-- Change the icon for IR3's steam bundler, to match the steam loader.
data.raw.item["ir3-beltbox-steam"].icons = {
	data.raw.item["ir3-beltbox-steam"].icons[1] or data.raw.item["ir3-beltbox-steam"].icon,
	{
		icon = "__IndustrialRevolution3Assets1__/graphics/icons/64/steam.png",
		icon_size = 64,
		icon_mipmaps = 4,
		scale = 0.25,
		shift = {-7, 10},
	},
}

-- Change the localised_description fields to point to the same shared description, so I don't have to repeat them in the locale file.
for name, beltTier in pairs({["beltbox-steam"] = 1, ["beltbox"] = 1, ["fast-beltbox"] = 2, ["express-beltbox"] = 3}) do
	data.raw.furnace["ir3-"..name].localised_description = { -- The entities are registered as furnaces.
		"shared-description.ir3-beltbox-ALL",
		{"belt-tier-name.tier-"..beltTier},
	}
end
for name, beltTier in pairs({["loader-steam"] = 1, ["loader"] = 1, ["fast-loader"] = 2, ["express-loader"] = 3}) do
	data.raw["loader-1x1"]["ir3-"..name].localised_description = {
		"shared-description.ir3-loader-ALL",
		{"belt-tier-name.tier-"..beltTier},
	}
end