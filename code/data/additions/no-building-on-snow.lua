-- We want to only allow building most structures on rock and grass, not on snow/ice.
-- Snow/ice can only have railways and rail signals.

local globalParams = require("code.global-params")

local snowTiles = {
	"frozen-snow-0",
	"frozen-snow-1",
	"frozen-snow-2",
	"frozen-snow-3",
	"frozen-snow-4",
	--"frozen-snow-7", -- not using this one bc it looks weird
}
local iceTiles = {
	"frozen-snow-5",
	"frozen-snow-6",
	"frozen-snow-8",
	"frozen-snow-9",
}
local buildableTiles = {
	"vegetation-turquoise-grass-1",
	"vegetation-turquoise-grass-2",
	"volcanic-orange-heat-1",
	"volcanic-orange-heat-2",
}

local forbiddenTypes = {
	"assembling-machine",
	"transport-belt",
	"lamp",
	"furnace",
	"splitter",
	"container",
	"ammo-turret",
	"accumulator",
	"artillery-turret",
	"fluid-turret",
	"electric-turret",
	"electric-pole",
	"loader",
	"arithmetic-combinator",
	"beacon",
	"boiler",
	"burner-generator",
	"constant-combinator",
	"decider-combinator",
	"electric-energy-interface",
	"generator",
	"heat-pipe",
	"inserter",
	"lab",
	"linked-container",
	"logistic-container",
	"mining-drill",
	"offshore-pump",
	"programmable-speaker",
	"pump",
	"radar",
	--"rail-chain-signal",
	"roboport",
	"rocket-silo",
	"simple-entity-with-force",
	"simple-entity-with-owner",
	"solar-panel",
	"splitter",
	"storage-tank",
	"train-stop",
	"programmable-speaker",
	"radar",
	"reactor",
	"roboport",
	"rocket-silo",
	"solar-panel",
	"wall",
	"pipe",
	"underground-belt",
}
local namesBuildableAnywhere = {
	["seismic-scanner"] = true,
	["big-electric-pole"] = true,
}

local tileItemsForbidBuilding = { -- Names of the entries in data.raw.item.
	"stone-brick",
	"concrete",
	"hazard-concrete",
	"refined-concrete",
	"refined-hazard-concrete",
	"tarmac",
}
local tilesForbidBuilding = { -- Names of the entries in data.raw.tile.
	"stone-path",
	"concrete",
	"hazard-concrete-left",
	"hazard-concrete-right",
	"refined-concrete",
	"refined-hazard-concrete-left",
	"refined-hazard-concrete-right",
	"tarmac",
}

local collisionMaskUtil = require("__core__/lualib/collision-mask-util")
local forbidBuildingLayer = collisionMaskUtil.get_first_unused_layer()

-- Code adapted from Foundations mod
local function updateCollisionMaskToForbidBuilding(x)
	-- Can be called on any entity or tile (to specify things buildable on that tile, not to specify what that tile can be built on).
	if x.collision_mask then
		table.insert(x.collision_mask, forbidBuildingLayer)
	else
		local mask = collisionMaskUtil.get_mask(x)
		table.insert(mask, forbidBuildingLayer)
		x.collision_mask = mask
	end
end

-- Add this collision mask to the snow/ice tiles.
for _, tileName in pairs(iceTiles) do
	updateCollisionMaskToForbidBuilding(data.raw.tile[tileName])
end
for _, tileName in pairs(snowTiles) do
	updateCollisionMaskToForbidBuilding(data.raw.tile[tileName])
end

-- Also update tile names for all the forbidden tiles, so the message shown to player looks better.
if globalParams.unifySnowIceTileNames then
	for _, tileName in pairs(snowTiles) do
		data.raw.tile[tileName].localised_name = {"Desolation.snow-tile"}
	end
	for _, tileName in pairs(iceTiles) do
		data.raw.tile[tileName].localised_name = {"Desolation.ice-tile"}
	end
end

-- Also add this collision mask to all the entities that can't be built on snow/ice.
for _, entityType in pairs(forbiddenTypes) do
	for entityName, entity in pairs(data.raw[entityType]) do
		if not namesBuildableAnywhere[entityName] then
			updateCollisionMaskToForbidBuilding(entity)
		end
	end
end

-- Add collision mask to paving tiles that can't be built on ice.
for _, tileName in pairs(tileItemsForbidBuilding) do
	--updateCollisionMaskToForbidBuilding(data.raw.tile[tileName])
		-- This would make it so buildings can't be built on these tiles.
		-- But that's not what we want. We want to forbid building these tiles on tiles with forbidBuildingLayer.
	table.insert(data.raw.item[tileName].place_as_tile.condition, forbidBuildingLayer)
end