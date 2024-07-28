-- We want to restrict landfill to only be built on shallow water.

local collisionMaskUtil = require("__core__/lualib/collision-mask-util")
local nonShallowWaterLayer = collisionMaskUtil.get_first_unused_layer()

local nonShallowWaterTiles = {
	"deepwater",
	"water",
}

-- Add the layer to all non-shallow water tiles.
for _, tileName in pairs(nonShallowWaterTiles) do
	table.insert(data.raw.tile[tileName].collision_mask, nonShallowWaterLayer)
end

-- Add the layer to landfill.
table.insert(data.raw.item["landfill"].place_as_tile.condition, nonShallowWaterLayer)

for tileName, tile in pairs(data.raw.tile) do
	log("Tile name: "..tileName)
end