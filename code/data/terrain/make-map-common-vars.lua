-- This file decides things that are relevant to both elevation and resource placement.
-- Generally we want to register some noise vars here, and then use those in both elevation.lua and resource-placing.lua, etc.

local noise = require "noise"
local tne = noise.to_noise_expression
local var = noise.var

local C = require("code.data.terrain.constants")
local U = require("code.data.terrain.util")

------------------------------------------------------------------------

U.nameNoiseExpr("scale",
	noise.define_noise_function(function(x, y, tile, map)
		return 1 / (C.terrainScaleSlider * map.segmentation_multiplier)
	end))

------------------------------------------------------------------------

U.nameNoiseExpr("spawn-to-start-island-center-angle",
	U.mapRandBetween(C.startIslandAngleToCenterMin, C.startIslandAngleToCenterMax))

U.nameNoiseExprXY("start-island-center",
	U.moveInDirScaled(tne(0), tne(0), var("spawn-to-start-island-center-angle"), C.spawnToStartIslandCenter))

U.nameNoiseExpr("dist-to-start-island-center",
	U.distVarXY("start-island-center", var("x") * var("scale"), var("y") * var("scale")))

------------------------------------------------------------------------

U.nameNoiseExpr("center-to-iron-blob-angle",
	var("spawn-to-start-island-center-angle") -- Use this angle, so it's on the other side of the island from where player spawns.
	+ U.mapRandBetween(C.startIslandIronMaxDeviationAngle, -C.startIslandIronMaxDeviationAngle))

U.nameNoiseExpr("dist-to-iron-arc",
	noise.define_noise_function(function(x, y, tile, map)
		local scale = 1 / (C.terrainScaleSlider * map.segmentation_multiplier)
		local angleCenterToBlob = var("center-to-iron-blob-angle")

		local arcStartXY = U.moveVarInDir("start-island-center", angleCenterToBlob, C.distCenterToIronArcStart * scale)
		local arcCenterXY = U.moveVarInDir("start-island-center", angleCenterToBlob, C.distCenterToIronArcCenter * scale)
		local arcEndXY = U.moveVarInDir("start-island-center", angleCenterToBlob, C.distCenterToIronBlob * scale)

		-- If the angle of the point to the arc center is within the arc, then distance to the arc depends on distance to the center.
		-- Otherwise, it's the min of the distances to the start and end.

		local distToArcStart = U.dist(x, y, arcStartXY[1], arcStartXY[2])
		local distToArcCenter = U.dist(x, y, arcCenterXY[1], arcCenterXY[2])
		local distToArcEnd = U.dist(x, y, arcEndXY[1], arcEndXY[2])

		local endpointDist = noise.min(distToArcStart, distToArcEnd)
		local arcBodyDist = noise.absolute_value(distToArcCenter - C.ironArcRad * scale)

		--local angleToArcCenter = noise.atan2(arcCenter[2] - y, arcCenter[1] - x)
		--local angleWithinArg = noise.less_than(angleToArcCenter, 3.1416 / 2)

		-- Instead of checking the angle, since these are always half-circles, we can just check what side the point is on from the islandCenter-ironCenter line.
		-- This is easier than checking angle, since angle could be negative or go over 2pi if we adjust it, etc.

		local dx1 = x - arcEndXY[1]
		local dy1 = y - arcEndXY[2]
		local dx2 = x - var("start-island-center-x")
		local dy2 = y - var("start-island-center-y")
		local whichSide = noise.less_than(0.5, U.mapRandBetween(0, 1))
		local isRightSide = noise.less_than(dx1 * dy2, dx2 * dy1)
		local isLeftSide = 1 - isRightSide
		local isCorrectSide = noise.if_else_chain(whichSide, isRightSide, isLeftSide)

		return noise.if_else_chain(isCorrectSide, arcBodyDist, endpointDist) / scale
	end))

