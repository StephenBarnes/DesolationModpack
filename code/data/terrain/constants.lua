local Settings = require("code.util.settings")
local noise = require "noise"
local tne = noise.to_noise_expression
local var = noise.var

local X = {} -- Exported values.

local function slider(ore, dim)
	if Settings.startupSetting("complex-sliders") then
		return var("control-setting:"..ore..":"..dim..":multiplier")
	else
		return 1
	end
	-- TODO Add a startup setting to toggle between these.
	-- TODO add utility functions so that instead of if_else_chain etc, we can do comptime stuff if the sliders are disabled.
end

X.terrainScaleSlider = slider("Desolation-scale", "frequency")

X.artifactShift = 20000 -- Added to a coordinate, to get rid of fractal symmetry.

X.buildableTiles = {"volcanic-orange-heat-1", "volcanic-orange-heat-2", "vegetation-turquoise-grass-1", "vegetation-turquoise-grass-2"}

X.temperatureThresholdForSnow = 15
X.temperatureBoundaryVolcanic1And2 = 35
X.moistureBoundaryVolcanicAndGrass = 0.3
X.moistureBoundaryGrass1And2 = 5.0
X.stoneTemperatureWidth = 10 -- How big of a range of temperatures stone can be spawned in. It spawns where temp is from the snow threshold to the snow threshold + this width.

------------------------------------------------------------------------
-- Starting island
-- TODO implement sliders for these

X.startIslandMinRad = 300 -- Distance from center of starting island to the closest ocean
X.startIslandMidRad = 450
X.startIslandMaxRad = 600 -- Distance from center of starting island to the furthest end of the starting island
X.startIslandAndOffshootsMaxRad = 1200 -- Distance from center of starting island to the furthest end of the furthest "offshoot", currently just the iron.
X.puddleMargin = 70 -- Distance before minRad where puddles start to appear.
X.spawnToStartIslandCenter = 100 -- Distance from center of starting island to spawn point.

X.startIslandNoiseScaleSlider = tne(1) / slider("Desolation-startisland-noise", "frequency")
X.startIslandNoiseAmplitudeSlider = slider("Desolation-startisland-noise", "size")
X.startIslandNoiseAmplitude = X.startIslandNoiseAmplitudeSlider * 16
X.startIslandNoiseScale = X.startIslandNoiseScaleSlider * (1/130)

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
X.otherIslandsMinDistFromStartIsland = 150
X.otherIslandsFadeInMidFromStartIsland = 250
X.otherIslandsFadeInEndFromStartIsland = 400

X.surroundingIslandsToggle = noise.less_or_equal(1/6, slider("Desolation-surrounding-islands-toggle", "size"))

------------------------------------------------------------------------
-- Noise for the starting island's offshoots, consisting of a circular arc and a blob with some ores on it.

-- Rule of thumb: For terrain autocontrols, first slider (labelled "scale") is :frequency:multiplier but inverted. Second slider is :size:multiplier, not inverted.

X.arcBlobNoiseScaleSlider = tne(1) / slider("Desolation-arcblob-noise", "frequency")
X.arcBlobNoiseAmplitudeSlider = slider("Desolation-arcblob-noise", "size")
X.arcBlobNoiseAmplitude = X.arcBlobNoiseAmplitudeSlider * 22
X.arcBlobNoiseScale = X.arcBlobNoiseScaleSlider * (1/200)

------------------------------------------------------------------------
-- Land arc leading to first iron patch

X.ironArcSizeSlider = tne(1) / slider("Desolation-iron-arc", "frequency")
X.ironArcWidthSlider = slider("Desolation-iron-arc", "size")
X.ironArcEnabled = noise.less_or_equal(slider("Desolation-iron-arc", "size"), 1/6)

