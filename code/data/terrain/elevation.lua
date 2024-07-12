local noise = require "noise"
local tne = noise.to_noise_expression

local C = require("code.data.terrain.constants")

-- Some notes:
-- map.wlc_elevation_offset (wlc = water level correction) -- This should be added to water level, to account for the water level set by the "coverage" slider.
-- map.wlc_elevation_minimum -- This is the minimum, so you should clamp elevation to be above this.
-- map.segmentation_multiplier -- this is the inverse of the water scale. Generally, you should multiply distances by this, and then divide the elevation output by this.
-- Basis noise arguments: seed0 should be map seed, seed1 should be any arbitrary number. Input scale should be var "segmentation_multiplier" divided by like 20, output scale should be the inverse of that.

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

local function makeBasisNoise(scale)
	return tne{
		type = "function-application",
		function_name = "factorio-basis-noise",
		arguments =
		{
			x = noise.var("x"),
			y = noise.var("y"),
			seed0 = noise.var("map_seed"),
			seed1 = tne(getNextSeed1()),
			input_scale = scale,
			output_scale = 1 / scale,
		}
	}
end

local function mapRandBetween(a, b, seed, steps)
	-- Returns a random number between a and b, that will be constant at every point on the map for the given seed.
	return a + (b - a) * (noise.fmod(seed, steps) / steps)
end

local getStartIslandCenter = function()
	local angle = mapRandBetween(C.startIslandAngleToCenterMin, C.startIslandAngleToCenterMax, noise.var("map_seed"), 20)
	local x = C.startIslandMinRad * noise.cos(angle) + C.xShift
	local y = C.startIslandMinRad * noise.sin(angle)
	--local x = tne(200) + C.xShift
	--local y = tne(100)
	return {x, y}
end

local function makeMarkerLakeMaxElevation(scale, centerX, centerY, x, y, rad)
	local dist = noise.absolute_value(centerX - x) + noise.absolute_value(centerY - y)
	--local dist = ((x - centerX) ^ 2 + (y - centerY) ^ 2) ^ 0.5
	return (dist * scale) - rad
end

local function desolationOverallElevation(x, y, tile, map)
	local scale = scaleSlider * map.segmentation_multiplier
	--local basic = makeBasisNoise(scale / 3) + 10
	local basic = noise.ridge(x+y, 0, 20)
	local startIslandCenter = getStartIslandCenter()
	local markerLakeMax1 = makeMarkerLakeMaxElevation(scale / 3, startIslandCenter[1], startIslandCenter[2], x, y, 10)
	local markerLakeMax2 = makeMarkerLakeMaxElevation(scale / 3, 0 + C.xShift, 0, x, y, 5)
	local elevation = correctWaterLevel(noise.min(basic, markerLakeMax1, markerLakeMax2), map)
	return elevation
end

data:extend {
	{
		--similar to vanilla, but with a bigger minimum starting area
		type = "noise-expression",
		name = "Desolation-islands-elevation",
		intended_property = "elevation",
		expression = noise.define_noise_function(function(x, y, tile, map)
			return desolationOverallElevation(x + C.xShift, y, tile, map)
		end),
	},
}