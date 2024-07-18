-- This file changes what tiles get autoplaced where.
-- Use noise layers defined in other files to determine whether we need buildable tiles (eg at resources) or not.

local noise = require "noise"
local U = require("code.data.terrain.util")

-- Disable autoplace for the hotter volcanic terrain, bc we want to use the greyer rock ones as buildable land.
data.raw.tile["volcanic-orange-heat-3"].autoplace = nil
data.raw.tile["volcanic-orange-heat-4"].autoplace = nil

--local snowBaseTile = "frozen-snow-0"
--local snowOtherTiles = {
--	"frozen-snow-1",
--	"frozen-snow-2",
--	"frozen-snow-3",
--	"frozen-snow-4",
--	"frozen-snow-5",
--	"frozen-snow-6",
--	"frozen-snow-7",
--	"frozen-snow-8",
--	"frozen-snow-9",
--}
--local snowBaseAutoplace = noise.if_else_chain(noise.less_than(noise.var("elevation"), 5), 0, 0.3)
--local snowOtherAutoplace = noise.if_else_chain(noise.less_than(noise.var("elevation"), 5), 0, 0.5)
--data.raw.tile[snowBaseTile].autoplace = {
--	probability_expression = snowBaseAutoplace,
--	richness_expression = snowBaseAutoplace,
--}
--for _, tileName in pairs(snowOtherTiles) do
--	data.raw.tile[tileName].autoplace = {
--		probability_expression = snowOtherAutoplace,
--		richness_expression = snowBaseAutoplace,
--	}
--end

-- Table mapping tile name to (min elevation, max elevation, min aux, max aux).
--local tilePlacementInfo = {
--	["frozen-snow-0"] = {0, 5, -1000, 0},
--	["frozen-snow-1"] = {0, 5, 0, 1000},
--	["frozen-snow-2"] = {5, 10, -1000, 0},
--	["frozen-snow-3"] = {5, 10, 0, 1000},
--	["frozen-snow-4"] = {10, 15, -1000, 0},
--	["frozen-snow-5"] = {10, 15, 0, 1000},
--	["frozen-snow-6"] = {15, 20, -1000, 0},
--	["frozen-snow-7"] = {15, 20, 0, 1000},
--	["frozen-snow-8"] = {20, 25, -1000, 0},
--	["frozen-snow-9"] = {20, 25, 0, 1000},
--	["volcanic-orange-heat-1"] = {25, 30, -1000, 0},
--	["volcanic-orange-heat-2"] = {25, 30, 0, 1000},
--	["vegetation-turquoise-grass-1"] = {30, 1000, -1000, 0},
--	["vegetation-turquoise-grass-2"] = {30, 1000, 0, 1000},
--}
--for tileName, tileRange in pairs(tilePlacementInfo) do
--	local minElevation, maxElevation, minAux, maxAux = tileRange[1], tileRange[2], tileRange[3], tileRange[4]
--	local placementFactor = noise.if_else_chain(
--		noise.less_than(noise.var("elevation"), minElevation), 0,
--		noise.less_than(maxElevation, noise.var("elevation")), 0,
--		noise.less_than(noise.var("aux"), minAux), 0,
--		noise.less_than(maxAux, noise.var("aux")), 0,
--		1)
--	data.raw.tile[tileName].autoplace = {
--		probability_expression = placementFactor,
--		richness_expression = placementFactor,
--	}
--end
-- So, that works, but it's very slow. Let's rather use the peaks system.


local tilePlacementInfo = {
	["frozen-snow-0"] = {0, 5, -1000, 0},
	["frozen-snow-1"] = {0, 5, 0, 1000},
	["frozen-snow-2"] = {5, 10, -1000, 0},
	["frozen-snow-3"] = {5, 10, 0, 1000},
	["frozen-snow-4"] = {10, 15, -1000, 0},
	["frozen-snow-5"] = {10, 15, 0, 1000},
	["frozen-snow-6"] = {15, 20, -1000, 0},
	["frozen-snow-7"] = {15, 20, 0, 1000},
	["frozen-snow-8"] = {20, 25, -1000, 0},
	["frozen-snow-9"] = {20, 25, 0, 1000},
	["volcanic-orange-heat-1"] = {25, 30, -1000, 0},
	["volcanic-orange-heat-2"] = {25, 30, 0, 1000},
	["vegetation-turquoise-grass-1"] = {30, 1000, -1000, 0},
	["vegetation-turquoise-grass-2"] = {30, 1000, 0, 1000},
}
-- First disable all autoplaces
for tileName, tileRange in pairs(tilePlacementInfo) do
	data.raw.tile[tileName].autoplace = nil
end
-- Now, use some peaks to set autoplaces for two of them, so I can see how it works.
local function makeAutoplace(temp, aux)
	return {
		peaks = {
			{
				influence = 0.5,
				noise_octaves_difference = 2,
				noise_persistence = 0.4,
				temperature_optimal = temp,
				temperature_range = 0,
				temperature_max_range = 1000,
				aux_optimal = aux,
				aux_range = 0,
				aux_max_range = 1000,
			},
		},
		sharpness = 0,
	}
end
data.raw.tile["volcanic-orange-heat-1"].autoplace = makeAutoplace(10, 1)
data.raw.tile["vegetation-turquoise-grass-1"].autoplace = makeAutoplace(10, -1)
data.raw.tile["frozen-snow-0"].autoplace = makeAutoplace(0, 2)
data.raw.tile["frozen-snow-9"].autoplace = makeAutoplace(0, -1)