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

local tileItemsForbiddenOnIce = { -- Names of the entries in data.raw.item.
	"stone-brick",
	"concrete",
	"hazard-concrete",
	"refined-concrete",
	"refined-hazard-concrete",
	"tarmac",
}
local tilesForbiddenOnIce = { -- Names of the entries in data.raw.tile.
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
-- We need two unused collision layer, one for ice (to block paving) and one for snow+ice (to block buildings).
-- Unfortunately, collisionMaskUtil gives no way to get 2 unused layers. So make our own function to do that.
-- (If you just try calling collisionMaskUtil.get_first_unused_layer() twice, it will give you the same layer twice. So we need to do it ourselves.)
-- These tables and functions are copied from core, with modifications.
local default_masks = { ["accumulator"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["ammo-turret"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["arithmetic-combinator"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["arrow"] = {}, ["artillery-flare"] = {}, ["artillery-projectile"] = {}, ["artillery-turret"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["artillery-wagon"] = {"train-layer"}, ["assembling-machine"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["beacon"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["beam"] = {}, ["boiler"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["burner-generator"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["car"] = {"player-layer", "train-layer", "consider-tile-transitions"}, ["cargo-wagon"] = {"train-layer"}, ["character-corpse"] = {}, ["character"] = {"player-layer", "train-layer", "consider-tile-transitions"}, ["cliff"] = {"item-layer", "object-layer", "player-layer", "water-tile", "not-colliding-with-itself"}, ["combat-robot"] = {}, ["constant-combinator"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["construction-robot"] = {}, ["container"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["corpse"] = {}, ["curved-rail"] = {"floor-layer", "item-layer", "object-layer", "rail-layer", "water-tile"}, ["decider-combinator"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["deconstructible-tile-proxy"] = {"ground-tile"}, ["electric-energy-interface"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["electric-pole"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["electric-turret"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["entity-ghost"] = {"ghost-layer"}, ["explosion"] = {}, ["fire"] = {}, ["fish"] = {"ground-tile", "colliding-with-tiles-only"}, ["flame-thrower-explosion"] = {}, ["fluid-turret"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["fluid-wagon"] = {"train-layer"}, ["flying-text"] = {}, ["furnace"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["gate"] = {"item-layer", "object-layer", "player-layer", "train-layer", "water-tile"}, ["generator"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["heat-interface"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["heat-pipe"] = {"floor-layer", "object-layer", "water-tile"}, ["highlight-box"] = {}, ["infinity-container"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["infinity-pipe"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["inserter"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["item-entity"] = {"item-layer"}, ["item-request-proxy"] = {}, ["lab"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["lamp"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["land-mine"] = {"object-layer", "water-tile", "rail-layer"}, ["leaf-particle"] = {}, ["linked-belt"] = {"item-layer", "object-layer", "transport-belt-layer", "water-tile"}, ["linked-container"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["loader-1x1"] = {"item-layer", "object-layer", "transport-belt-layer", "water-tile"}, ["loader"] = {"item-layer", "object-layer", "transport-belt-layer", "water-tile"}, ["locomotive"] = {"train-layer"}, ["logistic-container"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["logistic-robot"] = {}, ["market"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["mining-drill"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["offshore-pump"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["particle-source"] = {}, ["particle"] = {}, ["pipe-to-ground"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["pipe"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["player-port"] = {"floor-layer", "object-layer", "water-tile"}, ["power-switch"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["programmable-speaker"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["projectile"] = {}, ["pump"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["radar"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["rail-chain-signal"] = {"floor-layer", "item-layer", "rail-layer"}, ["rail-remnants"] = {}, ["rail-signal"] = {"floor-layer", "item-layer", "rail-layer"}, ["reactor"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["resource"] = {"resource-layer"}, ["roboport"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["rocket-silo-rocket-shadow"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["rocket-silo-rocket"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["rocket-silo"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["simple-entity-with-force"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["simple-entity-with-owner"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["simple-entity"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["smoke-with-trigger"] = {}, ["smoke"] = {}, ["solar-panel"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["speech-bubble"] = {}, ["spider-leg"] = {"player-layer", "rail-layer"}, ["spider-vehicle"] = {"player-layer", "train-layer"}, ["splitter"] = {"item-layer", "object-layer", "transport-belt-layer", "water-tile"}, ["sticker"] = {}, ["storage-tank"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["straight-rail"] = {"floor-layer", "item-layer", "object-layer", "rail-layer", "water-tile"}, ["stream"] = {}, ["tile"] = {}, ["tile-ghost"] = {"ghost-layer"}, ["train-stop"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["transport-belt"] = {"floor-layer", "object-layer", "transport-belt-layer", "water-tile"}, ["tree"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["turret"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["underground-belt"] = {"item-layer", "object-layer", "transport-belt-layer", "water-tile"}, ["unit-spawner"] = {"item-layer", "object-layer", "player-layer", "water-tile"}, ["unit"] = {"player-layer", "train-layer", "not-colliding-with-itself"}, ["wall"] = {"item-layer", "object-layer", "player-layer", "water-tile"} }
local layer_names = { "ground-tile", "water-tile", "resource-layer", "doodad-layer", "floor-layer", "item-layer", "ghost-layer", "object-layer", "player-layer", "train-layer", "rail-layer", "transport-belt-layer" }
for k = 13, 55 do table.insert(layer_names, "layer-"..k) end
local is_layer_used = function(layer)
	for type, default_mask in pairs(default_masks) do
		for name, entity in pairs(data.raw[type]) do
			local entity_mask = entity.collision_mask or default_mask
			if collisionMaskUtil.mask_contains_layer(entity_mask, layer) then
				return true
			end
		end
	end
	return false
end
local getTwoUnusedLayers = function()
	local layerA = nil
	local layerB = nil
	for k, layer in pairs(layer_names) do
		if not collisionMaskUtil.is_layer_used(layer) then
			if layerA == nil then
				layerA = layer
			elseif layerB == nil then
				layerB = layer
				return {layerA, layerB}
			else
				log("ERROR: two non-nil layers, shouldn't be possible")
			end
		end
	end
	log("ERROR: couldn't find two unused layers")
	return {nil, nil}
end

local iceLayerAndSnowIceLayer = getTwoUnusedLayers()
local iceLayer = iceLayerAndSnowIceLayer[1] -- layer with ice, and things that can't be placed on ice but can be placed on snow.
local snowOrIceLayer = iceLayerAndSnowIceLayer[2] -- layer with snow and ice, and buildings that can't be placed on either of those.
log("Using layer "..iceLayer.." for ice, and layer "..snowOrIceLayer.." for snow or ice.")

-- Code adapted from Foundations mod
local function updateCollisionMaskToForbidBuilding(x, layer)
	-- Can be called on any entity or tile (to specify things buildable on that tile, not to specify what that tile can be built on).
	if x.collision_mask then
		table.insert(x.collision_mask, layer)
	else
		local mask = collisionMaskUtil.get_mask(x)
		table.insert(mask, layer)
		x.collision_mask = mask
	end
end

-- Add this collision mask to the snow/ice tiles.
for _, tileName in pairs(iceTiles) do
	updateCollisionMaskToForbidBuilding(data.raw.tile[tileName], iceLayer)
	updateCollisionMaskToForbidBuilding(data.raw.tile[tileName], snowOrIceLayer)
end
for _, tileName in pairs(snowTiles) do
	updateCollisionMaskToForbidBuilding(data.raw.tile[tileName], snowOrIceLayer)
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
			updateCollisionMaskToForbidBuilding(entity, snowOrIceLayer)
		end
	end
end

-- Add collision mask to paving tiles that can't be built on ice.
for _, tileName in pairs(tileItemsForbiddenOnIce) do
	--updateCollisionMaskToForbidBuilding(data.raw.tile[tileName], iceLayer)
		-- This would make it so things with iceLayer can't be built on these tiles. 
		-- But that's not what we want. We want to forbid building this tile on tiles with iceLayer.
	table.insert(data.raw.item[tileName].place_as_tile.condition, iceLayer)
end