U.nameNoiseExprXY("start-island-iron-blob-center",
	-- Note this is the center of the blob, not the center of the actual ore patch.
	U.moveVarInDirScaled("start-island-center", var("center-to-iron-blob-angle"), C.distCenterToIronBlob))
U.nameNoiseExprXY("start-island-iron-arc-center",
	U.moveVarInDirScaled("start-island-center", var("center-to-iron-blob-angle"), C.distCenterToIronArcCenter))

U.nameNoiseExpr("iron-blob-to-iron-patch-angle",
	U.mapRandBetween(0, 2 * C.pi))

local ironCoalShiftScale = 30
local ironCoalShift = { -- Just to make it a bit more random.
	U.mapRandBetween(-ironCoalShiftScale, ironCoalShiftScale),
	U.mapRandBetween(-ironCoalShiftScale, ironCoalShiftScale),
}

local ironCoalPatchesCenter = U.shiftVarScaled("start-island-iron-blob-center", ironCoalShift)

U.nameNoiseExprXY("start-island-iron-patch-center",
	U.moveInDirScaled(ironCoalPatchesCenter[1], ironCoalPatchesCenter[2], var("iron-blob-to-iron-patch-angle"),
		(C.distIronToSecondCoal / 2)))
U.nameNoiseExprXY("start-island-second-coal-center",
	U.moveInDirScaled(ironCoalPatchesCenter[1], ironCoalPatchesCenter[2], var("iron-blob-to-iron-patch-angle") + C.pi,
		(C.distIronToSecondCoal / 2)))

U.nameNoiseExpr("dist-to-iron-coal-center",
	U.dist(ironCoalPatchesCenter[1], ironCoalPatchesCenter[2], var("x"), var("y")))

------------------------------------------------------------------------

U.nameNoiseExpr("center-to-copper-tin-blob-angle",
	-- Angle is center-to-iron-blob angle, plus pi (to flip it), plus some random angle.
	var("center-to-iron-blob-angle")
	+ C.pi
	+ U.mapRandBetween(C.startIslandCopperTinMaxDeviationAngle, -C.startIslandCopperTinMaxDeviationAngle))

U.nameNoiseExpr("dist-to-copper-tin-arc",
	noise.define_noise_function(function(x, y, tile, map)
		-- TODO refactor this so that we don't duplicate code from the iron arc.
		local scale = 1 / (C.terrainScaleSlider * map.segmentation_multiplier)
		local angleCenterToBlob = var("center-to-copper-tin-blob-angle")

		local arcStartXY = U.moveVarInDir("start-island-center", angleCenterToBlob, C.distCenterToCopperTinArcStart * scale)
		local arcCenterXY = U.moveVarInDir("start-island-center", angleCenterToBlob, C.distCenterToCopperTinArcCenter * scale)
		local arcEndXY = U.moveVarInDir("start-island-center", angleCenterToBlob, C.distCenterToCopperTin * scale)

		local distToArcStart = U.dist(x, y, arcStartXY[1], arcStartXY[2])
		local distToArcCenter = U.dist(x, y, arcCenterXY[1], arcCenterXY[2])
		local distToArcEnd = U.dist(x, y, arcEndXY[1], arcEndXY[2])

		local endpointDist = noise.min(distToArcStart, distToArcEnd)
		local arcBodyDist = noise.absolute_value(distToArcCenter - C.copperTinArcRad * scale)

		local dx1 = x - arcEndXY[1]
		local dy1 = y - arcEndXY[2]
		local dx2 = x - var("start-island-center-x")
		local dy2 = y - var("start-island-center-y")
		local whichSide = noise.less_than(0.5, U.mapRandBetween(0, 1))
		local isRightSide = noise.less_than(dx1 * dy2, dx2 * dy1)
		local isLeftSide = 1 - isRightSide
		local isCorrectSide = noise.if_else_chain(whichSide, isRightSide, isLeftSide)

		return noise.if_else_chain(isCorrectSide, arcBodyDist, endpointDist) / scale
	end))

