local noise = require "noise"
local tne = noise.to_noise_expression

local X = {} -- Exported values.

X.terrainScaleSlider = noise.var("control-setting:Desolation-scale:frequency:multiplier")

X.artifactShift = 20000 -- Added to a coordinate, to get rid of fractal symmetry.

------------------------------------------------------------------------
-- Starting island
-- TODO implement sliders for these

X.startIslandMinRad = 300 -- Distance from center of starting island to the closest ocean
X.startIslandMaxRad = 600 -- Distance from center of starting island to the furthest end of the starting island
X.startIslandAndOffshootsMaxRad = 1200 -- Distance from center of starting island to the furthest end of the furthest "offshoot", currently just the iron.
X.puddleMargin = 70 -- Distance before minRad where puddles start to appear.
X.spawnToStartIslandCenter = 200 -- Distance from center of starting island to spawn point.

-- These angles are radians. 0 means east, pi means west or 180 degrees, 0.5 * pi means south or 90 degrees.
-- TODO add sliders for these.
X.pi = 3.1416
X.startIslandAngleToCenterMin = 0.25 * X.pi
X.startIslandAngleToCenterMax = 0.75 * X.pi
X.startIslandIronMaxDeviationAngle = 0.25 * X.pi -- On starting island, iron ore spawns on the other side of the island center, with this big of an angle in either direction.
X.startIslandCopperTinMaxDeviationAngle = 0.2 * X.pi -- On starting island, an arc with copper/tin spawns on the other side of the iron arc, but offset randomly by an angle at most this big, positive or negative.

------------------------------------------------------------------------
-- Other islands, around the starting island
-- These are also used for the starting cold patch.

-- We don't place other islands too close to the starting island.
X.otherIslandsMinDistFromStartIsland = 200
X.otherIslandsFadeInMidFromStartIsland = 300
X.otherIslandsFadeInEndFromStartIsland = 500

X.surroundingIslandsToggle = noise.less_or_equal(1/6, noise.var("control-setting:Desolation-surrounding-islands-toggle:size:multiplier"))

------------------------------------------------------------------------
-- Noise for the starting island's offshoots, consisting of a circular arc and a blob with some ores on it.

-- Rule of thumb: For terrain autocontrols, first slider (labelled "scale") is :frequency:multiplier but inverted. Second slider is :size:multiplier, not inverted.

X.arcBlobNoiseScaleSlider = tne(1) / noise.var("control-setting:Desolation-arcblob-noise:frequency:multiplier")
X.arcBlobNoiseAmplitudeSlider = noise.var("control-setting:Desolation-arcblob-noise:size:multiplier")
X.arcBlobNoiseAmplitude = X.arcBlobNoiseAmplitudeSlider * 15
X.arcBlobNoiseScale = X.arcBlobNoiseScaleSlider * (1/200)

------------------------------------------------------------------------
-- Land arc leading to first iron patch

X.ironArcSizeSlider = tne(1) / noise.var("control-setting:Desolation-iron-arc:frequency:multiplier")
X.ironArcWidthSlider = noise.var("control-setting:Desolation-iron-arc:size:multiplier")
X.ironArcEnabled = noise.less_or_equal(noise.var("control-setting:Desolation-iron-arc:size:multiplier"), 1/6)

X.distCenterToIron = X.ironArcSizeSlider * 1000 -- Distance from center of starting island to the center of the first iron ore patch.
X.distCenterToIronArcStart = X.startIslandMinRad -- Distance from center of starting island to the start of the arc leading to the first iron ore patch.
X.distCenterToIronArcCenter = (X.distCenterToIron + X.distCenterToIronArcStart) / 2 -- Distance from center of starting island to the center of the arc leading to the first iron ore patch.

X.ironArcRad = X.distCenterToIron - X.distCenterToIronArcCenter -- Radius of the circular arc around the center.
X.ironArcMinWidth = X.ironArcWidthSlider * 30 -- Min width of terrain along the circular arc leading to the first iron ore patch.
X.ironArcMaxWidth = X.ironArcWidthSlider * 200
X.ironArcMinWidthHeightMin = 5

------------------------------------------------------------------------
-- Land blob around first iron patch

X.ironBlobSizeSlider = tne(1) / noise.var("control-setting:Desolation-iron-blob:frequency:multiplier")
X.ironBlobEnabled = noise.less_or_equal(noise.var("control-setting:Desolation-iron-blob:size:multiplier"), 1/6)

