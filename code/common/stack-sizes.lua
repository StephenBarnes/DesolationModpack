-- This file defines stack sizes of various groups of items.
-- General philosophy is that items should have higher stack sizes as they get more processed, to incentivise local processing.
-- Also, we want to make it hard to move around things like buildings and vehicles.

-- Note this file doesn't filter for existing items, bc we need to use it in settings stage.
-- For example, we could have stuff like "lead-rod" here, even though they don't exist in IR3.

local G = require("code.util.general")
local T = require("code.util.table")

local metals = {"copper", "tin", "iron", "steel", "bronze", "lead", "nickel", "chromium", "gold", "platinum"}

local oreLikes = {"copper-ore", "tin-ore", "gold-ore", "uranium-ore", "iron-ore", "coal", "stone"}
local woodLikes = {"wood", "rubber-wood"}
local rawMaterials = T.concat{oreLikes, woodLikes}
local crushedMaterials = {
	"copper-crushed", "tin-crushed", "gold-crushed",
	"gravel", "silica",
	"carbon-crushed", -- This ID is used for crushed coal.
	"wood-chips",
	"ruby-powder", "diamond-powder",
}
local pureMetals = T.stringProduct(metals, {"-pure"})
local purifiedMaterials = T.concat{
	pureMetals,
	{
			"sulfur",
			"uranium-235", "uranium-238",
			"diamond", "ruby", "electrum-gem", "electrum-gem-charged", "elixir-stone",
			"silicon", "graphite", "silicon-block",
			"rubber",
			"charcoal",
			"graphitic-coke",
			"solid-fuel", -- This ID is used for coke.
	}}
local metalIngots = T.stringProduct(metals, {"-ingot"})
local standardizedIngotsBricks = T.concat{
	metalIngots,
	{
		"stone-brick", "concrete-block", "plastic-bar", "glass", "nanoglass",
		"wood-beam", -- Renamed this to "lumber".
	},
}
local metalDenseIntermediates = T.stringProduct(metals,
	{"-pellet", "-rivet", "-cable", "-foil", "-wire", "-rod", "-plate", "-beam", "-plate-heavy"})
local denseIntermediates = T.concat{
	metalDenseIntermediates,
	{},
}
local metalBulkyIntermediates = T.stringProduct(metals,
	{"-gear-wheel", "-piston"})
local bulkyIntermediates = T.concat{
	metalBulkyIntermediates,
	{},
}

-- Define stackSizeGroups, table mapping group name to: {
--    items = {a, b, c},
--    defaultStackSize = d,
-- }
-- Note these are also used in the names of settings.
local stackSizeGroups = {
	raw = {
		defaultStackSize = 40,
		items = rawMaterials,
	},
	crushed = {
		defaultStackSize = 60,
		items = crushedMaterials,
	},
	purified = {
		defaultStackSize = 80,
		items = purifiedMaterials,
	},
	standardizedIngotsBricks = {
		defaultStackSize = 100,
		items = standardizedIngotsBricks,
	},
	denseIntermediates = {
		defaultStackSize = 60,
		items = denseIntermediates,
	},
	bulkyIntermediates = {
		defaultStackSize = 40,
		items = bulkyIntermediates,
	},
}

-- Seems that IR3's bundle items are setting their stack size in data stage? Bc even with this in data.lua, the bundles still have stack size 13, from base ingots having stack size 50, it seems. But I think their stack size was higher than 50. Probably being caused by my mod, somehow.
-- Note that player can manually unbundle - feature added by IR3.
-- So we can't set the stack sizes of the bundles too high, or it'll break, bc unbundle product will be capped at 1 stack.
local bundleItems = {
	"stacked-stone-brick",
	"stacked-concrete-block",
	"stacked-plastic-bar",
	"stacked-copper-ingot", "stacked-tin-ingot", "stacked-bronze-ingot", "stacked-iron-ingot", "stacked-gold-ingot",
	"stacked-lead-ingot", "stacked-steel-ingot", "stacked-brass-ingot", "stacked-nickel-ingot", "stacked-chromium-ingot",
	"stacked-platinum-ingot",
	"stacked-glass",
}

--return {
--	stackSizeGroups = stackSizeGroups,
--}

return stackSizeGroups