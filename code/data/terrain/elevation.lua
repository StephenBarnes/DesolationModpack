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
	local basis = Util.multiBasisNoise(7, 2, 2, 1 / (scale * 200), tne(13))
	local d = Util.dist(centerX, centerY, x, y) / scale
	local ramp1 = Util.ramp(d, C.startIslandMinRad, C.startIslandMaxRad, 25, -30)
	local minToPreventPuddles = Util.ramp(d, C.startIslandMinRad - C.puddleMargin, C.startIslandMinRad, 10, -10)
	return noise.max(ramp1 + basis, minToPreventPuddles)
end

local function makeIronArcMinElevation(scale, x, y, ironNoise)
	local distToIronArc = Util.getDistToIronArc(scale, x, y) / scale

	-- Minimum elevation to ensure the minimum width of the arc is always reached.
	local arcMinElevation = Util.ramp(distToIronArc, C.ironArcMinWidth, C.ironArcMaxWidth, C.ironArcMinWidthHeightMin, -200)

	-- Add noise from the min width to the max width, to make the arc look natural.
	local noiseRamp = Util.rampDouble(distToIronArc, C.ironArcMinWidth, C.ironArcMaxWidth, C.ironArcMaxWidth * 2,
		C.ironArcNoiseAmplitude * 2, -C.ironArcNoiseAmplitude * 1.5, -200)
	local noiseElevation = ironNoise + noiseRamp

	local overallMinElevation = noise.max(arcMinElevation, noiseElevation)
	return noise.if_else_chain(
		noise.less_or_equal(noise.var("control-setting:Desolation-iron-arc:size:multiplier"), 1/6),
		-100, overallMinElevation)
end

local function makeIronBlobMinElevation(scale, x, y, ironNoise)
	local blobCenter = Util.getStartIslandIronCenter(scale)
	local distToBlobCenter = Util.dist(x, y, blobCenter[1], blobCenter[2]) / scale
	local blobMinElevation = Util.rampDouble(distToBlobCenter, 0, C.ironBlobMinRad * 2, C.ironBlobMinRad * 3, 10, -10, -100)
	local blobNoise = ironNoise + Util.rampDouble(distToBlobCenter, C.ironBlobMinRad, C.ironBlobMidRad, C.ironBlobMaxRad * 2,
		C.ironArcNoiseAmplitude * 2, -C.ironArcNoiseAmplitude, -100)
	local overallMinElevation = noise.max(blobMinElevation, blobNoise)
	return noise.if_else_chain(
		noise.less_or_equal(noise.var("control-setting:Desolation-iron-blob:size:multiplier"), 1/6),
		-100, overallMinElevation)
end

local function desolationOverallElevation(x, y, tile, map)
	local scale = 1 / (scaleSlider * map.segmentation_multiplier)
	local elevation = tne(-10)

	local startIslandCenter = Util.getStartIslandCenter(scale)
	local startIslandMinElevation = makeStartIslandMinElevation(scale, startIslandCenter[1], startIslandCenter[2], x, y)
	elevation = noise.max(startIslandMinElevation, elevation)

	local ironNoise = Util.multiBasisNoise(7, 2, 2, 1 / (scale * 200), tne(C.ironArcNoiseAmplitude))
	local ironArcMinElevation = makeIronArcMinElevation(scale, x, y, ironNoise)
	local ironBlobMinElevation = makeIronBlobMinElevation(scale, x, y, ironNoise)
	elevation = noise.max(ironArcMinElevation, ironBlobMinElevation, elevation)

	local markerLakeMax1 = makeMarkerLakeMaxElevation(scale, startIslandCenter[1], startIslandCenter[2], x, y, 9)
	local markerLakeMax2 = makeMarkerLakeMaxElevation(scale, 0, 0, x, y, 5)
	local ironCenter = Util.getStartIslandIronCenter(scale)
	local markerLakeMax3 = makeMarkerLakeMaxElevation(scale, ironCenter[1], ironCenter[2], x, y, 15)
	elevation = noise.min(elevation, markerLakeMax1, markerLakeMax2, markerLakeMax3)

	return correctWaterLevel(elevation, map)
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