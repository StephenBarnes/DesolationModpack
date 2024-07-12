local noise = require "noise"
local tne = noise.to_noise_expression

local C = require("code.data.terrain.constants")

-- Some notes:
-- map.wlc_elevation_offset (wlc = water level correction) -- This should be added to water level, to account for the water level set by the "coverage" slider.
-- map.wlc_elevation_minimum -- This is the minimum, so you should clamp elevation to be above this.
-- map.segmentation_multiplier -- this is the inverse of the water scale. Generally, you should multiply distances by this, and then divide the elevation output by this.
-- Basis noise arguments: seed0 should be map seed, seed1 should be any arbitrary number. Input scale should be var "segmentation_multiplier" divided by like 20, output scale should be the inverse of that.
-- For basis noise, setting output scale to 20 should give values roughly between -20 and +20.

local scaleSlider = noise.var("control-setting:Desolation-scale:frequency:multiplier")

local function correctWaterLevel(elevation, map)
	return noise.max(
		map.wlc_elevation_minimum,
		elevation + map.wlc_elevation_offset
	)
end

local nextSeed1 = 0
local function getNextSeed1()
	nextSeed1 = nextSeed1 + 1
	return nextSeed1
end

local function makeBasisNoise(inScale, outScale)
	if outScale == nil then outScale = 1 / inScale end
	return tne{
		type = "function-application",
		function_name = "factorio-basis-noise",
		arguments =
		{
			x = noise.var("x") + C.artifactShift,
			y = noise.var("y"),
			seed0 = noise.var("map_seed"),
			seed1 = tne(getNextSeed1()),
			input_scale = inScale,
			output_scale = outScale,
		}
	}
end

local function mapRandBetween(a, b, seed, steps)
	-- Returns a random number between a and b, that will be constant at every point on the map for the given seed.
	return a + (b - a) * (noise.fmod(seed, steps) / steps)
end

local function moveInDirection(x, y, angle, distance)
	return {
		x + distance * noise.cos(angle),
		y + distance * noise.sin(angle),
	}
end

local function dist(x1, y1, x2, y2)
	return ((noise.absolute_value(x1 - x2) ^ 2) + (noise.absolute_value(y1 - y2) ^ 2)) ^ tne(0.5)
	-- No idea why the absolute value is necessary, but it seems to be necessary.
end

local getStartIslandCenter = function(scale)
	local angle = mapRandBetween(C.startIslandAngleToCenterMin, C.startIslandAngleToCenterMax, noise.var("map_seed"), 23)
	return moveInDirection(tne(0), tne(0), angle, C.spawnToStartIslandCenter * scale)
end

local function makeMarkerLakeMaxElevation(scale, centerX, centerY, x, y, rad)
	local d = dist(centerX, centerY, x, y) / scale
	return d - rad
end

local function ramp(v, v1, v2, out1, out2)
	-- We should have v1 < v2, but not necessarily out1 < out2.
	local vBelow = noise.less_than(v, v1)
	local vAbove = noise.less_than(v2, v)
	local interpolationFrac = (v - v1) / (v2 - v1)
	local interpolated = interpolationFrac * out2 + (1 - interpolationFrac) * out1
	return noise.if_else_chain(vBelow, out1, vAbove, out2, interpolated)
end

local function ramp01(v, v1, v2)
	local vBelow = noise.less_than(v, v1)
	local vAbove = noise.less_than(v2, v)
	local interpolationFrac = (v - v1) / (v2 - v1)
	local interpolated = interpolationFrac
	return noise.if_else_chain(vBelow, 0, vAbove, 1, interpolated)
end

local function makeStartIslandMinElevation(scale, centerX, centerY, x, y)
	local basis1 = makeBasisNoise(1 / (scale * 160), tne(20)) -- should range between -20 and +20
	local basis2 = makeBasisNoise(1 / (scale * 80), tne(8))
	local basis3 = makeBasisNoise(1 / (scale * 40), tne(4))
	local basis4 = makeBasisNoise(1 / (scale * 20), tne(1.8))
	local basis5 = makeBasisNoise(1 / (scale * 10), tne(0.8))
	local basis = basis1 + basis2 + basis3 + basis4 + basis5
	local d = dist(centerX, centerY, x, y) / scale
	local ramp1 = ramp(d, C.startIslandMinRad, C.startIslandMaxRad, 25, -30)
	local minToPreventPuddles = ramp(d, C.startIslandMinRad - C.puddleMargin, C.startIslandMinRad, 10, -10)
	return noise.max(ramp1 + basis, minToPreventPuddles)
end

local function desolationOverallElevation(x, y, tile, map)
	local scale = 1 / (scaleSlider * map.segmentation_multiplier)
	local basic = makeBasisNoise(scale / 3) - 10
	local startIslandCenter = getStartIslandCenter(scale)
	local markerLakeMax1 = makeMarkerLakeMaxElevation(scale, startIslandCenter[1], startIslandCenter[2], x, y, 9)
	local markerLakeMax2 = makeMarkerLakeMaxElevation(scale, 0, 0, x, y, 5)
	local startIslandMinElevation = makeStartIslandMinElevation(scale, startIslandCenter[1], startIslandCenter[2], x, y)
	local basicPlusStartIsland = noise.max(startIslandMinElevation, basic)
	local elevation = correctWaterLevel(noise.min(basicPlusStartIsland, markerLakeMax1, markerLakeMax2), map)
	return elevation
end

data:extend {
	{
		type = "noise-expression",
		name = "Desolation-islands-elevation",
		intended_property = "elevation",
		expression = noise.define_noise_function(function(x, y, tile, map)
			return desolationOverallElevation(x, y, tile, map)
		end),
	},
}