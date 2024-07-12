-- Adjust the temperature noise layer so starting island is always snowy.
-- Some of this code is copied from Factorio's core code.

local noise = require "noise"

local C = require("code.data.terrain.constants")

local scaleSlider = noise.var("control-setting:Desolation-scale:frequency:multiplier")

local function clamp_temperature(raw_temperature)
	return noise.clamp(raw_temperature, -20, 150)
end

local originalTempExpr = data.raw["noise-expression"].temperature.expression
local newTempExpr = noise.define_noise_function(function(x, y, tile, map)
	local scale = scaleSlider * map.segmentation_multiplier
	local startColdPatchRadius = C.coldRegionSize / scale
	local dist = noise.distance_from(x, y, noise.var("starting_lake_positions"), 1024)
	local startPatchInfluence = (startColdPatchRadius - dist) / startColdPatchRadius
	local startPatchInfluenceClamped = noise.clamp(startPatchInfluence, 0, 1)
	local tempAdjustment = -170 * startPatchInfluenceClamped
	local correctedTemp = originalTempExpr + tempAdjustment
	return noise.ident(clamp_temperature(correctedTemp))
end)
data.raw["noise-expression"].temperature.expression = newTempExpr