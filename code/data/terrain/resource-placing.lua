local noise = require "noise"
local tne = noise.to_noise_expression
local litexp = noise.literal_expression
local var = noise.var
local lt = noise.less_than

local resourceAutoplace = require("resource-autoplace")

local U = require("code.data.terrain.util")
local C = require("code.data.terrain.constants")
local G = require("code.util.general")


U.nameNoiseExpr("apply-start-island-resources", noise.less_than(var("dist-to-start-island-rim"), 200 * var("scale")))

local function autoplaceFor(resourceName)
	return data.raw.resource[resourceName].autoplace
end


------------------------------------------------------------------------
-- The resource-type layers.
-- It's positive for the one resource group (eg coal+tin), and negative for the other (eg copper+iron).
-- We start by deciding a sorta-random vector, by picking random x and y. Then rotate by 90 degrees to get the other axis for that resource layer.
-- Rotating by 90 degrees means swapping x and y, and then negating one of them.

-- We use resource A for coal+tin and copper+iron.
-- We use resource B for gold+fossilgas and oil+sourgas.
-- We use resource C for uranium and magic-fissure.

local function makeResourceType()
	local x = U.mapRandBetween(-1, 1)
	local y = U.mapRandBetween(-1, 1)
	local factor1 = var("x") * x + var("y") * y
	local factor2 = var("y") * x - var("x") * y
	return factor1 * factor2
end

local resourceA = makeResourceType()
U.nameNoiseExpr("Desolation-resource-A-ramp01",
	U.ramp(resourceA, -40, 40, 0, 1))

local resourceB = makeResourceType()
U.nameNoiseExpr("Desolation-resource-B-ramp01",
	U.ramp(resourceB, -80, 80, 0, 1))

local resourceC = makeResourceType()
U.nameNoiseExpr("Desolation-resource-C-ramp01",
	U.ramp(resourceC, -200, 200, 0, 1))

------------------------------------------------------------------------
-- Map colors

--data.raw.resource["iron-ore"].map_color = {r=0, g=0.5, b=1}
--data.raw.resource["tin-ore"].map_color = {r=0, g=0, b=0.7}
--data.raw.resource["gold-ore"].map_color = {r=1, g=0, b=1}

------------------------------------------------------------------------
-- Common functions for resources.

local function slider(ore, dim)
	return var("control-setting:"..ore..":"..dim..":multiplier")
end

local function makeResourceNoise(scaleMult)
	-- Returns a multi-basis noise function to be used for a specific resource. Probably don't share between resources.
	-- `scaleMult` should be the size slider for the resource; it's here so that ore patches maintain roughly similar shape as that slider is adjusted.
	local scale = scaleMult * var("scale")
	return U.multiBasisNoise(4, 2, 2, C.resourceNoiseInputScale / scale, C.resourceNoiseAmplitude)
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
	local minSpacing
	if params.minSpacing ~= nil then minSpacing = tne(params.minSpacing) else minSpacing = nil end
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
			minimum_candidate_point_spacing = minSpacing,
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

