local noise = require "noise"
local tne = noise.to_noise_expression

local Export = {}

Export.terrainScaleSlider = noise.var("control-setting:Desolation-scale:frequency:multiplier")

Export.artifactShift = 20000 -- Added to a coordinate, to get rid of fractal symmetry.

------------------------------------------------------------------------
-- Starting island
-- TODO implement sliders for these

Export.startIslandMinRad = 300 -- Distance from center of starting island to the closest ocean
Export.startIslandMaxRad = 600 -- Distance from center of starting island to the furthest end of the starting island
Export.startIslandAndOffshootsMaxRad = 1200 -- Distance from center of starting island to the furthest end of the furthest "offshoot", currently just the iron.
Export.puddleMargin = 70 -- Distance before minRad where puddles start to appear.
Export.spawnToStartIslandCenter = 200 -- Distance from center of starting island to spawn point.

-- These angles are radians. 0 means east, pi means west, 0.5 * pi means south.
Export.pi = 3.1416
Export.startIslandAngleToCenterMin = 0.25 * Export.pi
Export.startIslandAngleToCenterMax = 0.75 * Export.pi
Export.startIslandIronMaxDeviationAngle = 0.25 * Export.pi -- On starting island, iron ore spawns on the other side of the island center, with this big of an angle in either direction.
Export.startIslandCopperTinMaxDeviationAngle = 0.2 * Export.pi -- On starting island, an arc with copper/tin spawns on the other side of the iron arc, but offset randomly by an angle at most this big, positive or negative.

------------------------------------------------------------------------
-- Other islands, around the starting island
-- These are also used for the starting cold patch.

-- We don't place other islands too close to the starting island.
Export.otherIslandsMinDistFromStartIsland = 200
Export.otherIslandsFadeInMidFromStartIsland = 300
Export.otherIslandsFadeInEndFromStartIsland = 500

Export.surroundingIslandsToggle = noise.less_or_equal(1/6, noise.var("control-setting:Desolation-surrounding-islands-toggle:size:multiplier"))

------------------------------------------------------------------------
-- Noise for the starting island's offshoots, consisting of a circular arc and a blob with some ores on it.

-- Rule of thumb: For terrain autocontrols, first slider (labelled "scale") is :frequency:multiplier but inverted. Second slider is :size:multiplier, not inverted.

Export.arcBlobNoiseScaleSlider = tne(1) / noise.var("control-setting:Desolation-arcblob-noise:frequency:multiplier")
Export.arcBlobNoiseAmplitudeSlider = noise.var("control-setting:Desolation-arcblob-noise:size:multiplier")
Export.arcBlobNoiseAmplitude = Export.arcBlobNoiseAmplitudeSlider * 15
Export.arcBlobNoiseScale = Export.arcBlobNoiseScaleSlider * (1/200)

------------------------------------------------------------------------
-- Land arc leading to first iron patch

Export.ironArcSizeSlider = tne(1) / noise.var("control-setting:Desolation-iron-arc:frequency:multiplier")
Export.ironArcWidthSlider = noise.var("control-setting:Desolation-iron-arc:size:multiplier")
Export.ironArcEnabled = noise.less_or_equal(noise.var("control-setting:Desolation-iron-arc:size:multiplier"), 1/6)

Export.distCenterToIron = Export.ironArcSizeSlider * 1000 -- Distance from center of starting island to the center of the first iron ore patch.
Export.distCenterToIronArcStart = Export.startIslandMinRad -- Distance from center of starting island to the start of the arc leading to the first iron ore patch.
Export.distCenterToIronArcCenter = (Export.distCenterToIron + Export.distCenterToIronArcStart) / 2 -- Distance from center of starting island to the center of the arc leading to the first iron ore patch.

Export.ironArcRad = Export.distCenterToIron - Export.distCenterToIronArcCenter -- Radius of the circular arc around the center.
Export.ironArcMinWidth = Export.ironArcWidthSlider * 30 -- Min width of terrain along the circular arc leading to the first iron ore patch.
Export.ironArcMaxWidth = Export.ironArcWidthSlider * 200
Export.ironArcMinWidthHeightMin = 5

------------------------------------------------------------------------
-- Land blob around first iron patch

Export.ironBlobSizeSlider = tne(1) / noise.var("control-setting:Desolation-iron-blob:frequency:multiplier")
Export.ironBlobEnabled = noise.less_or_equal(noise.var("control-setting:Desolation-iron-blob:size:multiplier"), 1/6)

