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

local function correctWaterLevel(elevation, map)
	return noise.max(
		map.wlc_elevation_minimum,
		elevation + map.wlc_elevation_offset
	)
end

local function makeMarkerLakeMaxElevation(scale, centerX, centerY, x, y, rad)
	-- Makes max elevation that can be min'd with an elevation to create a marker lake at the given center.
	local d = Util.dist(centerX, centerY, x, y) / scale
	return d - rad
end

local function addMarkerLake(elevation, scale, centerX, centerY, x, y, rad)
	-- Given elevation, adds a marker lake.
	local markerLakeMax = makeMarkerLakeMaxElevation(scale, centerX, centerY, x, y, rad)
	return noise.min(elevation, markerLakeMax)
end

local function makeStartIslandMinElevation(scale, centerX, centerY, x, y)
	local basis = Util.multiBasisNoise(7, 2, 2, 1 / (scale * 200), tne(13))
	local d = Util.dist(centerX, centerY, x, y) / scale
	local ramp1 = Util.ramp(d, C.startIslandMinRad, C.startIslandMaxRad, 25, -30)
	local minToPreventPuddles = Util.ramp(d, C.startIslandMinRad - C.puddleMargin, C.startIslandMinRad, 10, -10)
	return noise.max(ramp1 + basis, minToPreventPuddles)
end

local function makeStartIslandMaxElevation(scale, centerX, centerY, x, y)
	-- Just pushes the starting island max elevation down far away from the center, so that we don't have tiny isles far away from weird noise.
	local d = Util.dist(centerX, centerY, x, y) / scale
	return Util.ramp(d, C.startIslandMaxRad, C.startIslandAndOffshootsMaxRad, 100, -1000)
end

local function makeIronArcMinElevation(scale, x, y, ironNoise)
	local distToIronArc = Util.getDistToIronArc(scale, x, y) / scale

	-- Minimum elevation to ensure the minimum width of the arc is always reached.
	local arcMinElevation = Util.ramp(distToIronArc, C.ironArcMinWidth, C.ironArcMaxWidth, C.ironArcMinWidthHeightMin, -200)

	-- Add noise from the min width to the max width, to make the arc look natural.
	local noiseRamp = Util.rampDouble(distToIronArc, C.ironArcMinWidth, C.ironArcMaxWidth, C.ironArcMaxWidth * 2,
		C.ironArcBlobNoiseAmplitude * 2, -C.ironArcBlobNoiseAmplitude * 1.5, -200)
	local noiseElevation = ironNoise + noiseRamp

	local overallMinElevation = noise.max(arcMinElevation, noiseElevation)
	return noise.if_else_chain(C.ironArcEnabled, -100, overallMinElevation)
end

local function makeIronBlobMinElevation(scale, x, y, ironNoise)
	local blobCenter = Util.getStartIslandIronCenter(scale)
	local distToBlobCenter = Util.dist(x, y, blobCenter[1], blobCenter[2]) / scale
	local blobMinElevation = Util.rampDouble(distToBlobCenter, 0, C.ironBlobMinRad * 2, C.ironBlobMinRad * 3, 10, -10, -100)
	local blobNoise = ironNoise + Util.rampDouble(distToBlobCenter, C.ironBlobMinRad, C.ironBlobMidRad, C.ironBlobMaxRad * 2,
		C.ironArcBlobNoiseAmplitude * 2, -C.ironArcBlobNoiseAmplitude, -100)
	local overallMinElevation = noise.max(blobMinElevation, blobNoise)
	return noise.if_else_chain(C.ironBlobEnabled, -100, overallMinElevation)
end