X.distCenterToIronBlob = X.ironArcSizeSlider * 850 -- Distance from center of starting island to the center of the iron ore blob (not the center of the patch, which is offset a bit further).
X.distCenterToIronArcStart = X.startIslandMinRad -- Distance from center of starting island to the start of the arc leading to the first iron ore patch.
X.distCenterToIronArcCenter = (X.distCenterToIronBlob + X.distCenterToIronArcStart) / 2 -- Distance from center of starting island to the center of the arc leading to the first iron ore patch.

X.ironArcRad = X.distCenterToIronBlob - X.distCenterToIronArcCenter -- Radius of the circular arc around the center.
X.ironArcMinWidth = X.ironArcWidthSlider * 30 -- Min width of terrain along the circular arc leading to the first iron ore patch.
X.ironArcMaxWidth = X.ironArcWidthSlider * 200
X.ironArcMinWidthHeightMin = 5

------------------------------------------------------------------------
-- Land blob around first iron patch

X.ironBlobSizeSlider = tne(1) / slider("Desolation-iron-blob", "frequency")
X.ironBlobEnabled = noise.less_or_equal(slider("Desolation-iron-blob", "size"), 1/6)

X.ironBlobMinRad = X.ironBlobSizeSlider * 100 -- Approximate width of terrain around the iron ore patch.
X.ironBlobMidRad = X.ironBlobSizeSlider * 200
X.ironBlobMaxRad = X.ironBlobSizeSlider * 300

------------------------------------------------------------------------
-- Land arc leading to extra copper/tin ore

X.copperTinArcSizeSlider = tne(1) / slider("Desolation-coppertin-arc", "frequency")
X.copperTinArcWidthSlider = slider("Desolation-coppertin-arc", "size")
X.copperTinArcEnabled = noise.less_or_equal(slider("Desolation-coppertin-arc", "size"), 1/6)

X.distCenterToCopperTin = X.copperTinArcSizeSlider * 700 -- Distance from center of starting island to the center of the first copper/tin ore patch.
X.distCenterToCopperTinArcStart = X.startIslandMinRad -- Distance from center of starting island to the start of the arc leading to the first iron ore patch.
X.distCenterToCopperTinArcCenter = (X.distCenterToCopperTin + X.distCenterToCopperTinArcStart) / 2 -- Distance from center of starting island to the center of the arc leading to the first copper/tin ore patch.

X.copperTinArcRad = X.distCenterToCopperTin - X.distCenterToCopperTinArcCenter -- Radius of the circular arc around the center.
X.copperTinArcMinWidth = X.copperTinArcWidthSlider * 20 -- Min width of terrain along the circular arc leading to the first copper/tin ore patch.
X.copperTinArcMaxWidth = X.copperTinArcWidthSlider * 150
X.copperTinArcMinWidthHeightMin = 5

------------------------------------------------------------------------
-- Land blob around extra copper/tin ore

X.copperTinBlobSizeSlider = tne(1) / slider("Desolation-coppertin-blob", "frequency")
X.copperTinBlobEnabled = noise.less_or_equal(slider("Desolation-coppertin-blob", "size"), 1/6)

X.copperTinBlobMinRad = X.copperTinBlobSizeSlider * 80 -- Approximate width of terrain around the copper/tin ore patch.
X.copperTinBlobMidRad = X.copperTinBlobSizeSlider * 170
X.copperTinBlobMaxRad = X.copperTinBlobSizeSlider * 260

------------------------------------------------------------------------
-- Resource patches

local resourceNoiseScaleSlider = tne(1) / slider("Desolation-resource-noise", "frequency")
local resourceNoiseAmplitudeSlider = slider("Desolation-resource-noise", "size")

-- Noise amplitude and input scale for starting island's resource patches. Shared between resource probability and richness.
X.resourceNoiseAmplitude = resourceNoiseAmplitudeSlider * 5
X.resourceNoiseInputScale = resourceNoiseScaleSlider * (1/30)

------------------------------------------------------------------------
-- Starting island iron/coal patches at the end of the circular arc