Export.ironBlobMinRad = Export.ironBlobSizeSlider * 100 -- Approximate width of terrain around the iron ore patch.
Export.ironBlobMidRad = Export.ironBlobSizeSlider * 200
Export.ironBlobMaxRad = Export.ironBlobSizeSlider * 300

------------------------------------------------------------------------
-- Land arc leading to extra copper/tin ore

Export.copperTinArcSizeSlider = tne(1) / noise.var("control-setting:Desolation-coppertin-arc:frequency:multiplier")
Export.copperTinArcWidthSlider = noise.var("control-setting:Desolation-coppertin-arc:size:multiplier")
Export.copperTinArcEnabled = noise.less_or_equal(noise.var("control-setting:Desolation-coppertin-arc:size:multiplier"), 1/6)

Export.distCenterToCopperTin = Export.copperTinArcSizeSlider * 700 -- Distance from center of starting island to the center of the first copper/tin ore patch.
Export.distCenterToCopperTinArcStart = Export.startIslandMinRad -- Distance from center of starting island to the start of the arc leading to the first iron ore patch.
Export.distCenterToCopperTinArcCenter = (Export.distCenterToCopperTin + Export.distCenterToCopperTinArcStart) / 2 -- Distance from center of starting island to the center of the arc leading to the first copper/tin ore patch.

Export.copperTinArcRad = Export.distCenterToCopperTin - Export.distCenterToCopperTinArcCenter -- Radius of the circular arc around the center.
Export.copperTinArcMinWidth = Export.copperTinArcWidthSlider * 20 -- Min width of terrain along the circular arc leading to the first copper/tin ore patch.
Export.copperTinArcMaxWidth = Export.copperTinArcWidthSlider * 150
Export.copperTinArcMinWidthHeightMin = 5

------------------------------------------------------------------------
-- Land blob around extra copper/tin ore

Export.copperTinBlobSizeSlider = tne(1) / noise.var("control-setting:Desolation-coppertin-blob:frequency:multiplier")
Export.copperTinBlobEnabled = noise.less_or_equal(noise.var("control-setting:Desolation-coppertin-blob:size:multiplier"), 1/6)

Export.copperTinBlobMinRad = Export.copperTinBlobSizeSlider * 60 -- Approximate width of terrain around the copper/tin ore patch.
Export.copperTinBlobMidRad = Export.copperTinBlobSizeSlider * 130
Export.copperTinBlobMaxRad = Export.copperTinBlobSizeSlider * 200

------------------------------------------------------------------------
-- Resource patches

local resourceNoiseScaleSlider = tne(1) / noise.var("control-setting:Desolation-resource-noise:frequency:multiplier")
local resourceNoiseAmplitudeSlider = noise.var("control-setting:Desolation-resource-noise:size:multiplier")

-- Noise amplitude and input scale for starting island's resource patches. Shared between resource probability and richness.
Export.resourceNoiseAmplitude = resourceNoiseAmplitudeSlider * 3
Export.resourceNoiseInputScale = resourceNoiseScaleSlider * 30

------------------------------------------------------------------------
-- First iron patch

local ironPatchMinRadSlider = tne(1) / noise.var("control-setting:Desolation-iron-patch:frequency:multiplier")
local ironPatchMinMaxSlider = noise.var("control-setting:Desolation-iron-patch:size:multiplier")
local ironCenterWeightSlider = tne(1) / noise.var("control-setting:Desolation-iron-prob-center-weight:frequency:multiplier")

Export.startIronPatchMinRad = ironPatchMinRadSlider * 20 -- Approximate radius of the starting iron patch.
Export.startIronPatchMidRad = Export.startIronPatchMinRad + ironPatchMinMaxSlider * 5
Export.startIronPatchMaxRad = Export.startIronPatchMinRad + ironPatchMinMaxSlider * 25
Export.startIronPatchCenterWeight = ironCenterWeightSlider * 6

------------------------------------------------------------------------
-- Distance-minimum resources

-- Map resource name to minimum distance from starting island, and fade-in max distance from starting island.
Export.resourceMinDist = {
	["crude-oil"] = {700, 1200, 2000},
	["gold-ore"] = {800, 1400, 2300},
	["uranium-ore"] = {1800, 2400, 3000},
}

return Export