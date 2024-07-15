-- Adjust the temperature noise layer so starting island is always snowy.

local noise = require "noise"

local C = require("code.data.terrain.constants")
local Util = require("code.data.terrain.util")

local function clamp_temperature(raw_temperature)
	return noise.clamp(raw_temperature, -20, 150) -- Alien Biomes seems to use this range.
end

local originalTempExpr = data.raw["noise-expression"].temperature.expression
-- TODO rather than modifying the original expression, rather create a fully custom expression.
local newTempExpr = noise.define_noise_function(function(x, y, tile, map)
	-- Reduce temperature around the starting island.
	local centerDist = noise.var("dist-to-start-island-rim")
	local tempAdjustmentDueToCenter = Util.ramp(centerDist / noise.var("scale"),
		C.otherIslandsMinDistFromStartIsland, C.otherIslandsFadeInMidFromStartIsland,
		-200, 0)

	local newTemp = originalTempExpr + tempAdjustmentDueToCenter
	return noise.ident(clamp_temperature(newTemp))
end)
data.raw["noise-expression"].temperature.expression = newTempExpr