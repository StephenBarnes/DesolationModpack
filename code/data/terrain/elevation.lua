local noise = require "noise"
local tne = noise.to_noise_expression
local var = noise.var

local C = require("code.data.terrain.constants")
local U = require("code.data.terrain.util")
local globalParams = require("code.global-params")

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
	local d = U.dist(centerX, centerY, x, y) / scale
	return d - rad
end

local function addMarkerLake(elevation, scale, centerX, centerY, x, y, rad)
	-- Given elevation, adds a marker lake.
	if not globalParams.enableMarkerLakes then return elevation end
	local markerLakeMax = makeMarkerLakeMaxElevation(scale, centerX, centerY, x, y, rad)
	return noise.min(elevation, markerLakeMax)
end

local function makeStartIslandMinElevation(scale, centerX, centerY, x, y)
	local basis = U.multiBasisNoise(7, 2, 2, C.startIslandNoiseScale / scale, C.startIslandNoiseAmplitude)
	local d = U.dist(centerX, centerY, x, y) / scale
	local ramp1 = U.ramp(d, C.startIslandMinRad, C.startIslandMidRad, 25, -100)
	local minToPreventPuddles = U.rampDouble(d,
		C.startIslandMinRad - C.puddleMargin,
		C.startIslandMinRad, C.startIslandMinRad + C.puddleMargin,
		10, -10, -100)
	return noise.max(ramp1 + basis, minToPreventPuddles)
end

local function makeStartIslandMaxElevation(scale, centerX, centerY, x, y)
	-- Just pushes the starting island max elevation down far away from the center, so that we don't have tiny isles far away from weird noise.
	local d = U.dist(centerX, centerY, x, y) / scale
	return U.ramp(d, C.startIslandMaxRad, C.startIslandAndOffshootsMaxRad, 100, -1000)
end

local function makeIronArcMinElevation(scale, x, y, ironNoise)
	local distToIronArc = var("dist-to-iron-arc")

	-- Minimum elevation to ensure the minimum width of the arc is always reached.
	local arcMinElevation = U.ramp(distToIronArc, C.ironArcMinWidth, C.ironArcMaxWidth, C.ironArcMinWidthHeightMin, -200)

	-- Add noise from the min width to the max width, to make the arc look natural.
	local noiseRamp = U.rampDouble(distToIronArc, C.ironArcMinWidth, C.ironArcMaxWidth, C.ironArcMaxWidth * 2,
		C.arcBlobNoiseAmplitude * 2, -C.arcBlobNoiseAmplitude * 1.5, -200)
	local noiseElevation = ironNoise + noiseRamp

	local overallMinElevation = noise.max(arcMinElevation, noiseElevation)
	return noise.if_else_chain(C.ironArcEnabled, -100, overallMinElevation)
end

local function makeIronBlobMinElevation(scale, x, y, arcBlobNoise)
	local distToBlobCenter = U.distVarXY("start-island-iron-blob-center", x, y) / scale
	local blobMinElevation = U.rampDouble(distToBlobCenter, 0, C.ironBlobMinRad, C.ironBlobMidRad, 10, -80, -200)
	local blobNoise = arcBlobNoise + U.rampDouble(distToBlobCenter, C.ironBlobMinRad, C.ironBlobMidRad, C.ironBlobMaxRad * 2,
		C.arcBlobNoiseAmplitude * 2, -C.arcBlobNoiseAmplitude, -100)
	local overallMinElevation = noise.max(blobMinElevation, blobNoise)
	return noise.if_else_chain(C.ironBlobEnabled, -100, overallMinElevation)
end

local function makeCopperTinArcMinElevation(scale, x, y, arcBlobNoise)
	-- TODO refactor this so that we don't duplicate code from the iron arc.
	local distToCopperTinArc = var("dist-to-copper-tin-arc")

	-- Minimum elevation to ensure the minimum width of the arc is always reached.
	local arcMinElevation = U.ramp(distToCopperTinArc, C.copperTinArcMinWidth, C.copperTinArcMaxWidth, C.copperTinArcMinWidthHeightMin, -200)

	-- Add noise from the min width to the max width, to make the arc look natural.
	local noiseRamp = U.rampDouble(distToCopperTinArc, C.copperTinArcMinWidth, C.copperTinArcMaxWidth, C.copperTinArcMaxWidth * 2,
		C.arcBlobNoiseAmplitude * 2, -C.arcBlobNoiseAmplitude * 1.5, -200)
	local noiseElevation = arcBlobNoise + noiseRamp

	local overallMinElevation = noise.max(arcMinElevation, noiseElevation)
	return noise.if_else_chain(C.copperTinArcEnabled, -100, overallMinElevation)
