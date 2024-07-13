-- Adjust the temperature noise layer so starting island is always snowy.

local noise = require "noise"

local C = require("code.data.terrain.constants")
local Util = require("code.data.terrain.util")

local function clamp_temperature(raw_temperature)
	return noise.clamp(raw_temperature, -20, 150) -- Alien Biomes seems to use this range.
end

local originalTempExpr = data.raw["noise-expression"].temperature.expression
local newTempExpr = noise.define_noise_function(function(x, y, tile, map)
	local scale = 1 / (C.terrainScaleSlider * map.segmentation_multiplier)

	-- Reduce temperature around the center of the starting island.
	local startIslandCenter = Util.getStartIslandCenter(scale)
	local distFromStartIslandCenter = Util.dist(startIslandCenter[1], startIslandCenter[2], x, y) / scale
	local tempAdjustmentDueToStartIslandCenter = Util.ramp(distFromStartIslandCenter,
		C.otherIslandsMinDistFromStartIslandCenter, C.otherIslandsFadeInMidFromStartIslandCenter,
		-50, 50)

	-- Also reduce temperature around the center of the iron arc.
	local ironArcCenter = Util.getStartIslandIronArcCenter(scale)
	local distFromIronArcCenter = Util.dist(ironArcCenter[1], ironArcCenter[2], x, y) / scale
	local tempAdjustmentDueToIronArcCenter = Util.ramp(distFromIronArcCenter,
		C.otherIslandsMinDistFromIronArcCenter, C.otherIslandsFadeInMidFromIronArcCenter,
		-50, 50)

	local tempAdjustmentTotal = noise.clamp(noise.min(tempAdjustmentDueToStartIslandCenter, tempAdjustmentDueToIronArcCenter), -50, 0)

	local newTemp = originalTempExpr + tempAdjustmentTotal
	return noise.ident(clamp_temperature(newTemp))
end)
data.raw["noise-expression"].temperature.expression = newTempExpr