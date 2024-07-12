-- Adjust the temperature noise layer so starting island is always snowy.

local noise = require "noise"

local C = require("code.data.terrain.constants")
local Util = require("code.data.terrain.util")

local scaleSlider = noise.var("control-setting:Desolation-scale:frequency:multiplier")

local function clamp_temperature(raw_temperature)
	return noise.clamp(raw_temperature, -20, 150)
end

local originalTempExpr = data.raw["noise-expression"].temperature.expression
local newTempExpr = noise.define_noise_function(function(x, y, tile, map)
	local scale = 1 / (scaleSlider * map.segmentation_multiplier)
	local startIslandCenter = Util.getStartIslandCenter(scale)
	local distFromStartIslandCenter = Util.dist(startIslandCenter[1], startIslandCenter[2], x, y) / scale
	local inStartIsland = noise.less_than(distFromStartIslandCenter, C.coldStartRegionRad)
	local maxTempForColdPatch = noise.if_else_chain(inStartIsland, -20, 150)
	local newTemp = noise.min(maxTempForColdPatch, originalTempExpr)
	return noise.ident(clamp_temperature(newTemp))
end)
data.raw["noise-expression"].temperature.expression = newTempExpr