local function getStartIslandAndOffshootsMinElevation(scale, x, y, tile, map)
	local elevation = tne(-10) -- starting elevation

	local startIslandCenter = Util.getStartIslandCenter(scale)
	local startIslandMinElevation = makeStartIslandMinElevation(scale, startIslandCenter[1], startIslandCenter[2], x, y)
	elevation = noise.max(startIslandMinElevation, elevation)

	local startIslandMaxElevation = makeStartIslandMaxElevation(scale, startIslandCenter[1], startIslandCenter[2], x, y)
	elevation = noise.min(startIslandMaxElevation, elevation)

	local ironNoise = Util.multiBasisNoise(7, 2, 2, C.ironArcBlobNoiseScale / scale, C.ironArcBlobNoiseAmplitude)
	local ironArcMinElevation = makeIronArcMinElevation(scale, x, y, ironNoise)
	local ironBlobMinElevation = makeIronBlobMinElevation(scale, x, y, ironNoise)
	local ironMinElevation = noise.max(ironArcMinElevation, ironBlobMinElevation)
	elevation = noise.max(elevation, ironMinElevation)

	elevation = addMarkerLake(elevation, scale, startIslandCenter[1], startIslandCenter[2], x, y, 9)
	elevation = addMarkerLake(elevation, scale, 0, 0, x, y, 5)

	local ironCenter = Util.getStartIslandIronCenter(scale)
	elevation = addMarkerLake(elevation, scale, ironCenter[1], ironCenter[2], x, y, 5)

	return elevation
end

local function getOtherIslandsMinElevation(scale, x, y, tile, map)
	-- This line creates all of the other islands.
	local elevation = Util.multiBasisNoise(8, 2, 2, (1 / 1000) / scale, tne(13)) - 12.2
	-- TODO move these to sliders.

	-- Cut off elevation from other islands close to the starting island.
	local startIslandCenter = Util.getStartIslandCenter(scale)
	local distFromStartIslandCenter = Util.dist(startIslandCenter[1], startIslandCenter[2], x, y) / scale
	local maxElevationToAvoidStartIslandCenter = Util.ramp(distFromStartIslandCenter,
		C.otherIslandsMinDistFromStartIslandCenter, C.otherIslandsFadeInMidFromStartIslandCenter,
		-100, 100)
	elevation = noise.min(elevation, maxElevationToAvoidStartIslandCenter)
	-- In addition to this min to hard-cutoff the elevation around the start island, we also add a constant to fade in islands gradually.
	local fadeAdjustmentForStartIslandCenter = Util.rampDouble(distFromStartIslandCenter,
		C.otherIslandsMinDistFromStartIslandCenter, C.otherIslandsFadeInMidFromStartIslandCenter, C.otherIslandsFadeInEndFromStartIslandCenter,
		-40, -20, 0)

	-- Also cut off elevation from other islands close to the iron arc center.
	local ironArcCenter = Util.getStartIslandIronArcCenter(scale)
	local distFromIronArcCenter = Util.dist(ironArcCenter[1], ironArcCenter[2], x, y) / scale
	local maxElevationToAvoidIronArcCenter = Util.ramp(distFromIronArcCenter,
		C.otherIslandsMinDistFromIronArcCenter, C.otherIslandsFadeInMidFromIronArcCenter,
		-100, 100)
	elevation = noise.min(elevation, maxElevationToAvoidIronArcCenter)
	-- In addition to this min to hard-cutoff the elevation around the iron arc center, we also add a constant to fade in islands gradually.
	local fadeAdjustmentForIronArcCenter = Util.rampDouble(distFromIronArcCenter,
		C.otherIslandsMinDistFromIronArcCenter, C.otherIslandsFadeInMidFromIronArcCenter, C.otherIslandsFadeInEndFromIronArcCenter,
		-40, -20, 0)

	-- We combine these two added constants to get a final elevation fade-in constant.
	local fadeAdjustmentTotal = noise.min(fadeAdjustmentForStartIslandCenter, fadeAdjustmentForIronArcCenter)
	elevation = elevation + fadeAdjustmentTotal

	return elevation
end

local function desolationOverallElevation(x, y, tile, map)
	local scale = 1 / (C.terrainScaleSlider * map.segmentation_multiplier)

	local startIslandAndOffshootsMinElevation = getStartIslandAndOffshootsMinElevation(scale, x, y, tile, map)

	local otherIslandsMinElevation = getOtherIslandsMinElevation(scale, x, y, tile, map)
	local elevation = noise.max(startIslandAndOffshootsMinElevation, otherIslandsMinElevation)

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