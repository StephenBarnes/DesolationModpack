local noise = require "noise"
local tne = noise.to_noise_expression

local C = require("code.data.terrain.constants")

local Export = {}

local nextSeed1 = 0
Export.getNextSeed1 = function()
	nextSeed1 = nextSeed1 + 1
	return nextSeed1
end

Export.basisNoise = function(inScale, outScale)
	if outScale == nil then outScale = 1 / inScale end
	return tne{
		type = "function-application",
		function_name = "factorio-basis-noise",
		arguments =
		{
			x = noise.var("x") + C.artifactShift,
			y = noise.var("y"),
			seed0 = noise.var("map_seed"),
			seed1 = tne(Export.getNextSeed1()),
			input_scale = inScale,
			output_scale = outScale,
		}
	}
end

Export.multiBasisNoise = function(levels, inScaleMultiplier, outScaleDivisor, inScale, outScale)
	-- Makes multioctave noise function by layering multiple basis noise functions.
	-- Output of first (strongest) layer will generally be between -outScale and +outScale. So all layers together will be like double that range, very roughly.
	local result = Export.basisNoise(inScale, outScale)
	for i = 2, levels do
		inScale = inScale * inScaleMultiplier
		outScale = outScale / outScaleDivisor
		local basis = Export.basisNoise(inScale, outScale)
		result = result + basis
	end
	return result
end

Export.mapRandBetween = function(a, b, seed, steps)
	-- Returns a random number between a and b, that will be constant at every point on the map for the given seed.
	return a + (b - a) * (noise.fmod(seed, steps) / steps)
end

Export.moveInDirection = function(x, y, angle, distance)
	return {
		x + distance * noise.cos(angle),
		y + distance * noise.sin(angle),
	}
end

Export.dist = function(x1, y1, x2, y2)
	return ((noise.absolute_value(x1 - x2) ^ 2) + (noise.absolute_value(y1 - y2) ^ 2)) ^ tne(0.5)
	-- No idea why the absolute value is necessary, but it seems to be necessary.
end

local function getSpawnToStartIslandCenterAngle()
	return Export.mapRandBetween(C.startIslandAngleToCenterMin, C.startIslandAngleToCenterMax, noise.var("map_seed"), 23)
end

Export.getStartIslandCenter = function(scale)
	local angle = getSpawnToStartIslandCenterAngle()
	return Export.moveInDirection(tne(0), tne(0), angle, C.spawnToStartIslandCenter * scale)
end

Export.getStartIslandIronCenter = function(scale)
	local baseAngle = getSpawnToStartIslandCenterAngle() -- Use this angle, so it's on the other side of the island from where player spawns.
	local angle = baseAngle + Export.mapRandBetween(-C.startIslandIronMaxDeviationAngle, C.startIslandIronMaxDeviationAngle, noise.var("map_seed"), 17)
	local islandCenter = Export.getStartIslandCenter(scale)
	return Export.moveInDirection(islandCenter[1], islandCenter[2], angle, C.distCenterToIron * scale)
end

Export.ramp = function(v, v1, v2, out1, out2)
	-- We should have v1 < v2, but not necessarily out1 < out2.
	local vBelow = noise.less_than(v, v1)
	local vAbove = noise.less_than(v2, v)
	local interpolationFrac = (v - v1) / (v2 - v1)
	local interpolated = interpolationFrac * out2 + (1 - interpolationFrac) * out1
	return noise.if_else_chain(vBelow, out1, vAbove, out2, interpolated)
end

Export.ramp01 = function(v, v1, v2)
	local vBelow = noise.less_than(v, v1)
	local vAbove = noise.less_than(v2, v)
	local interpolationFrac = (v - v1) / (v2 - v1)
	local interpolated = interpolationFrac
	return noise.if_else_chain(vBelow, 0, vAbove, 1, interpolated)
end

return Export