X.ironBlobMinRad = X.ironBlobSizeSlider * 100 -- Approximate width of terrain around the iron ore patch.
X.ironBlobMidRad = X.ironBlobSizeSlider * 200
X.ironBlobMaxRad = X.ironBlobSizeSlider * 300

------------------------------------------------------------------------
-- Land arc leading to extra copper/tin ore

X.copperTinArcSizeSlider = tne(1) / noise.var("control-setting:Desolation-coppertin-arc:frequency:multiplier")
X.copperTinArcWidthSlider = noise.var("control-setting:Desolation-coppertin-arc:size:multiplier")
X.copperTinArcEnabled = noise.less_or_equal(noise.var("control-setting:Desolation-coppertin-arc:size:multiplier"), 1/6)

X.distCenterToCopperTin = X.copperTinArcSizeSlider * 700 -- Distance from center of starting island to the center of the first copper/tin ore patch.
X.distCenterToCopperTinArcStart = X.startIslandMinRad -- Distance from center of starting island to the start of the arc leading to the first iron ore patch.
X.distCenterToCopperTinArcCenter = (X.distCenterToCopperTin + X.distCenterToCopperTinArcStart) / 2 -- Distance from center of starting island to the center of the arc leading to the first copper/tin ore patch.

X.copperTinArcRad = X.distCenterToCopperTin - X.distCenterToCopperTinArcCenter -- Radius of the circular arc around the center.
X.copperTinArcMinWidth = X.copperTinArcWidthSlider * 20 -- Min width of terrain along the circular arc leading to the first copper/tin ore patch.
X.copperTinArcMaxWidth = X.copperTinArcWidthSlider * 150
X.copperTinArcMinWidthHeightMin = 5

------------------------------------------------------------------------
-- Land blob around extra copper/tin ore

X.copperTinBlobSizeSlider = tne(1) / noise.var("control-setting:Desolation-coppertin-blob:frequency:multiplier")
X.copperTinBlobEnabled = noise.less_or_equal(noise.var("control-setting:Desolation-coppertin-blob:size:multiplier"), 1/6)

X.copperTinBlobMinRad = X.copperTinBlobSizeSlider * 60 -- Approximate width of terrain around the copper/tin ore patch.
X.copperTinBlobMidRad = X.copperTinBlobSizeSlider * 130
X.copperTinBlobMaxRad = X.copperTinBlobSizeSlider * 200

------------------------------------------------------------------------
-- Resource patches

local resourceNoiseScaleSlider = tne(1) / noise.var("control-setting:Desolation-resource-noise:frequency:multiplier")
local resourceNoiseAmplitudeSlider = noise.var("control-setting:Desolation-resource-noise:size:multiplier")

-- Noise amplitude and input scale for starting island's resource patches. Shared between resource probability and richness.
X.resourceNoiseAmplitude = resourceNoiseAmplitudeSlider * 3
X.resourceNoiseInputScale = resourceNoiseScaleSlider * 30

------------------------------------------------------------------------
-- First iron patch

local ironPatchMinRadSlider = tne(1) / noise.var("control-setting:Desolation-iron-patch:frequency:multiplier")
local ironPatchMinMaxSlider = noise.var("control-setting:Desolation-iron-patch:size:multiplier")
local ironCenterWeightSlider = tne(1) / noise.var("control-setting:Desolation-iron-prob-center-weight:frequency:multiplier")

X.startIronPatchMinRad = ironPatchMinRadSlider * 20 -- Approximate radius of the starting iron patch.
X.startIronPatchMidRad = X.startIronPatchMinRad + ironPatchMinMaxSlider * 13
X.startIronPatchMaxRad = X.startIronPatchMinRad + ironPatchMinMaxSlider * 40
X.startIronPatchCenterWeight = ironCenterWeightSlider * 6

X.ironPatchDesiredAmount = 3000000

------------------------------------------------------------------------
-- Distance-minimum resources

-- Map resource name to minimum distance from starting island, and fade-in max distance from starting island.
X.resourceMinDist = {
	["crude-oil"] = {700, 1200, 2000},
	["gold-ore"] = {800, 1400, 2300},
	["uranium-ore"] = {1800, 2400, 3000},
}

return X