local noise = require "noise"
local tne = noise.to_noise_expression
local litexp = noise.literal_expression
local var = noise.var

local resourceAutoplace = require("resource-autoplace")

local U = require("code.data.terrain.util")
local C = require("code.data.terrain.constants")


U.nameNoiseExpr("apply-start-island-resources", noise.less_than(var("dist-to-start-island-rim"), 200 * var("scale")))

------------------------------------------------------------------------
-- Map colors
-- Trying to make the ores more obvious against the white/greyblue background.

data.raw.resource["iron-ore"].map_color = {r=0, g=0.5, b=1}
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
		return U.multiBasisNoise(3, 2, 2, C.resourceNoiseInputScale / scale, C.resourceNoiseAmplitude)
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
			basement_value = tne(C.resourceNoiseAmplitude) * (-2), -- This value is placed wherever we don't have spots. So it should be negative enough to ensure that even with the noise we're still always below zero, so we don't have any ore other than at the spots.
			-- TODO rather have separate noise amplitude and scale for every resource, bc we want it to be smaller for resources that spawn in smaller patches.
			maximum_spot_basement_radius = tne(params.patchRad) * 2, -- This is the radius until we use the basement value. So it should be larger than the patch radius.
			region_size = tne(params.regionSize), -- Probably want to use large regions, because we're using much higher overall terrain scale than in vanilla.

			-- For starting patches.
			minimum_candidate_point_spacing = params.minSpacing,
		},
	}
	return noise.if_else_chain(var("buildable-temperature"), spotNoise, -1000)
end
-- Example patchFavorability:
--   0.5 - uniform
--   Util.ramp(var("elevation"), 30, 100, -10, 10) -- more likely at higher elevations
--   var("elevation") -- more likely at higher elevations
--   var("dist-to-start-island-center")

------------------------------------------------------------------------
-- Iron goes on the starting island (at the end of the land route) and then in patches on other islands.

local ironNoise = makeResourceNoise(slider("iron-ore", "size"))

local startingPatchIronFactor = makeResourceFactorForPatch(
	U.varXY("start-island-iron-patch-center"),
	C.startIronPatchMinRad,
	C.startIronPatchMidRad,
	C.startIronPatchMaxRad,
	C.startIronPatchCenterWeight)
	-- TODO this function should probably take an argument for total amount of ore.

local otherIslandIronFactor = makeSpotNoiseFactor {
	candidateSpotCount = 32,
	density = 0.05,
	patchResourceAmt = 10000, -- TODO take distance into account
	patchRad = slider("iron-ore", "size") * 32, -- TODO take distance from starting island into account -- make patches bigger and richer as we travel further from starting island.
	patchFavorability = var("elevation"), -- TODO take something else into account, eg temperature
	regionSize = 2048,
}

local ironFactor = ironNoise + noise.if_else_chain(var("apply-start-island-resources"), startingPatchIronFactor, otherIslandIronFactor)

data.raw.resource["iron-ore"].autoplace.probability_expression = factorToProb(ironFactor, 0.8)

data.raw.resource["iron-ore"].autoplace.richness_expression = (ironFactor
	* slider("iron-ore", "richness")
	* (C.ironPatchDesiredAmount / 2500)) -- This 2500 number was found by experimenting. Should experiment more, especially since this is with the marker lake.
	-- TODO this uses the same startIronPatchDesiredAmount constant for patches outside the starting island. Maybe adjust, use noise.if_else_chain to choose between a within-island and outside-island multiplier.

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

local startIslandCoalFactor = noise.max(startPatchCoalFactor, secondPatchCoalFactor)

local otherIslandCoalFactor = makeSpotNoiseFactor {
	candidateSpotCount = 32,
	density = 0.05,
	patchResourceAmt = 10000, -- TODO take distance into account
	patchRad = slider("coal", "size") * 32, -- TODO take distance from starting island into account -- make patches bigger and richer as we travel further from starting island.
	patchFavorability = var("elevation"), -- TODO take something else into account, eg temperature
	regionSize = 2048,
}