U.nameNoiseExprXY("start-island-copper-tin-blob-center",
	U.moveVarInDirScaled("start-island-center", var("center-to-copper-tin-blob-angle"), C.distCenterToCopperTin))

U.nameNoiseExprXY("start-island-copper-tin-arc-center",
	U.moveVarInDirScaled("start-island-center", var("center-to-copper-tin-blob-angle"), C.distCenterToCopperTinArcCenter))

U.nameNoiseExpr("copper-tin-blob-to-copper-patch-angle",
	U.mapRandBetween(0, 2 * C.pi))

local copperTinShiftScale = 15
local copperTinShift = {
	U.mapRandBetween(-copperTinShiftScale, copperTinShiftScale),
	U.mapRandBetween(-copperTinShiftScale, copperTinShiftScale),
}
local copperTinPatchesCenter = U.shiftVarScaled("start-island-copper-tin-blob-center", copperTinShift)
U.nameNoiseExprXY("start-island-second-copper-patch-center",
		U.moveInDirScaled(copperTinPatchesCenter[1], copperTinPatchesCenter[2], var("copper-tin-blob-to-copper-patch-angle"),
			(C.distSecondCopperToTin / 2)))
U.nameNoiseExprXY("start-island-second-tin-patch-center",
		U.moveInDirScaled(copperTinPatchesCenter[1], copperTinPatchesCenter[2], var("copper-tin-blob-to-copper-patch-angle") + C.pi,
			(C.distSecondCopperToTin / 2)))

U.nameNoiseExpr("dist-to-copper-tin-patches-center",
	U.dist(copperTinPatchesCenter[1], copperTinPatchesCenter[2], var("x"), var("y")))

------------------------------------------------------------------------

U.nameNoiseExpr("dist-to-start-island-rim",
	noise.define_noise_function(function(x, y, tile, map)
		local distFromStartIslandCenter = U.distVarXY("start-island-center", x, y)
		local distFromIronArcCenter = U.distVarXY("start-island-iron-arc-center", x, y)
		local distFromCopperTinArcCenter = U.distVarXY("start-island-copper-tin-arc-center", x, y)
		return noise.min(
			distFromStartIslandCenter - C.startIslandMaxRad * var("scale"),
			distFromIronArcCenter - C.distCenterToIronArcCenter * var("scale"),
			distFromCopperTinArcCenter - C.distCenterToCopperTinArcCenter * var("scale")) / var("scale")
	end))

------------------------------------------------------------------------
-- Starting ore patches.

local startPatchesShiftX = {-12, 8}
local startPatchesShiftY = {-28, -20} -- Bias to shift north, so you can build southward.
local startPatchesShift = {
	U.mapRandBetween(startPatchesShiftX[1], startPatchesShiftX[2]),
	U.mapRandBetween(startPatchesShiftY[1], startPatchesShiftY[2]),
}
local startPatchesCenter = U.shiftScaled({0, 0}, startPatchesShift)

U.nameNoiseExpr("start-patch-angle",
	U.mapRandBetween(0, 2 * C.pi))
U.nameNoiseExpr("start-patch-rot-each",
	(2 * C.pi / 3) + U.mapRandBetween(-0.5, 0.5))

U.nameNoiseExprXY("start-coal-patch-center",
	U.moveInDirScaled(startPatchesCenter[1], startPatchesCenter[2], var("start-patch-angle"), C.distSpawnToStartPatches))
U.nameNoiseExprXY("start-copper-patch-center",
	U.moveInDirScaled(startPatchesCenter[1], startPatchesCenter[2], var("start-patch-angle") + var("start-patch-rot-each"), C.distSpawnToStartPatches))
U.nameNoiseExprXY("start-tin-patch-center",
	U.moveInDirScaled(startPatchesCenter[1], startPatchesCenter[2], var("start-patch-angle") + (var("start-patch-rot-each") * 2), C.distSpawnToStartPatches))
--U.nameNoiseExpr("dist-to-start-coal-patch",
--	U.distVarXY("start-coal-patch-center", var("x"), var("y")))