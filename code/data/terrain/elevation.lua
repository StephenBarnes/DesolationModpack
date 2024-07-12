local noise = require "noise"
local tne = noise.to_noise_expression

local C = require("code.data.terrain.constants")
local Util = require("code.data.terrain.util")

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

local function makeMarkerLakeMaxElevation(scale, centerX, centerY, x, y, rad)
	local d = Util.dist(centerX, centerY, x, y) / scale
	return d - rad
end

local function makeStartIslandMinElevation(scale, centerX, centerY, x, y)
	local basis = Util.multiBasisNoise(6, 2, 2, 1 / (scale * 200), tne(13))
	local d = Util.dist(centerX, centerY, x, y) / scale
	local ramp1 = Util.ramp(d, C.startIslandMinRad, C.startIslandMaxRad, 25, -30)
	local minToPreventPuddles = Util.ramp(d, C.startIslandMinRad - C.puddleMargin, C.startIslandMinRad, 10, -10)
	return noise.max(ramp1 + basis, minToPreventPuddles)
end

local function desolationOverallElevation(x, y, tile, map)
	local scale = 1 / (scaleSlider * map.segmentation_multiplier)
	local basic = Util.basisNoise(scale / 3) - 10
	local startIslandCenter = Util.getStartIslandCenter(scale)
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