local coalFactor = coalNoise + noise.if_else_chain(var("apply-start-island-resources"), startIslandCoalFactor, otherIslandCoalFactor)

data.raw.resource["coal"].autoplace.probability_expression = factorToProb(coalFactor, 0.8)
data.raw.resource["coal"].autoplace.richness_expression = (coalFactor
	* slider("coal", "richness")
	* (C.coalPatchDesiredAmount / 2500)) -- This 2500 number was found by experimenting. Should experiment more, especially since this is with the marker lake. TODO
	-- TODO this uses the same startIronPatchDesiredAmount constant for patches outside the starting island. Maybe adjust, use noise.if_else_chain to choose between a within-island and outside-island multiplier.

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

local startIslandCopperFactor = noise.max(startPatchCopperFactor, secondCopperFactor)

local otherIslandCopperFactor = makeSpotNoiseFactor {
	candidateSpotCount = 32,
	density = 0.05,
	patchResourceAmt = 10000, -- TODO take distance into account
	patchRad = slider("copper-ore", "size") * 32,
	patchFavorability = var("temperature"),
	regionSize = 2048,
}

local copperFactor = copperNoise + noise.if_else_chain(var("apply-start-island-resources"), startIslandCopperFactor, otherIslandCopperFactor)

data.raw.resource["copper-ore"].autoplace.probability_expression = factorToProb(copperFactor, 0.8)
data.raw.resource["copper-ore"].autoplace.richness_expression = (copperFactor
	* slider("copper-ore", "richness")
	* (C.secondCopperPatchDesiredAmount / 2500))

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

local startIslandTinFactor = noise.max(startPatchTinFactor, secondTinFactor)

-- TODO implement other-island tin factor

local tinFactor = tinNoise + startIslandTinFactor

data.raw.resource["tin-ore"].autoplace.probability_expression = factorToProb(tinFactor, 0.8)
data.raw.resource["tin-ore"].autoplace.richness_expression = (tinFactor
	* slider("tin-ore", "richness")
	* (C.secondTinPatchDesiredAmount / 2500))

------------------------------------------------------------------------
-- Stone

-- TODO

local stoneFactor = tne(0)

data.raw.resource["stone"].autoplace.probability_expression = factorToProb(stoneFactor, 0.8)
data.raw.resource["stone"].autoplace.richness_expression = (stoneFactor
	* slider("stone", "richness")
	* (C.stonePatchDesiredAmount / 2500))

------------------------------------------------------------------------
-- All resources that fade in at a certain distance from the starting island.

-- TODO I want these to be partially dependent on elevation, so they spawn near the centers of islands, not overlapping the edges of islands.
data.raw.resource["uranium-ore"].autoplace = resourceAutoplace.resource_autoplace_settings {
	name = "uranium-ore",
	order = "c",
	base_density = 0.9,
	base_spots_per_km2 = 1.25,
	has_starting_area_placement = false,
	random_spot_size_minimum = 2,
	random_spot_size_maximum = 4,
	regular_rq_factor_multiplier = 1
}

--log(serpent.block(data.raw.resource["uranium-ore"].autoplace.probability_expression))
local goldOreSpotNoise = makeSpotNoiseFactor {
	candidateSpotCount = 256,
	density = 0.1,
	patchResourceAmt = 10000,
	patchRad = 10,
	patchFavorability = var("dist-to-start-island-center"),
	regionSize = 2048,
}
data.raw.resource["gold-ore"].map_color = {r=1, g=0, b=1}
data.raw.resource["gold-ore"].autoplace.probability_expression = goldOreSpotNoise
data.raw.resource["gold-ore"].autoplace.richness_expression = goldOreSpotNoise * slider("gold-ore", "richness")


------------------------------------------------------------------------

-- TODO handle the starting patch resources with extra patches at edges: copper, tin, coal, stone.
-- TODO handle gas fissures.
-- TODO handle starting-area steam fissures; maybe multiple.
-- TODO handle crude oil.
-- TODO handle uranium and gold.
-- TODO place the gem-bearing rocks from IR3. They should be placed on certain ores. (Called gem-rock-diamond, gem-rock-ruby.)