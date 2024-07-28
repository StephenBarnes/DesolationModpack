local noise = require "noise"
local tne = noise.to_noise_expression
local litexp = noise.literal_expression
local var = noise.var
local lt = noise.less_than

local resourceAutoplace = require("resource-autoplace")

local U = require("code.data.terrain.util")
local C = require("code.data.terrain.constants")


U.nameNoiseExpr("apply-start-island-resources", noise.less_than(var("dist-to-start-island-rim"), 200 * var("scale")))

local function autoplaceFor(resourceName)
	return data.raw.resource[resourceName].autoplace
end


------------------------------------------------------------------------
-- The resource-type layers.
-- It's positive for the one type, and negative for the other.
-- We start by deciding a sorta-random vector, by picking random x and y. Then rotate by 90 degrees to get the other axis for that resource layer.
-- Rotating by 90 degrees means swapping x and y, and then negating one of them.

-- We use Desolation-resource-type-A for coal+tin and copper+iron.
-- We use Desolation-resource-type-B for gold and oil.
-- We use Desolation-resource-type-C for uranium and magic-fissure.

U.nameNoiseExprXY("Desolation-resource-vector-A", {
	U.mapRandBetween(-1, 1, var("map_seed"), 87),
	U.mapRandBetween(-1, 1, var("map_seed"), 10203)
})
U.nameNoiseExpr("Desolation-resource-A1",
	var("x") * var("Desolation-resource-vector-A-x") + var("y") * var("Desolation-resource-vector-A-y"))
U.nameNoiseExpr("Desolation-resource-A2",
	var("y") * var("Desolation-resource-vector-A-x") - var("x") * var("Desolation-resource-vector-A-y"))
U.nameNoiseExpr("Desolation-resource-type-A",
	var("Desolation-resource-A1") * var("Desolation-resource-A2"))
U.nameNoiseExpr("Desolation-resource-type-A-ramp01",
	U.ramp(var("Desolation-resource-type-A"), -40, 40, 0, 1))

------------------------------------------------------------------------
-- Map colors

--data.raw.resource["iron-ore"].map_color = {r=0, g=0.5, b=1}
--data.raw.resource["tin-ore"].map_color = {r=0, g=0, b=0.7}

------------------------------------------------------------------------
-- Common functions for resources.

local function slider(ore, dim)
	return var("control-setting:"..ore..":"..dim..":multiplier")
end

local function makeResourceNoise(scaleMult)
	-- Returns a multi-basis noise function to be used for a specific resource. Probably don't share between resources.
	-- `scaleMult` should be the size slider for the resource; it's here so that ore patches maintain roughly similar shape as that slider is adjusted.
	return noise.define_noise_function(function(x, y, tile, map)
		local scale = scaleMult / (C.terrainScaleSlider * map.segmentation_multiplier)
		return U.multiBasisNoise(4, 2, 2, C.resourceNoiseInputScale / scale, C.resourceNoiseAmplitude)
	end)
end

local function makeResourceFactorForPatch(patchPos, minRad, midRad, maxRad, centerWeight)
	-- Makes a resource factor, which is a value used for both probability and richness of the given resource.
	-- This is for a patch at a specific position. So use `noise.max` to combine with other factors.
	-- This doesn't have noise added yet. So make noise with makeResourceNoise(), and add it to these.
	-- From this factor, obtain probability by clamping it to [0, 1] and then setting it to 0 below floor prob.
	return noise.define_noise_function(function(x, y, tile, map)
		local scale = 1 / (C.terrainScaleSlider * map.segmentation_multiplier)
		local distFromPatch = U.dist(patchPos[1], patchPos[2], x, y) / scale
		return U.rampDouble(distFromPatch,
			minRad, midRad, maxRad,
			centerWeight, 0, -100)
	end)
end

local function factorToProb(factor, floorProb)
	-- Given a resource factor, return a probability of resource. Probability lower than floorProb is set to 0.
	return noise.if_else_chain(noise.less_than(factor, floorProb), 0, noise.clamp(factor, 0, 1))
end