local ironPatchMinRadSlider = tne(1) / slider("Desolation-iron-patch", "frequency")
local ironPatchMinMaxSlider = slider("Desolation-iron-patch", "size")
local ironCenterWeightSlider = tne(1) / slider("Desolation-iron-prob-center-weight", "frequency")

X.startIronPatchMinRad = ironPatchMinRadSlider * 10 -- Approximate radius of the starting iron patch.
X.startIronPatchMidRad = X.startIronPatchMinRad + ironPatchMinMaxSlider * 13
X.startIronPatchMaxRad = X.startIronPatchMinRad + ironPatchMinMaxSlider * 20
X.startIronPatchCenterWeight = ironCenterWeightSlider * 6
X.ironPatchDesiredAmount = 3000000

-- The "second coal" is the patch close to the starting iron patch.
local secondCoalPatchMinRadSlider = tne(1) / slider("Desolation-second-coal-patch", "frequency")
local secondCoalPatchMinMaxSlider = slider("Desolation-second-coal-patch", "size")
local secondCoalCenterWeightSlider = tne(1) / slider("Desolation-second-coal-prob-center-weight", "frequency")

X.secondCoalPatchMinRad = secondCoalPatchMinRadSlider * 8 -- Approximate radius of the starting coal patch.
X.secondCoalPatchMidRad = X.secondCoalPatchMinRad + secondCoalPatchMinMaxSlider * 9
X.secondCoalPatchMaxRad = X.secondCoalPatchMinRad + secondCoalPatchMinMaxSlider * 16
X.secondCoalPatchCenterWeight = secondCoalCenterWeightSlider * 6

X.distIronToSecondCoal = (X.startIronPatchMaxRad + X.secondCoalPatchMaxRad) * 0.7

------------------------------------------------------------------------
-- Starting island copper/tin blob at the end of the circular arc

X.secondCopperPatchMinRad = 10
X.secondCopperPatchMidRad = X.secondCopperPatchMinRad + 6
X.secondCopperPatchMaxRad = X.secondCopperPatchMinRad + 20
X.secondCopperPatchCenterWeight = 6
X.secondCopperPatchDesiredAmount = 1000000

X.secondTinPatchMinRad = 8
X.secondTinPatchMidRad = X.secondTinPatchMinRad + 5
X.secondTinPatchMaxRad = X.secondTinPatchMinRad + 15
X.secondTinPatchCenterWeight = 6
X.secondTinPatchDesiredAmount = 1000000

X.distSecondCopperToTin = (X.secondCopperPatchMaxRad + X.secondTinPatchMaxRad) * 0.7

------------------------------------------------------------------------
-- For the temp, aux, and moisture noise layers (which determine where to place what tiles)
-- For aux and moisture, there's built-in scale sliders, but not amplitude. So I'll use both the built-in slider and a Desolation-aux/moisture slider.

X.temperatureScaleSlider = slider("Desolation-temperature", "frequency")
X.temperatureAmplitudeSlider = slider("Desolation-temperature", "size")
X.temperatureAmplitude = X.temperatureAmplitudeSlider * 45
X.temperatureScale = X.temperatureScaleSlider * (1/600)

X.auxScaleSlider = slider("Desolation-aux", "frequency") * slider("Desolation-aux", "frequency")
X.auxAmplitudeSlider = slider("Desolation-aux", "size")
X.auxAmplitude = X.auxAmplitudeSlider * 0.75
X.auxScale = X.auxScaleSlider * (1/150)
X.auxBias = var("control-setting:aux:bias") - 0.1

X.moistureScaleSlider = slider("Desolation-moisture", "frequency") * slider("Desolation-moisture", "frequency")
X.moistureAmplitudeSlider = slider("Desolation-moisture", "size")
X.moistureAmplitude = X.moistureAmplitudeSlider * 10
X.moistureScale = X.moistureScaleSlider * (1/400)
X.moistureBias = var("control-setting:moisture:bias") * 30