end

local function makeCopperTinBlobMinElevation(scale, x, y, arcBlobNoise)
	local distToBlobCenter = var("dist-to-copper-tin-patches-center") / scale
	local blobMinElevation = U.rampDouble(distToBlobCenter, 0, C.copperTinBlobMinRad, C.copperTinBlobMidRad, 10, -80, -200)
	local blobNoise = arcBlobNoise + U.rampDouble(distToBlobCenter, C.copperTinBlobMinRad, C.copperTinBlobMidRad, C.copperTinBlobMaxRad * 2,
		C.arcBlobNoiseAmplitude * 2, -C.arcBlobNoiseAmplitude, -100)
	local overallMinElevation = noise.max(blobMinElevation, blobNoise)
	return noise.if_else_chain(C.copperTinBlobEnabled, -100, overallMinElevation)
end

local function getStartIslandAndOffshootsMinElevation(scale, x, y, tile, map)
	local elevation = tne(-100) -- starting elevation

	local startIslandCenterXY = U.varXY("start-island-center")
	local startIslandMinElevation = makeStartIslandMinElevation(scale, startIslandCenterXY[1], startIslandCenterXY[2], x, y)
	elevation = noise.max(startIslandMinElevation, elevation)

	local startIslandMaxElevation = makeStartIslandMaxElevation(scale, startIslandCenterXY[1], startIslandCenterXY[2], x, y)
	elevation = noise.min(startIslandMaxElevation, elevation)

	local arcBlobNoise = U.multiBasisNoise(7, 2, 2, C.arcBlobNoiseScale / scale, C.arcBlobNoiseAmplitude)

	local ironArcMinElevation = makeIronArcMinElevation(scale, x, y, arcBlobNoise)
	local ironBlobMinElevation = makeIronBlobMinElevation(scale, x, y, arcBlobNoise)
	local ironMinElevation = noise.max(ironArcMinElevation, ironBlobMinElevation)
	elevation = noise.max(elevation, ironMinElevation)

	local copperTinArcMinElevation = makeCopperTinArcMinElevation(scale, x, y, arcBlobNoise)
	local copperTinBlobMinElevation = makeCopperTinBlobMinElevation(scale, x, y, arcBlobNoise)
	local copperTinMinElevation = noise.max(copperTinArcMinElevation, copperTinBlobMinElevation)
	elevation = noise.max(elevation, copperTinMinElevation)

	-- Make underwater areas a bit shallower, so there's more shallow water, so it looks more like the rest of the islands.
	elevation = noise.if_else_chain(noise.less_than(-5, elevation), elevation, noise.min(-5, elevation / 6))

	elevation = addMarkerLake(elevation, scale, startIslandCenterXY[1], startIslandCenterXY[2], x, y, 9)
	elevation = addMarkerLake(elevation, scale, 0, 0, x, y, 5)

	local ironCenterXY = U.varXY("start-island-iron-blob-center")
	elevation = addMarkerLake(elevation, scale, ironCenterXY[1], ironCenterXY[2], x, y, 5)
	local copperTinCenterXY = U.varXY("start-island-copper-tin-blob-center")
	elevation = addMarkerLake(elevation, scale, copperTinCenterXY[1], copperTinCenterXY[2], x, y, 5)

	return elevation
end

local function getOtherIslandsMinElevation(scale, x, y, tile, map)
	-- This line creates all of the other islands.
	local elevation = U.multiBasisNoise(8, 2, 2, (1 / 1000) / scale, tne(13)) - 11.8
	-- TODO move these to sliders.
	local startIslandDist = noise.var("dist-to-start-island-rim")

	-- Cut off elevation from other islands close to the starting island.
	local maxElevationToAvoidCenter = U.ramp(startIslandDist,
		C.otherIslandsMinDistFromStartIsland, C.otherIslandsFadeInMidFromStartIsland,
		-100, 100)
	elevation = noise.min(elevation, maxElevationToAvoidCenter)

	-- In addition to this min to hard-cutoff the elevation around the start island, we also add a constant to fade in islands gradually.
	local fadeAdjustment = U.rampDouble(startIslandDist,
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