local function makeSpotNoiseFactor(params)
	local scale = var("scale")
	local spotNoise = tne {
		type = "function-application",
		function_name = "spot-noise",
		arguments = {
			x = var("x") / scale,
			y = var("y") / scale,
			seed0 = var("map_seed"),
			seed1 = tne(U.getNextSeed1()),

			candidate_spot_count = tne(params.candidateSpotCount), -- Maybe more points will make the favorability bias work better? Default is 21.
			density_expression = litexp(params.density), -- Makes more patches, it seems.
			spot_quantity_expression = litexp(params.patchResourceAmt), -- Amount of resource per patch, from totalling up all the tiles.
			spot_radius_expression = litexp(params.patchRad), -- Radius of each resource patch, in tiles.
			spot_favorability_expression = litexp(params.patchFavorability),
			basement_value = tne(C.resourceNoiseAmplitude) * (-3), -- This value is placed wherever we don't have spots. So it should be negative enough to ensure that even with the noise we're still always below zero, so we don't have any ore other than at the spots.
			-- TODO rather have separate noise amplitude and scale for every resource, bc we want it to be smaller for resources that spawn in smaller patches.
			maximum_spot_basement_radius = tne(params.patchRad) * 2, -- This is the radius until we use the basement value. So it should be larger than the patch radius.
			region_size = tne(params.regionSize), -- Probably want to use large regions, because we're using much higher overall terrain scale than in vanilla.

			-- For starting patches.
			minimum_candidate_point_spacing = params.minSpacing,
		},
	}
	--return noise.if_else_chain(var("buildable-temperature"), spotNoise, -1000)
		-- We could use this, but it's easier to just set the autoplace.tile_restriction field to restrict the resource to buildable tiles.
	return spotNoise
end
-- Example patchFavorability:
--   0.5 - uniform
--   Util.ramp(var("elevation"), 30, 100, -10, 10) -- more likely at higher elevations
--   var("elevation") -- more likely at higher elevations
--   var("dist-to-start-island-center")

------------------------------------------------------------------------
-- Iron goes on the starting island (at the end of the land route) and then in patches on other islands.

local ironNoise = makeResourceNoise(slider("iron-ore", "size"))

local startingPatchIronFactor = ironNoise + makeResourceFactorForPatch(
	U.varXY("start-island-iron-patch-center"),
	C.startIronPatchMinRad,
	C.startIronPatchMidRad,
	C.startIronPatchMaxRad,
	C.startIronPatchCenterWeight)
	-- TODO this function should probably take an argument for total amount of ore.

local otherIslandIronFactor = ironNoise + makeSpotNoiseFactor {
	candidateSpotCount = 32,
	density = 0.3,
	patchResourceAmt = 10000, -- TODO take distance into account
	patchRad = slider("iron-ore", "size") * 16, -- TODO take distance from starting island into account -- make patches bigger and richer as we travel further from starting island.
	patchFavorability = var("elevation"), -- TODO take something else into account, eg temperature
	regionSize = 2048,
}
otherIslandIronFactor = otherIslandIronFactor * var("Desolation-resource-type-A-ramp01")

local ironFactor = noise.if_else_chain(var("apply-start-island-resources"), startingPatchIronFactor, otherIslandIronFactor)

autoplaceFor("iron-ore").probability_expression = factorToProb(ironFactor, 0.8)
autoplaceFor("iron-ore").richness_expression = (ironFactor
	* slider("iron-ore", "richness")
	* (C.ironPatchDesiredAmount / 2500)) -- This 2500 number was found by experimenting. Should experiment more, especially since this is with the marker lake.
	-- TODO this uses the same startIronPatchDesiredAmount constant for patches outside the starting island. Maybe adjust, use noise.if_else_chain to choose between a within-island and outside-island multiplier.
autoplaceFor("iron-ore").tile_restriction = C.buildableTiles

------------------------------------------------------------------------
-- Coal

local coalNoise = makeResourceNoise(slider("coal", "size"))

-- Create starting patch factor -- attempt using spot noise.
--local coalRad = slider("coal", "size") * 16 -- TODO move to constants
--local startPatchMaxRad = coalRad -- TODO move to constants, take max of multiple
--local startPatchCoalFactor = startingPatchSpotNoiseFactor {
--	patchResourceAmt = 1000,
--	patchRad = coalRad / var("scale"),
--	patchFavorability = -var("distance") + noise.random(0.5),
--	--patchFavorability = 1,
--	regionSize = C.spawnPatchesDist / var("scale"),
--	minSpacing = startPatchMaxRad * 3 / var("scale"),
--}
--startPatchCoalFactor = noise.if_else_chain(noise.less_than(var("distance"), C.spawnPatchesDist / var("scale")), startPatchCoalFactor, -1000)

