local noise = require "noise"
local tne = noise.to_noise_expression

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
	return {
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

local function desolationOverallElevation(x, y, tile, map)
	local scale = scaleSlider * map.segmentation_multiplier
	local basic = makeBasisNoise(scale / 10)
	local elevation = correctWaterLevel(basic, map)
	return elevation
end

data:extend {
	{
		--similar to vanilla, but with a bigger minimum starting area
		type = "noise-expression",
		name = "Desolation-islands-elevation",
		intended_property = "elevation",
		expression = noise.define_noise_function(function(x, y, tile, map)
			x = x + 20000 -- Move the point where 'fractal similarity' is obvious off into the boonies
			y = y
			return desolationOverallElevation(x, y, tile, map)
		end),
	},
}