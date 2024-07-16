local Tech = require("code.util.tech")
local Recipe = require("code.util.recipe")


-- Tweaks to the base IR3 inserters and belts, because we have these loaders etc
------------------------------------------------------------------------

-- Remove inserter throughput techs. Rather push the player to use loaders etc.
Tech.hideTech("inserter-capacity-bonus-1")
Tech.hideTech("inserter-capacity-bonus-2")
Tech.hideTech("inserter-capacity-bonus-3")
Tech.hideTech("ir-normal-inserter-capacity-bonus-1")
Tech.hideTech("ir-normal-inserter-capacity-bonus-2")

-- I'm going to change fast inserters to require red circuits, and stack inserters to require blue circuits, since logistics is generally harder and I want to encourage using the loaders.
-- IR3 has steel motor => fast inserter => stack inserter and automation 3. But there's no conflicts making it depend on red circuits, plus it matches the prereqs of the iron tier.
Tech.setPrereqs("ir-inserters-2", {"electric-engine", "ir-electronics-2"})
Recipe.substituteIngredient("fast-inserter", "electronic-circuit", "advanced-circuit")
Recipe.substituteIngredient("filter-inserter", "electronic-circuit", "advanced-circuit")
-- IR3 has electroplating (and inserters-2) leading to inserters-3 (stack inserter). I'll change it to blue circuits (ir-electronics-3).
Tech.setPrereqs("ir-inserters-3", {"ir-electronics-3"})
Recipe.substituteIngredient("stack-inserter", "advanced-circuit", "processing-unit")
Recipe.substituteIngredient("stack-filter-inserter", "advanced-circuit", "processing-unit")

-- Since logistics-2 now has lubricant as prereq, let's add some of it to the recipes, same as vanilla has for blue belts.
data.raw.recipe["fast-transport-belt"].category = data.raw.recipe["express-transport-belt"].category -- Needed to have a fluid ingredient
Recipe.addIngredients("fast-transport-belt", {{type="fluid", name="lubricant", amount=5}})

-- For IR3 Loaders and Stacking mod
------------------------------------------------------------------------
-- We want to use both the loaders and the bundlers (stacking beltboxes) from this mod. Using HarderBasicLogistics to restrict these loaders to only bundlers/packers.
-- I don't want IR3 bundlers/loaders to have separate techs, rather just put them in a corresponding logistics tech or motor tech.
-- I also want to remove the circuit requirement for beltboxes and loaders. Keep them for inserters, which seem like they need more actual intelligence. I want beltboxes to be cheap, since they're limited to just ingots, and we want to encourage using beltboxes.

Tech.hideTech("ir3-beltbox-steam")
Tech.hideTech("ir3-loader-steam")
Tech.addRecipeToTech("ir3-beltbox-steam", "logistics")
Tech.addRecipeToTech("ir3-loader-steam", "logistics")

Tech.hideTech("ir3-beltbox")
Tech.hideTech("ir3-loader")
Tech.addRecipeToTech("ir3-beltbox", "ir-iron-motor")
Tech.addRecipeToTech("ir3-loader", "ir-iron-motor")
Recipe.removeIngredient("ir3-beltbox", "electronic-circuit")
Recipe.removeIngredient("ir3-loader", "electronic-circuit")

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

-- Change the icons for IR3 loaders, to distinguish from AAI loaders.
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
	local sharedDescription = {
		"shared-description.ir3-beltbox-ALL",
		{"belt-tier-name.tier-"..beltTier},
	}
	data.raw.item["ir3-"..name].localised_description = sharedDescription
	data.raw.furnace["ir3-"..name].localised_description = sharedDescription -- The entities are registered as furnaces.
end
for name, beltTier in pairs({["loader-steam"] = 1, ["loader"] = 1, ["fast-loader"] = 2, ["express-loader"] = 3}) do
	local sharedDescription = {
		"shared-description.ir3-loader-ALL",
		{"belt-tier-name.tier-"..beltTier},
	}
	data.raw.item["ir3-"..name].localised_description = sharedDescription
	data.raw["loader-1x1"]["ir3-"..name].localised_description = sharedDescription
end

-- For AAI Loaders
------------------------------------------------------------------------

-- For this mod, we have 3 loaders. All 3 require lubricant.
-- Where should they go in the tech tree? After lubricant obviously, but other than that they could go anywhere.
-- Don't pay attention to their ingredients, since we can easily change those.
-- Ok, so, here's my idea: you get logistics 1, then lubricant, then logistics 2 (red belts), then logistics 3 (blue belts).
-- (This requires making logistics 2 depend on lubricant, which is actually fine, you just don't get red belts until a bit later. Again, IR3 changes progression so things like cars don't depend on logistics 2.)
-- Then just attach the loaders respectively to lubricant, logistics 2, logistics 3.
-- And change their recipes to use the corresponding belt, plus other components guaranteed discovered by that point.

