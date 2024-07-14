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
		C.arcBlobNoiseAmplitude * 2, -C.arcBlobNoiseAmplitude * 1.5, -200)
	local noiseElevation = ironNoise + noiseRamp

	local overallMinElevation = noise.max(arcMinElevation, noiseElevation)
	return noise.if_else_chain(C.ironArcEnabled, -100, overallMinElevation)
end

local function makeIronBlobMinElevation(scale, x, y, arcBlobNoise)
	local blobCenter = Util.getStartIslandIronCenter(scale)
	local distToBlobCenter = Util.dist(x, y, blobCenter[1], blobCenter[2]) / scale
	local blobMinElevation = Util.rampDouble(distToBlobCenter, 0, C.ironBlobMinRad * 2, C.ironBlobMinRad * 3, 10, -10, -100)
	local blobNoise = arcBlobNoise + Util.rampDouble(distToBlobCenter, C.ironBlobMinRad, C.ironBlobMidRad, C.ironBlobMaxRad * 2,
		C.arcBlobNoiseAmplitude * 2, -C.arcBlobNoiseAmplitude, -100)
	local overallMinElevation = noise.max(blobMinElevation, blobNoise)
	return noise.if_else_chain(C.ironBlobEnabled, -100, overallMinElevation)
end

local function makeCopperTinArcMinElevation(scale, x, y, arcBlobNoise)
	local distToCopperTinArc = Util.getDistToCopperTinArc(scale, x, y) / scale

	-- Minimum elevation to ensure the minimum width of the arc is always reached.
	local arcMinElevation = Util.ramp(distToCopperTinArc, C.copperTinArcMinWidth, C.copperTinArcMaxWidth, C.copperTinArcMinWidthHeightMin, -200)

	-- Add noise from the min width to the max width, to make the arc look natural.
	local noiseRamp = Util.rampDouble(distToCopperTinArc, C.copperTinArcMinWidth, C.copperTinArcMaxWidth, C.copperTinArcMaxWidth * 2,
		C.arcBlobNoiseAmplitude * 2, -C.arcBlobNoiseAmplitude * 1.5, -200)
	local noiseElevation = arcBlobNoise + noiseRamp

	local overallMinElevation = noise.max(arcMinElevation, noiseElevation)
	return noise.if_else_chain(C.copperTinArcEnabled, -100, overallMinElevation)
end

local function makeCopperTinBlobMinElevation(scale, x, y, arcBlobNoise)
	local blobCenter = Util.getStartIslandCopperTinCenter(scale)
	local distToBlobCenter = Util.dist(x, y, blobCenter[1], blobCenter[2]) / scale
	local blobMinElevation = Util.rampDouble(distToBlobCenter, 0, C.copperTinBlobMinRad * 2, C.copperTinBlobMinRad * 3, 10, -10, -100)
	local blobNoise = arcBlobNoise + Util.rampDouble(distToBlobCenter, C.copperTinBlobMinRad, C.copperTinBlobMidRad, C.copperTinBlobMaxRad * 2,
		C.arcBlobNoiseAmplitude * 2, -C.arcBlobNoiseAmplitude, -100)
	local overallMinElevation = noise.max(blobMinElevation, blobNoise)
	return noise.if_else_chain(C.copperTinBlobEnabled, -100, overallMinElevation)
end

local function getStartIslandAndOffshootsMinElevation(scale, x, y, tile, map)
	local elevation = tne(-10) -- starting elevation

	local startIslandCenter = Util.getStartIslandCenter(scale)
	local startIslandMinElevation = makeStartIslandMinElevation(scale, startIslandCenter[1], startIslandCenter[2], x, y)
	elevation = noise.max(startIslandMinElevation, elevation)

	local startIslandMaxElevation = makeStartIslandMaxElevation(scale, startIslandCenter[1], startIslandCenter[2], x, y)
	elevation = noise.min(startIslandMaxElevation, elevation)

	local arcBlobNoise = Util.multiBasisNoise(7, 2, 2, C.arcBlobNoiseScale / scale, C.arcBlobNoiseAmplitude)

	local ironArcMinElevation = makeIronArcMinElevation(scale, x, y, arcBlobNoise)
	local ironBlobMinElevation = makeIronBlobMinElevation(scale, x, y, arcBlobNoise)
	local ironMinElevation = noise.max(ironArcMinElevation, ironBlobMinElevation)
	elevation = noise.max(elevation, ironMinElevation)

	local copperTinArcMinElevation = makeCopperTinArcMinElevation(scale, x, y, arcBlobNoise)
	local copperTinBlobMinElevation = makeCopperTinBlobMinElevation(scale, x, y, arcBlobNoise)
	local copperTinMinElevation = noise.max(copperTinArcMinElevation, copperTinBlobMinElevation)
	elevation = noise.max(elevation, copperTinMinElevation)

	elevation = addMarkerLake(elevation, scale, startIslandCenter[1], startIslandCenter[2], x, y, 9)
	elevation = addMarkerLake(elevation, scale, 0, 0, x, y, 5)

	local ironCenter = Util.getStartIslandIronCenter(scale)
	elevation = addMarkerLake(elevation, scale, ironCenter[1], ironCenter[2], x, y, 5)
	local copperTinCenter = Util.getStartIslandCopperTinCenter(scale)
	elevation = addMarkerLake(elevation, scale, copperTinCenter[1], copperTinCenter[2], x, y, 5)

	return elevation
end

local function getOtherIslandsMinElevation(scale, x, y, tile, map)
	-- This line creates all of the other islands.
	local elevation = Util.multiBasisNoise(8, 2, 2, (1 / 1000) / scale, tne(13)) - 11.8
	-- TODO move these to sliders.

	-- Cut off elevation from other islands close to the starting island.
	local startIslandDist = Util.getMinDistToStartIsland(scale, x, y)
	local maxElevationToAvoidCenter = Util.ramp(startIslandDist,
		C.otherIslandsMinDistFromStartIsland, C.otherIslandsFadeInMidFromStartIsland,
		-100, 100)
	elevation = noise.min(elevation, maxElevationToAvoidCenter)

	-- In addition to this min to hard-cutoff the elevation around the start island, we also add a constant to fade in islands gradually.
	local fadeAdjustment = Util.rampDouble(startIslandDist,
		C.otherIslandsMinDistFromStartIsland, C.otherIslandsFadeInMidFromStartIsland, C.otherIslandsFadeInEndFromStartIsland,
		-40, -20, 0)
	elevation = elevation + fadeAdjustment

	return noise.if_else_chain(C.surroundingIslandsToggle, elevation, fadeAdjustment + 20)
	--return elevation
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