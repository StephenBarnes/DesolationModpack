-- Tweaks for Intermodal Containers recipes and techs.

local Recipe = require("code.util.recipe")
local Tech = require("code.util.tech")

--[[
I want them to use iron, not steel, bc they're unlocked with robotics 1, and they should be available soon after basic rail.

For the ingredients of the container:
The box has 12 edges and 5 faces.
To make them somewhat expensive, and to make disassembly recipe produce more products, I'll make them require a reinforced plate for each face.
Container is made from 5 reinforced plate + 5 rivets. Each reinforced plate is 2 plates and 1 rivet.
	So each container is 10 plates + 10 rivets, which is 15 ingots.
Container disassembly gives plates, rivets, and scrap.
	Making it 8-10 plates, and 8-10 rivets, and 0-3 scrap. This totals 9 + 4.5 + 1.5 = 15 ingots.
	So, disassembly has no net cost in iron.
You could also scrap the container directly, or disassemble and then scrap. But this loses some material.
Comparing scrapping vs disassembly, scrapping loses material, but disassembly forces you to re-use the resulting iron.
]]


Recipe.setIngredients("ic-container", { -- Ingredients chosen bc the box has 12 edges and 5 faces (excluding top), and we want to use IR3's intermediates.
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
		-- The file adjust-scrap.lua removes scrap from the recipe to create containers. Otherwise it would be possible to gain iron by making and disassembling containers.
		results = {
			{ name = "iron-plate", amount_min = 8, amount_max = 10 }, -- Averages to 9 plates = 9 ingots.
			{ name = "iron-rivet", amount_min = 8, amount_max = 10 }, -- Averages to 9 rivets = 4.5 ingots.
			{ name = "iron-scrap", amount_min = 0, amount_max = 3 }, -- Averages to 1.5 scrap = 1.5 ingots.
			-- So total is 9 + 4.5 + 1.5 = 15 ingots from disassembly.
		},
		main_product = "iron-plate",
		localised_name = { "recipe-name.ic-container-disassembly" },
		allow_as_intermediate = false,
		allow_intermediates = false, -- So it doesn't try to make other items by disassembling containers.
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
	data.raw["assembling-machine"]["ic-containerization-machine-"..i].localised_description = {
		"shared-description.ic-containerization-machine-ALL", {"belt-tier-name.tier-"..i}}
end

-- Change tabs and ordering in crafting menu.
data.raw.item["ic-container"].subgroup = "containerization"
data.raw.item["ic-container"].order = "2-1"
for i = 1, 3 do
	data.raw.item["ic-containerization-machine-"..i].order = "1-"..i
	data.raw.item["ic-containerization-machine-"..i].subgroup = "containerization"
end

-- Improve icons for the robotics techs.
for i = 1, 3 do
	local containerTech = data.raw.technology["ic-containerization-"..i]
	local inserterTech = data.raw.technology["ir-inserters-"..i]
	-- TODO rather make a general function to put together icons like this, that abstracts away .icon vs .icons, and .icons[i].icon_size vs .icon_size, etc.
	-- TODO Re-use with container disassembly recipe.
	data.raw.technology["ir-inserters-"..i].icons = {
		{
			icon = "__Desolation__/graphics/empty_icon.png",
			icon_size = 64,
			icon_mipmaps = 4,
			scale = 1.0,
		},
		{
			icon = containerTech.icons[1].icon,
			icon_size = containerTech.icon_size,
			icon_mipmaps = containerTech.icon_mipmaps,
			scale = 0.4,
			shift = {-4, -9},
		},
		{
			icon = containerTech.icons[2].icon,
			icon_size = containerTech.icon_size,
			icon_mipmaps = containerTech.icon_mipmaps,
			tint = containerTech.icons[2].tint,
			scale = 0.4,
			shift = {-4, -9},
		},
		{
			icon = inserterTech.icon,
			icon_size = inserterTech.icon_size,
			icon_mipmaps = inserterTech.icon_mipmaps,
			scale = 0.15,
			shift = {6, 15},
		},
	}
	data.raw.technology["ir-inserters-"..i].icon = nil
end