Tech.addRecipeToTech("aai-loader", "lubricant")
Tech.hideTech("aai-loader")

Tech.addRecipeToTech("aai-fast-loader", "logistics-2")
Tech.hideTech("aai-fast-loader")

Tech.addRecipeToTech("aai-express-loader", "logistics-3")
Tech.hideTech("aai-express-loader")

Tech.setPrereqs("logistics-2", {"lubricant"}) -- This adds lubricant as prereq, and also removes automation-2 and circuits-1 as prereqs (which is good, because they're already needed for lubricant).
Tech.copyCosts("lubricant", "logistics-2") -- We don't want logistics 2 (after lubricant) to cost much less than lubricant.

-- Set ingredients
-- For first loader, the only tech we have is the beltbox tech plus lubricant, and some irrelevant stuff (concrete, oil). So just copy the recipe from beltbox to loader.
-- It's fairly realistic too. Add one more belt too, for realism and a bit of extra expense.
-- From looking it over, the same rule can be applied to the other 2 loaders.
Recipe.copyIngredients("ir3-loader", "aai-loader")
Recipe.copyIngredients("ir3-fast-loader", "aai-fast-loader")
Recipe.copyIngredients("ir3-express-loader", "aai-express-loader")

-- Use the icons from Deadlock's loaders mod, for the AAI loaders, so that they have black belts and look the same as the others.
-- The actual placed entity doesn't look quite like the Deadlock icons, but it's fairly close and at least this way the icons won't have grey belts that stick out.
for i, val in pairs({"loader", "fast-loader", "express-loader"}) do
	data.raw.item["aai-"..val].icons = {
		{
			icon = "__IndustrialRevolution3LoadersStacking__/graphics/icons/64/ir3-"..val..".png",
			icon_size = 64,
			icon_mipmaps = 4
		},
		{
			icon = "__IndustrialRevolution3Assets1__/graphics/icons/64/lubricant.png",
			icon_size = 64,
			icon_mipmaps = 4,
			scale = 0.25,
			shift = {-7, 10},
		},
	}
	local sharedDescription = {
		"shared-description.ir3-loader-ALL",
		{"belt-tier-name.tier-"..i},
	}
	data.raw.item["aai-"..val].localised_description = sharedDescription
	data.raw["loader-1x1"]["aai-"..val].localised_description = sharedDescription
end


-- For Intermodal Containers
------------------------------------------------------------------------

-- I want them to use iron, not steel, bc they're unlocked with robotics 1.
-- We could make them require steel, it's just a bit later than iron.
-- But I want to make rail right after iron, and rail goes nicely with containerization, so no, rather use iron.

-- For the ingredients of the container:
-- The box has 12 edges and 5 faces (excluding top), and we want to use IR3's intermediates. So maybe 5x plates, 12x rod, 4x rivet.
-- I want them to be somewhat expensive, with expensive losses from disassembly recipe too. Otherwise you just disassemble them to multiple products, then scrap all of those and re-smelt to get back ingots.
-- To make them somewhat expensive, let's make them use reinforced iron plates.
-- If it's 5 plate + 12 rod + 4 rivets, that's 13 ingots each. Machines for 1/sec are 1 big assembler, 24 small assemblers (mostly for rods).
-- If it's 5 reinforced plate + 5 rivets, that's 15 ingots each. Machines for 1/sec are 16 big assemblers, 32 small assemblers.
--   In that case, we use 5 rivets for container, and 5 rivets for reinforced plates (1 rivet per reinf plate).
--   I like this, since we could return the rivets and plates to the player.
--   Each reinforced plate is 1 rivet + 2 plates. So if a container is 5 reinf plates + 5 rivets, disassembly could yield 8-10 plates and 6-10 rivets.
--   So expected loss is 1 plate and 2 rivets, which comes to 2 ingots per disassembly.
--   I'm probably going to give train wagons like 10 storage slots, stack size for ore is 20, and it's like 5 containers per stack each holding half the original item's stack size. So per train trip, that's 10*5 = 50 containers. Disassembly of one train-wagon-load is then a loss of 100 iron ingots.
-- Hm, TODO balance all this better with some actual playtesting, after deciding on stack sizes etc.

Recipe.setIngredients("ic-container", { -- Ingredients chosen bc the box has 12 edges and 5 faces (excluding top), and we want to use IR3's intermediates.
	--{"iron-plate", 5},
	--{"iron-stick", 12},
	--{"iron-rivet", 4}
	{"iron-plate-heavy", 5},
	{"iron-rivet", 5},
})

data:extend({
	-- Add a subgroup for containers and containerization machines.
	{
		type = "item-subgroup",
		name = "containerization",
		group = "logistics",
		order = "bc", -- After beltboxes row, but before inserter row.
	},
	-- Add a recipe to disassemble containers at destination.
	{
		type = "recipe",
		name = "ic-container-disassembly",
		category = data.raw.recipe["ic-container"].category,
		subgroup = "containerization",
		order = "2-2",
		ingredients = {
			{ "ic-container", 1 },
		},
		-- Note that we get scrap when creating the container, so we can't get back all of the raw materials.
		-- Scrap is 0.55 scrap, though user could set it to like 1.1 or so.
		-- I think the best solution is to cap the scrap produced by the container recipe, to at most the expected loss when disassembling, which I'm setting at (chance of losing a rivet) * (ingots per rivet) = 0.5 * 0.5 = 0.25. Set it to 0.15 to be safe.
		results = {
			{ name = "iron-plate", amount_min = 8, amount_max = 10 },
			{ name = "iron-rivet", amount_min = 6, amount_max = 10 },
		},
		main_product = "iron-plate",
		localised_name = { "recipe-name.ic-container-disassembly" },
		allow_as_intermediate = false,
		allow_intermediates = false, -- So it doesn't try something stupid like making and then disassembling a container.
		allow_decomposition = false, -- Don't break down to "raw ingredients".
		enabled = false,      -- Not enabled before researched.
		icons = {
			-- Empty icon as background layer, because the sub-icons are sized relative to back layer.
			{
				icon = "__Desolation__/graphics/empty_icon.png",
				icon_size = 64,
				icon_mipmaps = 4,
				scale = 0.5
			},
			{ icon = data.raw.item["ic-container"].icon, icon_size = 64, icon_mipmaps = 4, scale = 0.4,  shift = { 0, -4 } },
			{ icon = data.raw.item["iron-plate"].icon,   icon_size = 64, icon_mipmaps = 4, scale = 0.35, shift = { -7, 7 } },
			{ icon = data.raw.item["iron-rivet"].icon,   icon_size = 64, icon_mipmaps = 4, scale = 0.35, shift = { 7, 7 } },
		},
	}
})

-- Re containerization machines / packers.
-- So, defaults are definitely unsuitable, eg the first tier of containerization machine requires only red and green science, but depends on stack inserter tech which needs red+green+blue+purple.
-- I think I want them to not require stack inserters at all, at the bottom tier. Rather make it require multiple ordinary inserters, or fast inserters.
-- I also want to do away with the separate techs for each tier, that's ugly.
-- I think we should move them into the logistics techs too, like for AAI loaders.
-- Their recipes should use the large frame of corresponding resource tier.

Tech.hideTech("ic-containerization-1")
Tech.hideTech("ic-containerization-2")
Tech.hideTech("ic-containerization-3")

Tech.addRecipeToTech("ic-container", "ir-inserters-1")
Tech.addRecipeToTech("ic-container-disassembly", "ir-inserters-1")
Tech.addRecipeToTech("ic-containerization-machine-1", "ir-inserters-1")
Tech.addRecipeToTech("ic-containerization-machine-2", "ir-inserters-2")
Tech.addRecipeToTech("ic-containerization-machine-3", "ir-inserters-3")

Recipe.setIngredients("ic-containerization-machine-1", {
	{"iron-frame-large", 1},
	{"iron-gear-wheel", 8},
	--{"electronic-circuit", 2}, -- No, large frame already has circuits.
	{"iron-motor", 2}, -- the red (iron) motor
	{"iron-beam", 2},
})
Recipe.setIngredients("ic-containerization-machine-2", {
	{"steel-frame-large", 1},
	{"steel-gear-wheel", 8},
	--{"advanced-circuit", 2}, -- red circuit
	{"electric-engine-unit", 2}, -- the "advanced motor" ie blue/steel motor
	{"steel-beam", 2},
})
Recipe.setIngredients("ic-containerization-machine-3", {
	{"chromium-frame-large", 1},
	{"brass-gear-wheel", 8}, -- There's no chromium gear wheel?
	--{"processing-unit", 2}, -- blue circuit
	--{"chromium-engine-unit", 2}, -- the "advanced engine" (looks like blue engine, not motor)
	{"electric-engine-unit", 2}, -- Decided to rather use this, to match the other recipes. It's a motor, not an engine.
	{"chromium-beam", 2},
})

-- Change the localised_description fields to point to the same shared description, so I don't have to repeat them in the locale file.
for i = 1, 3 do
	data.raw.item["ic-containerization-machine-"..i].localised_description = {"shared-description.ic-containerization-machine-ALL", {"belt-tier-name."..i}}
end

-- Change tabs and ordering in crafting menu.
data.raw.item["ic-container"].subgroup = "containerization"
data.raw.item["ic-containerization-machine-1"].subgroup = "containerization"
data.raw.item["ic-containerization-machine-2"].subgroup = "containerization"
data.raw.item["ic-containerization-machine-3"].subgroup = "containerization"
data.raw.item["ic-container"].order = "2-1"
data.raw.item["ic-containerization-machine-1"].order = "1-1"
data.raw.item["ic-containerization-machine-2"].order = "1-2"
data.raw.item["ic-containerization-machine-3"].order = "1-3"