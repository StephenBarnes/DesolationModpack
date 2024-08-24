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

-- TODO check that the loaders and bundlers can actually handle entire yellow/red/blue belts.
-- TODO check power usage. Should be more than inserters, since loaders are faster.
-- TODO maybe add the AAI lubricant-requiring loaders back in. Because otherwise there's no reason to use stuff like fast loaders and stack loaders, ugh. And then dig up the last commit where I still had those. And correct things like the icons, etc.

------------------------------------------------------------------------
--- Trying out using AAI loaders with IR3 loader sprites

--data.raw["loader-1x1"]["aai-loader"].belt_animation_set = data.raw["loader-1x1"]["ir3-loader"].belt_animation_set -- TODO check if necessary?
--data.raw["loader-1x1"]["aai-loader"].structure = data.raw["loader-1x1"]["ir3-loader"].structure
-- So, this works, BUT the pipe isn't right, it's using vanilla pipe instead of IR3's pipe. Could probably fix that too.

------------------------------------------------------------------------
--- Trying just modifying the other IR3 loaders to use lubricant

-- Set lubricant to have a fuel value, so loaders can use it as fuel.
data.raw.fluid.lubricant.fuel_value = "100KJ"
-- Note this allows the petrochem generator to accept lubricant. Can't see any way to prevent petrochem generator from burning a specific fluid.
-- I think that's actually fine, since lubricant is flammable (according to some quick research).
-- For comparison, petroleum and ethanol are 400kJ per fluid unit. Petroleum cost in raw materials is similar to cost of lubricant, per fluid unit.

local function setLoaderToConsumeLubricant(loaderName, lubricantPerItem)
	local originalEnergySource = data.raw["loader-1x1"][loaderName].energy_source
	if originalEnergySource == nil then
		log("ERROR: Couldn't find original energy source for loader "..loaderName)
		return
	end
	data.raw["loader-1x1"][loaderName].energy_source = table.deepcopy(data.raw["loader-1x1"]["ir3-loader-steam"].energy_source)
	data.raw["loader-1x1"][loaderName].energy_source.smoke = originalEnergySource.smoke
	data.raw["loader-1x1"][loaderName].energy_source.emissions_per_minute = originalEnergySource.emissions_per_minute
	data.raw["loader-1x1"][loaderName].energy_source.fluid_box.filter = "lubricant"
	---@diagnostic disable-next-line: undefined-global
	data.raw["loader-1x1"][loaderName].energy_source.fluid_box.pipe_covers = DIR.pipe_covers.iron -- DIR defined in IR3.
	data.raw["loader-1x1"][loaderName].energy_per_item = (lubricantPerItem * 100) .. "KJ"

	-- IR3 steam loader has base area 0.5, so it can hold 100 steam. Lubricant-consuming loaders consume much less fluid than steam loaders, so reduce amount stored to 10.
	data.raw["loader-1x1"][loaderName].energy_source.fluid_box.base_area = 0.05

	-- For steam loader, speed depends on steam temperature. For lubricant, we want it to instead calculate based on the fluid's fuel value, not temperature.
	data.raw["loader-1x1"][loaderName].energy_source.burns_fluid = true

	-- TODO more things to do here? Change icon or something?
end

-- AAI loaders consume 0.1 or 0.15 or 0.2 lubricant per minute. That's 0.00333 to 0.001667 per second, or 0.000111 to 0.0000370370 per item.
-- So for these loaders, maybe consume like 0.0002 per item, for all items.
setLoaderToConsumeLubricant("ir3-loader", 0.0002)
setLoaderToConsumeLubricant("ir3-fast-loader", 0.0002)
setLoaderToConsumeLubricant("ir3-express-loader", 0.0002)

-- TODO idea: we could make other machines consume lubricant too. Eg beltboxes, what else?

-- TODO update the descriptions of these loaders to note that they consume lubricant.

-- TODO update description of lubricant, eg note that you can technically burn it in petrochem generator.

-- TODO make the steam loader maybe half as fast, like 7.5/sec instead of 10/sec. So the first lubricant-consuming loader is an upgrade.