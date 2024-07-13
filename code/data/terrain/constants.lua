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
local pi = 3.1416
Export.startIslandAngleToCenterMin = 0.25 * pi
Export.startIslandAngleToCenterMax = 0.75 * pi
Export.startIslandIronMaxDeviationAngle = 0.25 * pi -- On starting island, iron ore spawns on the other side of the island center, with this big of an angle in either direction.

------------------------------------------------------------------------
-- Other islands, around the starting island
-- These are also used for the starting cold patch.

-- We don't place other islands too close to the center of the starting island.
Export.otherIslandsMinDistFromStartIslandCenter = 600
Export.otherIslandsFadeInMidFromStartIslandCenter = 900
Export.otherIslandsFadeInEndFromStartIslandCenter = 1200

-- We don't place other islands too close to the center of the arc that leads to the iron ore.
Export.otherIslandsMinDistFromIronArcCenter = 550
Export.otherIslandsFadeInMidFromIronArcCenter = 800
Export.otherIslandsFadeInEndFromIronArcCenter = 1100

------------------------------------------------------------------------
-- Iron arc and blob noise

-- Rule of thumb: For terrain autocontrols, first slider (labelled "scale") is :frequency:multiplier but inverted. Second slider is :size:multiplier, not inverted.

Export.ironArcBlobNoiseScaleSlider = tne(1) / noise.var("control-setting:Desolation-iron-arcblob-noise:frequency:multiplier")
Export.ironArcBlobNoiseAmplitudeSlider = noise.var("control-setting:Desolation-iron-arcblob-noise:size:multiplier")
Export.ironArcBlobNoiseAmplitude = Export.ironArcBlobNoiseAmplitudeSlider * 15
Export.ironArcBlobNoiseScale = Export.ironArcBlobNoiseScaleSlider * (1/200)

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
-- First iron patch

local ironPatchMinRadSlider = tne(1) / noise.var("control-setting:Desolation-iron-patch:frequency:multiplier")
local ironPatchMinMaxSlider = noise.var("control-setting:Desolation-iron-patch:size:multiplier")
local ironProbNoiseScaleSlider = tne(1) / noise.var("control-setting:Desolation-iron-prob-noise:frequency:multiplier")
local ironProbNoiseAmplitudeSlider = noise.var("control-setting:Desolation-iron-prob-noise:size:multiplier")
local ironRichnessNoiseScaleSlider = tne(1) / noise.var("control-setting:Desolation-iron-richness-noise:frequency:multiplier")
local ironRichnessNoiseAmplitudeSlider = noise.var("control-setting:Desolation-iron-richness-noise:size:multiplier")
local ironCenterWeightSlider = tne(1) / noise.var("control-setting:Desolation-iron-prob-center-weight:frequency:multiplier")

Export.startIronPatchMinRad = ironPatchMinRadSlider * 20 -- Approximate radius of the starting iron patch.
Export.startIronPatchMidRad = Export.startIronPatchMinRad + ironPatchMinMaxSlider * 5
Export.startIronPatchMaxRad = Export.startIronPatchMinRad + ironPatchMinMaxSlider * 25
Export.startIronPatchProbNoiseAmplitude = ironProbNoiseAmplitudeSlider * 3 -- Noise amplitude for the probability of each tile in the starting iron patch.
Export.startIronPatchProbNoiseInputScale = ironProbNoiseScaleSlider * 30 -- Noise input scale for the probability of each tile in the starting iron patch.
Export.startIronPatchRichnessNoiseAmplitude = ironRichnessNoiseAmplitudeSlider * 1000
Export.startIronPatchRichnessNoiseInputScale = ironRichnessNoiseScaleSlider * 40
Export.startIronPatchCenterWeight = ironCenterWeightSlider * 6

return Export