local function setResourceAutoplace(params)
	-- Creates the autoplace rules for a resource.
	-- @param params.id is the name of the resource entity, such as "iron-ore"
	-- @param params.sliderName is the name of the slider with size/richness/frequency
	-- @param params.startPatches is a list of patch tables on the start island, each patch table being: {{xCenter, yCenter}, minRad, midRad, maxRad, centerWeight}
	-- @param params.outsideFade is {minDist, midDist, maxDist} for fading in patches outside the starting region.
	-- @param params.fissureLike is a bool for whether the resource is fissure-like, ie spawns in patches of size 1 that should be close to each other but with a min distance.
	-- @param params.outsideDensity is the density of resource patches outside the starting island.
	-- @param params.outsideRad is the radius of resource patches outside the starting island.
	-- @param params.resourceType is the resource type, such as "A" or "B"
	-- @param params.resourceTypeInverted is a bool for whether the resource type is inverted.
	-- @param params.desiredAmount is the desired amount of the resource.

	-- TODO actually each patch table should specify the amount in that patch, and then have a separate outsidePatchAmount that is the per-patch amount for patches outside starting island.

	local id = params.id or G.die("setResourceAutoplace: id is required")
	local sliderName = params.sliderName or id
	local startPatches = params.startPatches or {}
	local outsideFade = params.outsideFade
	local fissureLike = params.fissureLike
	local outsideDensity = params.outsideDensity or 0.2
	local outsideRad = params.outsideRad or 16
	local resourceType = params.resourceType
	local resourceTypeInverted = params.resourceTypeInverted
	local desiredAmount = params.desiredAmount or 10000

	local sizeSlider = slider(sliderName, "size")
	local richnessSlider = slider(sliderName, "richness")
	local freqSlider = slider(sliderName, "frequency")

	outsideRad = outsideRad * sizeSlider
	desiredAmount = desiredAmount * richnessSlider
	outsideDensity = outsideDensity * freqSlider

	local resourceNoise = makeResourceNoise(sizeSlider)

	-- Create a factor for the patches on the starting island.
	local combinedStartPatchFactor
	if #startPatches > 0 then
		local startPatchFactors = {}
		for i, patch in pairs(startPatches) do
			local center, minRad, midRad, maxRad, centerWeight = table.unpack(patch)
			startPatchFactors[i] = makeResourceFactorForPatch(
				center,
				minRad,
				midRad,
				maxRad,
				centerWeight
			)
		end
		combinedStartPatchFactor = resourceNoise + noise.max(table.unpack(startPatchFactors))
	else
		combinedStartPatchFactor = tne(0)
	end

	-- The "outsideFadeFactor" is used to enforce the restriction that some resources only spawn far from the start island.
	-- The outsideFadeFactor is 0 close to start island, then fades to 1 as we move further away. For some resources, it's just 1 everywhere.
	local outsideFadeFactor
	if outsideFade ~= nil then
		outsideFadeFactor = U.rampDouble(
			var("dist-to-start-island-rim"),
			outsideFade[1], outsideFade[2], outsideFade[3],
			0, 0.5, 1
		)
	else
		outsideFadeFactor = tne(1)
	end
	local possibleRegions = outsideFadeFactor

	-- Apply resource type filters, to make it only spawn in two opposite quadrants of the map.
	if resourceType ~= nil then
		local resourceTypeVar = var("Desolation-resource-"..resourceType.."-ramp01")
		if resourceTypeInverted then
			resourceTypeVar = 1 - resourceTypeVar
		end
		possibleRegions = possibleRegions * resourceTypeVar
	end

	-- Also confine to buildable regions, so it doesn't place the patches in cold regions or water, have them disappear, and then think that's enough.
	-- But, this adds significant lag, perhaps because it makes resource placement depend on elevation.
	-- So instead of this, let's just triple the number of spots placed.
	-- I've tested with this line and without it, and it's definitely a significant performance hit.
	--possibleRegions = possibleRegions * var("buildable")

	-- Cache as procedure, might improve performance
	possibleRegions = noise.delimit_procedure(possibleRegions)

	-- The "outsideFactor" determines resource placement outside the starting island.
	local outsideFactor = resourceNoise + makeSpotNoiseFactor {
		candidateSpotCount = 32,
		density = outsideDensity,
		patchResourceAmt = 10000, -- TODO should this be desiredAmount? or account for that below when setting richness.
			-- TODO take distance into account
		patchRad = outsideRad, -- TODO take distance from starting island into account -- make patches bigger and richer as we travel further from starting island.
		patchFavorability = possibleRegions, -- TODO take something else into account, eg temperature
		regionSize = 2048,
	}
	outsideFactor = outsideFactor * possibleRegions

	-- The "resourceFactor" determines all resource placement. It contains the combined start patch factor, and the outside factor.
	local resourceFactor = noise.if_else_chain(var("apply-start-island-resources"), combinedStartPatchFactor, outsideFactor)

	if fissureLike then
		-- TODO
		assert(false)
		resourceFactor = makeSpotNoiseFactor {
			candidateSpotCount = 128,
			density = freqSlider,
			patchResourceAmt = 1,
			patchRad = 1,
			patchFavorability = resourceFactor,
			regionSize = 256,
			minSpacing = 3,
		}
	end

	data.raw.resource[id].autoplace = {
		probability_expression = factorToProb(resourceFactor, 0.8),
		richness_expression = resourceFactor * (desiredAmount / 2500), -- TODO this should probably take rad into account
		tile_restriction = C.buildableTiles,
	}
end

------------------------------------------------------------------------
-- Iron goes on the starting island (at the end of the land route) and then in patches on other islands.

setResourceAutoplace {
	id = "iron-ore",
	startPatches = {
		{
			U.varXY("start-island-iron-patch-center"),
			C.startIronPatchMinRad, C.startIronPatchMidRad, C.startIronPatchMaxRad,
			C.startIronPatchCenterWeight
		},
	},
	outsideDensity = 0.3,
	desiredAmount = C.ironPatchDesiredAmount,
	resourceType = "A",
}

------------------------------------------------------------------------
-- Coal

setResourceAutoplace {
	id = "coal",
	startPatches = {
		{ -- Patch in starting oasis
			U.varXY("start-coal-patch-center"),
			C.startCoalPatchMinRad, C.startCoalPatchMidRad, C.startCoalPatchMaxRad,
			C.startCoalPatchCenterWeight
		},
		{ -- Patch at the end of the land route
			U.varXY("start-island-second-coal-center"),
			C.secondCoalPatchMinRad, C.secondCoalPatchMidRad, C.secondCoalPatchMaxRad,
			C.secondCoalPatchCenterWeight
		},
	},
	outsideDensity = 0.3,
	desiredAmount = C.coalPatchDesiredAmount,
	resourceType = "A",
	resourceTypeInverted = true,
}

------------------------------------------------------------------------
-- Copper

