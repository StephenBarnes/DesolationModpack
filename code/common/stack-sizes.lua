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
			"diamond-gem", "ruby-gem", "electrum-gem", "electrum-gem-charged", "elixir-stone",
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
		"stone-brick", "concrete-block",
		"plastic-bar",
		"glass", "nanoglass",
	},
}
local metalDenseIntermediates = T.stringProduct(metals,
	{"-pellet", "-rivet", "-cable", "-foil", "-wire", "-rod", "-plate", "-beam", "-plate-heavy"})
local denseIntermediates = T.concat{
	metalDenseIntermediates,
	{
		"wood-beam", -- Renamed this to "lumber".
		"red-wire", "green-wire",
	},
}
local metalBulkyIntermediates = T.stringProduct(metals,
	{"-gear-wheel", "-piston"})
local bulkyIntermediates = T.concat{
	metalBulkyIntermediates,
	{
		"ic-container",
		"spidertron-remote",
	}, -- TODO add things like engines and motors and rotor bases
}
local bigBuildings = {
	"ic-containerization-machine-1", "ic-containerization-machine-2", "ic-containerization-machine-3",
	"roboport",
}
local mediumBuildings = {
	"substation",
	"storage-tank",
	"chrome-transmat", "cargo-transmat",
	"airship-station",
	"robotower",
	"aai-signal-sender", "aai-signal-receiver", -- Radio towers.
}
local smallBuildings = {
	"wood-pallet", "tin-pallet", "wooden-chest", "tin-chest", "iron-chest", "steel-chest",
	"transfer-plate", "transfer-plate-2x2",
	"pit",
	"underground-belt", "fast-underground-belt", "express-underground-belt",
	"splitter", "fast-splitter", "express-splitter",
	"ir3-loader-steam", "ir3-loader", "ir3-fast-loader", "ir3-express-loader",
	"ir3-beltbox-steam", "ir3-beltbox", "ir3-fast-beltbox", "ir3-express-beltbox",
	"burner-inserter", "steam-inserter", "inserter", "slow-filter-inserter", "fast-inserter", "filter-inserter", "stack-inserter", "stack-filter-inserter",
	"small-electric-pole", "small-bronze-pole", "small-iron-pole", "medium-electric-pole", "big-wooden-pole", "big-electric-pole", -- Substation is in big buildings
	"small-steam-tank", "small-tank",
	"copper-pump", "offshore-pump", "pump",
	"train-stop",
	"rail-signal", "rail-chain-signal",
	"port", "buoy", "chain_buoy",
	"logistic-chest-active-provider", "logistic-chest-passive-provider", "logistic-chest-requester", "logistic-chest-storage", "logistic-chest-buffer",
	"arithmetic-combinator", "decider-combinator", "constant-combinator", "power-switch", "programmable-speaker",
	"deadlock-copper-lamp", "copper-aetheric-lamp-straight", "small-lamp", "deadlock-large-lamp", "deadlock-floor-lamp",
}
local tinyPlaced = {
	"transport-belt", "fast-transport-belt", "express-transport-belt",
	"copper-pipe", "copper-valve", "copper-pipe-to-ground", "copper-pipe-to-ground-short",
	"steam-pipe", "steam-valve", "steam-pipe-to-ground", "steam-pipe-to-ground-short",
	"pipe", "valve", "pipe-to-ground", "pipe-to-ground-short",
	"air-pipe", "air-valve", "air-pipe-to-ground", "air-pipe-to-ground-short",
	"rail",
}
local vehicles = {
	"meat:steam-locomotive-item", "locomotive", "cargo-wagon", "artillery-wagon",
	"boat", "cargo_ship", "ironclad",
	"monowheel", "heavy-roller", "heavy-picket",
	"car", "tank",
	"hydrogen-airship", "helium-airship",
	"spidertron",
}
local robots = {
	"steambot", "construction-robot", "logistic-robot",
	"lampbot-capsule",
}
-- TODO still need to go through all tabs of items. Already went through the first one, still need to go through the rest.

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
	tinyPlaced = {
		defaultStackSize = 100,
		items = tinyPlaced,
	},
	smallBuildings = {
		defaultStackSize = 40,
		items = smallBuildings,
	},
	mediumBuildings = {
		defaultStackSize = 20,
		items = mediumBuildings,
	},
	bigBuildings = {
		defaultStackSize = 10,
		items = bigBuildings,
	},
	robots = {
		defaultStackSize = 40,
		items = robots,
	},
	vehicles = {
		defaultStackSize = 1,
		items = vehicles,
	},
}

-- Seems that IR3's bundle items are setting their stack size in data stage? Bc even with this in data.lua, the bundles still have stack size 13, from base ingots having stack size 50, it seems. But I think their stack size was higher than 50. Probably being caused by my mod, somehow.
-- Note that player can manually unbundle - feature added by IR3.
-- So we can't set the stack sizes of the bundles too high, or it'll break, bc unbundle product will be capped at 1 stack.
-- This list here excludes the stacked- prefix.
local bundleItems = {
	"stone-brick",
	"concrete-block",
	"plastic-bar",
	"copper-ingot", "tin-ingot", "bronze-ingot", "iron-ingot", "gold-ingot",
	"lead-ingot", "steel-ingot", "brass-ingot", "nickel-ingot", "chromium-ingot",
	"platinum-ingot",
	"glass",
}

return {
	stackSizeGroups = stackSizeGroups,
	bundleItems = bundleItems,
}