-- Create starting patch factor -- attempt using a var for center and dist.
local startPatchCoalFactor = makeResourceFactorForPatch(
	U.varXY("start-coal-patch-center"),
	C.startCoalPatchMinRad,
	C.startCoalPatchMidRad,
	C.startCoalPatchMaxRad,
	C.startCoalPatchCenterWeight)

-- The "second patch" is the patch close to the starting iron patch.
local secondPatchCoalFactor = makeResourceFactorForPatch(
	U.varXY("start-island-second-coal-center"),
	C.secondCoalPatchMinRad,
	C.secondCoalPatchMidRad,
	C.secondCoalPatchMaxRad,
	C.secondCoalPatchCenterWeight)

local startIslandCoalFactor = coalNoise + noise.max(startPatchCoalFactor, secondPatchCoalFactor)

local otherIslandCoalFactor = coalNoise + makeSpotNoiseFactor {
	candidateSpotCount = 32,
	density = 0.3,
	patchResourceAmt = 10000, -- TODO take distance into account
	patchRad = slider("coal", "size") * 16, -- TODO take distance from starting island into account -- make patches bigger and richer as we travel further from starting island.
	patchFavorability = var("elevation"), -- TODO take something else into account, eg temperature
	regionSize = 2048,
}
otherIslandCoalFactor = otherIslandCoalFactor * (1 - var("Desolation-resource-type-A-ramp01"))

local coalFactor = noise.if_else_chain(var("apply-start-island-resources"), startIslandCoalFactor, otherIslandCoalFactor)

autoplaceFor("coal").probability_expression = factorToProb(coalFactor, 0.8)
autoplaceFor("coal").richness_expression = (coalFactor
	* slider("coal", "richness")
	* (C.coalPatchDesiredAmount / 2500)) -- This 2500 number was found by experimenting. Should experiment more, especially since this is with the marker lake. TODO
	-- TODO this uses the same startIronPatchDesiredAmount constant for patches outside the starting island. Maybe adjust, use noise.if_else_chain to choose between a within-island and outside-island multiplier.
autoplaceFor("coal").tile_restriction = C.buildableTiles

------------------------------------------------------------------------
-- Copper

local copperNoise = makeResourceNoise(slider("copper-ore", "size"))

local startPatchCopperFactor = makeResourceFactorForPatch(
	U.varXY("start-copper-patch-center"),
	C.startCopperPatchMinRad,
	C.startCopperPatchMidRad,
	C.startCopperPatchMaxRad,
	C.startCopperPatchCenterWeight)

local secondCopperFactor = makeResourceFactorForPatch(
	U.varXY("start-island-second-copper-patch-center"),
	C.secondCopperPatchMinRad,
	C.secondCopperPatchMidRad,
	C.secondCopperPatchMaxRad,
	C.secondCopperPatchCenterWeight)
	-- TODO this function should probably take an argument for total amount of ore.
	-- TODO abstract this stuff so we rather have a "patch" object with min/mid/max rad and center weight.

local startIslandCopperFactor = copperNoise + noise.max(startPatchCopperFactor, secondCopperFactor)

local otherIslandCopperFactor = copperNoise + makeSpotNoiseFactor {
	candidateSpotCount = 32,
	density = 0.3,
	patchResourceAmt = 10000, -- TODO take distance into account
	patchRad = slider("copper-ore", "size") * 16,
	patchFavorability = var("temperature"),
	regionSize = 2048,
}
otherIslandCopperFactor = otherIslandCopperFactor * var("Desolation-resource-type-A-ramp01")

local copperFactor = noise.if_else_chain(var("apply-start-island-resources"), startIslandCopperFactor, otherIslandCopperFactor)

autoplaceFor("copper-ore").probability_expression = factorToProb(copperFactor, 0.8)
autoplaceFor("copper-ore").richness_expression = (copperFactor
	* slider("copper-ore", "richness")
	* (C.secondCopperPatchDesiredAmount / 2500))
autoplaceFor("copper-ore").tile_restriction = C.buildableTiles

------------------------------------------------------------------------
-- Tin

local tinNoise = makeResourceNoise(slider("tin-ore", "size"))

local startPatchTinFactor = makeResourceFactorForPatch(
	U.varXY("start-tin-patch-center"),
	C.startTinPatchMinRad,
	C.startTinPatchMidRad,
	C.startTinPatchMaxRad,
	C.startTinPatchCenterWeight)