setResourceAutoplace {
	id = "copper-ore",
	startPatches = {
		{ -- Patch in starting oasis
			U.varXY("start-copper-patch-center"),
			C.startCopperPatchMinRad, C.startCopperPatchMidRad, C.startCopperPatchMaxRad,
			C.startCopperPatchCenterWeight
		},
		{ -- Patch at the end of the land route
			U.varXY("start-island-second-copper-patch-center"),
			C.secondCopperPatchMinRad, C.secondCopperPatchMidRad, C.secondCopperPatchMaxRad,
			C.secondCopperPatchCenterWeight
		},
	},
	outsideDensity = 0.3,
	desiredAmount = C.copperPatchDesiredAmount,
	resourceType = "A",
}

------------------------------------------------------------------------
-- Tin

setResourceAutoplace {
	id = "tin-ore",
	startPatches = {
		{ -- Patch in starting oasis
			U.varXY("start-tin-patch-center"),
			C.startTinPatchMinRad, C.startTinPatchMidRad, C.startTinPatchMaxRad,
			C.startTinPatchCenterWeight
		},
		{ -- Patch at the end of the land route
			U.varXY("start-island-second-tin-patch-center"),
			C.secondTinPatchMinRad, C.secondTinPatchMidRad, C.secondTinPatchMaxRad,
			C.secondTinPatchCenterWeight
		},
	},
	outsideDensity = 0.3,
	desiredAmount = C.tinPatchDesiredAmount,
	resourceType = "A",
	resourceTypeInverted = true,
}

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
-- Gold

local goldNoise = makeResourceNoise(slider("gold-ore", "size"))

local goldRamp = U.rampDouble(var("dist-to-start-island-rim"),
	C.resourceMinDist["gold-ore"][1], C.resourceMinDist["gold-ore"][2], C.resourceMinDist["gold-ore"][3],
	0, 0.5, 1)

local goldOreSpotNoise = makeSpotNoiseFactor {
	candidateSpotCount = 128,
	density = 0.1,
	patchResourceAmt = 10000,
	patchRad = slider("gold-ore", "size") * 7,
	patchFavorability = goldRamp,
	regionSize = 2048,
}

-- Make gold ore factor
local goldFactor = goldRamp * (goldOreSpotNoise + goldNoise) * var("Desolation-resource-B-ramp01")

autoplaceFor("gold-ore").probability_expression = factorToProb(goldFactor, 0.8)
autoplaceFor("gold-ore").richness_expression = (goldFactor
	* slider("gold-ore", "richness")
	* (C.goldPatchDesiredAmount / 2500))
autoplaceFor("gold-ore").tile_restriction = C.buildableTiles

------------------------------------------------------------------------
-- Crude Oil

-- So, I tried a strategy of generating big patches with spot-noise, and then generating individual tiles within those patches using a 2nd layer of spot-noise.
-- However, that seems to be extremely slow.
-- So instead, use multibasis noise for the first layer, then generate spot noise on that layer.

local oilRamp = U.rampDouble(var("dist-to-start-island-rim"),
	C.resourceMinDist["crude-oil"][1], C.resourceMinDist["crude-oil"][2], C.resourceMinDist["crude-oil"][3],
	0, 0.5, 1)

--local oilPossibleAreas = makeSpotNoiseFactor {
--	candidateSpotCount = 128,
--	density = 0.5,
--	patchResourceAmt = 10000,
--	patchRad = slider("crude-oil", "size") * 20,
--	patchFavorability = oilRamp,
--	regionSize = 512,
--}
--oilPossibleAreas = noise.clamp(oilPossibleAreas, 0, 1)

local oilPossibleAreas = U.multiBasisNoise(2, 2, 2, (slider("crude-oil", "size") / 1000) / var("scale"), 5) - 4
oilPossibleAreas = noise.clamp(oilPossibleAreas, 0, 1)
oilPossibleAreas = oilRamp * oilPossibleAreas * (1 - var("Desolation-resource-B-ramp01"))

local oilSpotNoise = makeSpotNoiseFactor {
	candidateSpotCount = 128,
	density = 1.0,
	patchResourceAmt = 10000,
	patchRad = 1,
	patchFavorability = oilPossibleAreas,
	regionSize = 256,
	minSpacing = 3,
}

local oilFactor = oilSpotNoise * oilPossibleAreas

data.raw.resource["crude-oil"].autoplace = {
	probability_expression = oilFactor,
	richness_expression = (oilFactor
		* slider("crude-oil", "richness")
		* (C.oilPatchDesiredAmount / 2500)),
	tile_restriction = C.buildableTiles,
}

------------------------------------------------------------------------
-- Fossil gas

-- TODO

------------------------------------------------------------------------

-- TODO handle gas fissures.
-- TODO handle starting-area steam fissures; maybe multiple.
-- TODO handle crude oil.
-- TODO handle uranium and gold.
-- TODO place the gem-bearing rocks from IR3. They should be placed on certain ores. (Called gem-rock-diamond, gem-rock-ruby.)


-- TODO all of these should be refactored a lot, so that we instead just have tables with the "specification" of a given resource.
-- Specification should include a list of patch centers and radii, and then the min distance for patch generation, and some details of patch shape/size.
-- Then we just use the same code to generate all resources.