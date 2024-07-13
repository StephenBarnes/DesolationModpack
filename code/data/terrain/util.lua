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
		arguments = {
			x = noise.var("x") + C.artifactShift,
			y = noise.var("y"),
			seed0 = noise.var("map_seed"),
			seed1 = tne(Export.getNextSeed1()),
			input_scale = inScale,
			output_scale = outScale,
		}
	}
end

Export.multiBasisNoise = function(octaves, inScaleMultiplier, outScaleDivisor, inScale, outScale)
	-- Makes multioctave noise function by layering multiple basis noise functions.
	-- Output of first (strongest) layer will generally be between -outScale and +outScale. So all layers together will be like double that range, very roughly.
	if outScale == nil then outScale = 1 / inScale end
	return tne{
		type = "function-application",
		function_name = "factorio-quick-multioctave-noise",
		arguments = {
			x = noise.var("x") + C.artifactShift,
			y = noise.var("y"),
			seed0 = noise.var("map_seed"),
			seed1 = tne(Export.getNextSeed1()),
			input_scale = tne(inScale),
			output_scale = tne(outScale),
			octaves = tne(octaves),
			octave_output_scale_multiplier = 1 / tne(outScaleDivisor),
			octave_input_scale_multiplier = tne(inScaleMultiplier),
		}
	}
end

Export.multiBasisNoiseSlow = function(levels, inScaleMultiplier, outScaleDivisor, inScale, outScale)
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

Export.ramp = function(v, v1, v2, out1, out2)
	-- If v < v1, then return out1. If v > v2, then return out2. Otherwise interpolate between out1 and out2.
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

Export.rampDouble = function(v, v1, v2, v3, out1, out2, out3)
	-- If v < v1, then return out1. If v > v3, then return out3. Otherwise, interpolate between out1 and out2, or between out2 and out3.
	-- We should have v1 < v2 < v3, but not necessarily out1 < out2 < out3.
	local interpolationFrac1 = (v - v1) / (v2 - v1)
	local interpolated1 = interpolationFrac1 * out2 + (1 - interpolationFrac1) * out1

	local interpolationFrac2 = (v - v2) / (v3 - v2)
	local interpolated2 = interpolationFrac2 * out3 + (1 - interpolationFrac2) * out2

	return noise.if_else_chain(noise.less_than(v, v1), out1,
		noise.less_than(v, v2), interpolated1,
		noise.less_than(v, v3), interpolated2, out3)
end

Export.between = function(v, v1, v2, ifTrue, ifFalse)
	-- Assumes v1 < v2.
	return noise.if_else_chain(noise.less_than(v, v1), ifFalse,
		noise.less_than(v2, v), ifFalse, ifTrue)
end

------------------------------------------------------------------------

local function getSpawnToStartIslandCenterAngle()
	return Export.mapRandBetween(C.startIslandAngleToCenterMin, C.startIslandAngleToCenterMax, noise.var("map_seed"), 23)
end

Export.getStartIslandCenter = function(scale)
	local angle = getSpawnToStartIslandCenterAngle()
	return Export.moveInDirection(tne(0), tne(0), angle, C.spawnToStartIslandCenter * scale)
end

Export.withinStartIsland = function(scale, x, y)
	local startIslandCenter = Export.getStartIslandCenter(scale)
	local distFromStartIsland = Export.dist(startIslandCenter[1], startIslandCenter[2], x, y) / scale
	return noise.less_than(distFromStartIsland, C.startIslandAndOffshootsMaxRad)
end

------------------------------------------------------------------------

local function getCenterToIronAngle()
	local baseAngle = getSpawnToStartIslandCenterAngle() -- Use this angle, so it's on the other side of the island from where player spawns.
	return baseAngle + Export.mapRandBetween(-C.startIslandIronMaxDeviationAngle, C.startIslandIronMaxDeviationAngle, noise.var("map_seed"), 17)
end

Export.getDistToIronArc = function(scale, x, y)
	local ironAngle = getCenterToIronAngle()
	local islandCenter = Export.getStartIslandCenter(scale)
	local arcStart = Export.moveInDirection(islandCenter[1], islandCenter[2], ironAngle, C.distCenterToIronArcStart * scale)
	local arcCenter = Export.moveInDirection(islandCenter[1], islandCenter[2], ironAngle, C.distCenterToIronArcCenter * scale)
	local arcEnd = Export.moveInDirection(islandCenter[1], islandCenter[2], ironAngle, C.distCenterToIron * scale)

	-- If the angle of the point to the arc center is within the arc, then distance to the arc depends on distance to the center.
	-- Otherwise, it's the min of the distances to the start and end.

	local distToArcStart = Export.dist(x, y, arcStart[1], arcStart[2])
	local distToArcEnd = Export.dist(x, y, arcEnd[1], arcEnd[2])
	local distToArcCenter = Export.dist(x, y, arcCenter[1], arcCenter[2])

	local endpointDist = noise.min(distToArcStart, distToArcEnd)
	local arcBodyDist = noise.absolute_value(distToArcCenter - C.ironArcRad * scale)

	--local angleToArcCenter = noise.atan2(arcCenter[2] - y, arcCenter[1] - x)
	--local angleWithinArg = noise.less_than(angleToArcCenter, 3.1416 / 2)

	-- Instead of checking the angle, since these are always half-circles, we can just check what side the point is on from the islandCenter-ironCenter line.
	-- This is easier than checking angle, since angle could be negative or go over 2pi if we adjust it, etc.

	local dx1 = x - arcEnd[1]
	local dy1 = y - arcEnd[2]
	local dx2 = x - islandCenter[1]
	local dy2 = y - islandCenter[2]
	local whichSide = noise.less_than(0.5, Export.mapRandBetween(0, 1, noise.var("map_seed"), 7))
	local isRightSide = noise.less_than(dx1 * dy2, dx2 * dy1)
	local isLeftSide = 1 - isRightSide
	local isCorrectSide = noise.if_else_chain(whichSide, isRightSide, isLeftSide)

	return noise.if_else_chain(isCorrectSide, arcBodyDist, endpointDist)
end

Export.getStartIslandIronCenter = function(scale)
	local ironAngle = getCenterToIronAngle()
	local islandCenter = Export.getStartIslandCenter(scale)
	return Export.moveInDirection(islandCenter[1], islandCenter[2], ironAngle, C.distCenterToIron * scale)
end

Export.getStartIslandIronArcCenter = function(scale)
	local ironAngle = getCenterToIronAngle()
	local islandCenter = Export.getStartIslandCenter(scale)
	return Export.moveInDirection(islandCenter[1], islandCenter[2], ironAngle, C.distCenterToIronArcCenter * scale)
end

------------------------------------------------------------------------

return Export