local secondTinFactor = makeResourceFactorForPatch(
	U.varXY("start-island-second-tin-patch-center"),
	C.secondTinPatchMinRad,
	C.secondTinPatchMidRad,
	C.secondTinPatchMaxRad,
	C.secondTinPatchCenterWeight)
	-- TODO this function should probably take an argument for total amount of ore.

local startIslandTinFactor = tinNoise + noise.max(startPatchTinFactor, secondTinFactor)

local otherIslandTinFactor = tinNoise + makeSpotNoiseFactor {
	candidateSpotCount = 32,
	density = 0.3,
	patchResourceAmt = 10000, -- TODO take distance into account
	patchRad = slider("tin-ore", "size") * 16,
	patchFavorability = var("temperature"),
	regionSize = 2048,
}
otherIslandTinFactor = otherIslandTinFactor * (1 - var("Desolation-resource-type-A-ramp01"))

local tinFactor = noise.if_else_chain(var("apply-start-island-resources"), startIslandTinFactor, otherIslandTinFactor)

autoplaceFor("tin-ore").probability_expression = factorToProb(tinFactor, 0.8)
autoplaceFor("tin-ore").richness_expression = (tinFactor
	* slider("tin-ore", "richness")
	* (C.secondTinPatchDesiredAmount / 2500))
autoplaceFor("tin-ore").tile_restriction = C.buildableTiles

------------------------------------------------------------------------
-- Stone

local stoneNoise = makeResourceNoise(slider("stone", "size"))

-- Try to place stone in areas that are on the edges of buildable oases.
local stoneTempBand = U.ramp(var("temperature"),
	C.temperatureThresholdForSnow, C.temperatureThresholdForSnow + C.stoneTemperatureWidth,
	1, 0)

local stoneFactor = stoneNoise + makeSpotNoiseFactor {
	candidateSpotCount = 128,
	density = 0.5,
	patchResourceAmt = 10000, -- TODO take distance into account
	patchRad = slider("stone", "size") * 32,
	patchFavorability = stoneTempBand,
	regionSize = 256,
}
stoneFactor = stoneFactor * stoneTempBand

autoplaceFor("stone").probability_expression = factorToProb(stoneFactor, 0.8)
autoplaceFor("stone").richness_expression = (stoneFactor
	* slider("stone", "richness")
	* (C.stonePatchDesiredAmount / 2500))
autoplaceFor("stone").order = "zzz" -- Place it last, so other resources can be placed on top of it.
autoplaceFor("stone").tile_restriction = C.buildableTiles

------------------------------------------------------------------------
-- Uranium

-- TODO I want these to be partially dependent on elevation, so they spawn near the centers of islands, not overlapping the edges of islands.
--autoplaceFor("uranium-ore") = resourceAutoplace.resource_autoplace_settings {
--	name = "uranium-ore",
--	order = "c",
--	base_density = 0.9,
--	base_spots_per_km2 = 1.25,
--	has_starting_area_placement = false,
--	random_spot_size_minimum = 2,
--	random_spot_size_maximum = 4,
--	regular_rq_factor_multiplier = 1
--}

------------------------------------------------------------------------
-- Gold

--log(serpent.block(autoplaceFor("uranium-ore").probability_expression))
local goldOreSpotNoise = makeSpotNoiseFactor {
	candidateSpotCount = 256,
	density = 0.1,
	patchResourceAmt = 10000,
	patchRad = 10,
	patchFavorability = var("dist-to-start-island-center"),
	regionSize = 2048,
}
data.raw.resource["gold-ore"].map_color = {r=1, g=0, b=1}
autoplaceFor("gold-ore").probability_expression = goldOreSpotNoise
autoplaceFor("gold-ore").richness_expression = goldOreSpotNoise * slider("gold-ore", "richness")
autoplaceFor("gold-ore").tile_restriction = C.buildableTiles


------------------------------------------------------------------------

-- TODO handle the starting patch resources with extra patches at edges: copper, tin, coal, stone.
-- TODO handle gas fissures.
-- TODO handle starting-area steam fissures; maybe multiple.
-- TODO handle crude oil.
-- TODO handle uranium and gold.
-- TODO place the gem-bearing rocks from IR3. They should be placed on certain ores. (Called gem-rock-diamond, gem-rock-ruby.)