------------------------------------------------------------------------
-- Start island temperature stuff

X.oasisNoiseScaleSlider = slider("Desolation-start-island-oasis-noise", "frequency")
X.oasisNoiseAmplitudeSlider = slider("Desolation-start-island-oasis-noise", "size")
X.oasisNoiseAmplitude = X.oasisNoiseAmplitudeSlider * 12
X.oasisNoiseScale = X.oasisNoiseScaleSlider * (1/300)

local spawnOasisMinRadSlider = tne(1) / slider("Desolation-spawn-oasis-rad", "frequency")
local spawnOasisMinMaxSlider = slider("Desolation-spawn-oasis-rad", "size")

X.spawnOasisMinRad = spawnOasisMinRadSlider * 50
X.spawnOasisMidRad = X.spawnOasisMinRad + spawnOasisMinMaxSlider * 80
X.spawnOasisMaxRad = X.spawnOasisMinRad + spawnOasisMinMaxSlider * 200

local copperTinOasisMinRadSlider = tne(1) / slider("Desolation-coppertin-oasis-rad", "frequency")
local copperTinOasisMinMaxSlider = slider("Desolation-coppertin-oasis-rad", "size")

X.copperTinOasisMinRad = copperTinOasisMinRadSlider * X.distSecondCopperToTin * 1.8
X.copperTinOasisMidRad = X.copperTinOasisMinRad + copperTinOasisMinMaxSlider * X.distSecondCopperToTin * 2.5
X.copperTinOasisMaxRad = X.copperTinOasisMinRad + copperTinOasisMinMaxSlider * X.distSecondCopperToTin * 7

X.ironCoalOasisMinRad = X.distIronToSecondCoal * 1.8
X.ironCoalOasisMidRad = X.ironCoalOasisMinRad + X.distIronToSecondCoal * 2.5
X.ironCoalOasisMaxRad = X.ironCoalOasisMinRad + X.distIronToSecondCoal * 7

-- TODO Get rid of all these extra sliders. I think they might make the map gen slower.

------------------------------------------------------------------------
-- Starting patches

X.distSpawnToStartPatches = (X.spawnOasisMinRad / 2) * 0.5

X.startCoalPatchMinRad = 6.5 * slider("coal", "size")
X.startCoalPatchMidRad = 10 * slider("coal", "size")
X.startCoalPatchMaxRad = 40 * slider("coal", "size")
X.startCoalPatchCenterWeight = 15

X.startCopperPatchMinRad = 5 * slider("copper-ore", "size")
X.startCopperPatchMidRad = 8 * slider("copper-ore", "size")
X.startCopperPatchMaxRad = 32 * slider("copper-ore", "size")
X.startCopperPatchCenterWeight = 15

X.startTinPatchMinRad = 5 * slider("tin-ore", "size")
X.startTinPatchMidRad = 7 * slider("tin-ore", "size")
X.startTinPatchMaxRad = 30 * slider("tin-ore", "size")
X.startTinPatchCenterWeight = 15

------------------------------------------------------------------------

X.goldPatchDesiredAmount = 100000
X.oilPatchDesiredAmount = 100000
X.copperPatchDesiredAmount = 100000
X.tinPatchDesiredAmount = 100000
X.coalPatchDesiredAmount = 100000
-- TODO these should be put into a table indexed by resource name, same as resourceMinDist below.

------------------------------------------------------------------------
-- Distance-minimum resources

-- Map resource name to minimum distance from starting island, and fade-in max distance from starting island.
X.resourceMinDist = {
	["crude-oil"] = {700, 1200, 2000},
	["sour-gas-fissure"] = {700, 1200, 2000},
	["gold-ore"] = {800, 1400, 2300},

	["uranium-ore"] = {1800, 2400, 3000},
	["fossil-gas-fissure"] = {1800, 2400, 3000},
	-- TODO magic gas here
}

return X