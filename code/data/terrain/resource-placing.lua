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

------------------------------------------------------------------------
-- The resource-type layers.
-- It's positive for the one resource group (eg coal+tin), and negative for the other (eg copper+iron).
-- We start by deciding a sorta-random vector, by picking random x and y. Then rotate by 90 degrees to get the other axis for that resource layer.
-- Rotating by 90 degrees means swapping x and y, and then negating one of them.

-- We use resource A for copper+iron, and coal+tin (inverted).
-- We use resource B for gold+fossilgas, and oil+sourgas (inverted).
-- We use resource C for uranium, and magic-fissure (inverted).
-- We don't use any of these quadrant restrictions for polluted steam.

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
	-- params.shouldScale determines whether we scale by map scale.
	--   This should be disabled for things like the dot noise, bc we want the radius to be 1 tile, not 1 tile * scale.
	local scale
	if params.shouldScale == nil or params.shouldScale then
		scale = var("scale")
	else
		scale = 1
	end

	local minSpacing
	if params.minSpacing ~= nil then
		minSpacing = tne(params.minSpacing)
	else
		minSpacing = nil
	end

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

-- We make a "dot factor" shared between crude oil and all gas fissures.
-- This noise layer is multiplied with separate noise layers that create the bigger areas that contain oil or gas fissures, etc.
-- We share this between them to improve performance, since it's unnecessary to re-do this for each one.
local dotFactor = makeSpotNoiseFactor {
	candidateSpotCount = 128,
	density = 128, -- number in each region
	patchResourceAmt = 100000,
	patchRad = 1,
	patchFavorability = 1,
	regionSize = 128,
	minSpacing = 5,
	shouldScale = false, -- No scaling, bc eg at 300% scale we don't want patch radius to be 3 tiles.
}
dotFactor = noise.clamp(dotFactor, 0, 1)

local function setResourceAutoplace(params)
	-- Creates the autoplace rules for a resource.
	-- params.id is the name of the resource entity, such as "iron-ore"
	local id = params.id or G.die("setResourceAutoplace: id is required")
	-- params.sliderName is the name of the slider with size/richness/frequency
	local sliderName = params.sliderName or id
	-- params.startPatches is a list of patch tables on the start island, each patch table being: {{xCenter, yCenter}, minRad, midRad, maxRad, centerWeight}
	local startPatches = params.startPatches or {}
	-- params.outsideFade is {minDist, midDist, maxDist} for fading in patches outside the starting region.
	local outsideFade = params.outsideFade
	-- params.dots is a bool for whether the resource spawns in patches of size 1 that should be close to each other but with a min distance. Used for crude oil and fissures.
	local dots = params.dots
	-- params.outsideDensity is the number of resource patches per region, outside the starting island.
	local outsideDensity = params.outsideDensity or 1.0
	-- params.outsideRad is the radius of resource patches outside the starting island.
	local outsideRad = params.outsideRad or 16
	-- params.resourceType is the resource type, such as "A" or "B"
	local resourceType = params.resourceType
	-- params.resourceTypeInverted is a bool for whether the resource type is inverted.
	local resourceTypeInverted = params.resourceTypeInverted
	-- params.desiredAmount is the desired amount of the resource.
	local desiredAmount = params.desiredAmount or 100000
	-- params.order is placement order.
	local order = params.order or ""
	-- params.extraCondition is an extra condition required to place the resource in a spot, eg stone requires temperature to be in a certain band so it spawns on the edges of oases.
	local extraCondition = params.extraCondition
	-- params.normalSpawnInStartIsland is a bool for whether the resource should spawn normally in the starting island, using the "outside" settings.
	local normalSpawnInStartIsland = params.normalSpawnInStartIsland

	-- TODO actually each patch table should specify the amount in that patch, and then have a separate outsidePatchAmount that is the per-patch amount for patches outside starting island.

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

	local possibleRegions = extraCondition or tne(1)

	-- The "outsideFadeFactor" is used to enforce the restriction that some resources only spawn far from the start island.
	-- The outsideFadeFactor is 0 close to start island, then fades to 1 as we move further away. For some resources, it's just 1 everywhere.
	if outsideFade ~= nil then
		local outsideFadeFactor = U.rampDouble(
			var("dist-to-start-island-rim"),
			outsideFade[1], outsideFade[2], outsideFade[3],
			0, 0.5, 1
		)
		possibleRegions = possibleRegions * outsideFadeFactor
	end

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
	local resourceFactor
	if normalSpawnInStartIsland then
		if #startPatches > 0 then
			resourceFactor = noise.max(combinedStartPatchFactor, outsideFactor)
		else
			resourceFactor = outsideFactor
		end
	else
		resourceFactor = noise.if_else_chain(var("apply-start-island-resources"), combinedStartPatchFactor, outsideFactor)
	end

	if dots then
		-- For dot-placed resources, we first place the big spots as above. Then we make a second layer of spot noise, with 1 tile patches. Then multiply them together.
		resourceFactor = resourceFactor * dotFactor
		-- Increase radius that gets aggregated together in the tooltip on the map.
		data.raw.resource[id].resource_patch_search_radius = params.outsideRad * 8 -- must be a number, not a noise-var, so we can't make it depend on map scale.
	end

	data.raw.resource[id].autoplace = {
		probability_expression = factorToProb(resourceFactor, 0.8),
		richness_expression = resourceFactor * (desiredAmount / 2500), -- TODO this should probably take rad into account
		tile_restriction = C.buildableTiles,
		order = order,
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
	outsideDensity = 2,
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
	outsideDensity = 2,
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
	outsideDensity = 2,
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
	outsideDensity = 2,
	desiredAmount = C.tinPatchDesiredAmount,
	resourceType = "A",
	resourceTypeInverted = true,
}

------------------------------------------------------------------------
-- Stone

-- Try to place stone in areas that are on the edges of buildable oases.
local stoneTempBand = U.ramp(var("temperature"),
	C.temperatureThresholdForSnow, C.temperatureThresholdForSnow + C.stoneTemperatureWidth,
	1, 0)

setResourceAutoplace {
	id = "stone",
	order = "zzz", -- Place it last, so other resources can be placed on top of it.
	outsideDensity = 0.3,
	outsideRad = 60,
	desiredAmount = C.stonePatchDesiredAmount,
	extraCondition = stoneTempBand,
	normalSpawnInStartIsland = true,
}

------------------------------------------------------------------------
-- Uranium

setResourceAutoplace {
	id = "uranium-ore",
	outsideDensity = 1,
	outsideRad = 16,
	desiredAmount = 100000,
	resourceType = "C",
	outsideFade = C.resourceMinDist["uranium-ore"],
}

------------------------------------------------------------------------
-- Gold

setResourceAutoplace {
	id = "gold-ore",
	outsideDensity = 1,
	outsideRad = 16,
	desiredAmount = 100000,
	resourceType = "B",
	outsideFade = C.resourceMinDist["gold-ore"],
}

------------------------------------------------------------------------
-- Crude Oil

-- So, to make oil patches, I tried a strategy of using 2 layers of spot noise.
--   Big spot noise creates oil locations, then smaller spot noise creates individual tiles inside that first layer.
--   However, that seems to be extremely slow. Probably because I was using first layer as favorability.
-- Also tried using multibasis noise for the first layer, then generate spot noise on that layer. This works, but the spots aren't clustered as much as I want them to be.
-- So instead, I'm now generating 2 spot noise layers, and multiplying them together.

setResourceAutoplace {
	id = "crude-oil",
	outsideRad = 24, -- This is the size of the big region that contains the smaller spots.
	outsideDensity = 0.3,
	desiredAmount = 1e9, -- Must be very high, because it's a percentage yield.
	dots = true,
	outsideFade = C.resourceMinDist["crude-oil"],
	resourceType = "B",
	resourceTypeInverted = true,
}

------------------------------------------------------------------------
-- Sour gas

setResourceAutoplace {
	id = "sulphur-gas-fissure",
	outsideRad = 24,
	outsideDensity = 0.25,
	desiredAmount = 1e9,
	dots = true,
	resourceType = "B",
	resourceTypeInverted = true,
	outsideFade = C.resourceMinDist["sulphur-gas-fissure"],
}

------------------------------------------------------------------------
-- Natural gas fissures

-- We don't autoplace any natural gas fissures. Instead we autoplace fossil gas fissures.
-- Fossil gas can be easily processed into natgas, or natgas+nitrogen+helium. IR3 doesn't autoplace natural gas fissures anyway.
-- In the real world, "fossil gas" is just another name for natural gas. I think IR3 calls it "fossil gas" just to differentiate from the purer natural gas.
data.raw.resource["natural-gas-fissure"].autoplace = nil

------------------------------------------------------------------------
-- Polluted steam

setResourceAutoplace {
	id = "dirty-steam-fissure",
	outsideRad = 12,
	outsideDensity = 0.2, -- Lower density than other fissures, because it's not restricted to a resource type / quadrants.
	desiredAmount = 1e9,
	dots = true,
	normalSpawnInStartIsland = true, -- So can spawn on starting island.
}

------------------------------------------------------------------------
-- Clean steam
-- IR3 places one near player spawn point automatically.

-- TODO does IR3 place these anywhere except at spawn? If not, maybe remove this.
setResourceAutoplace {
	id = "steam-fissure",
	outsideRad = 12,
	outsideDensity = 0.2, -- Lower density than other fissures, because it's not restricted to a resource type / quadrants.
	desiredAmount = 5e8,
	dots = true,
}

------------------------------------------------------------------------
-- Fossil gas

setResourceAutoplace {
	id = "fossil-gas-fissure",
	outsideRad = 24,
	outsideDensity = 0.4,
	desiredAmount = 1e9,
	resourceType = "B",
	dots = true,
	outsideFade = C.resourceMinDist["fossil-gas-fissure"],
}

------------------------------------------------------------------------
-- Magic gas

setResourceAutoplace {
	id = "immateria-fissure",
	outsideRad = 24,
	outsideDensity = 0.4,
	desiredAmount = 1e9,
	resourceType = "C",
	resourceTypeInverted = true,
	dots = true,
	outsideFade = C.resourceMinDist["immateria-fissure"],
}

------------------------------------------------------------------------
-- Enemy bases

-- TODO

------------------------------------------------------------------------
-- Trees

-- TODO

------------------------------------------------------------------------
-- Gem-bearing rocks
-- (Called gem-rock-diamond, gem-rock-ruby.)
-- Maybe place them on certain ores, like IR3 does. Or maybe just place them randomly on frigid terrain.
-- TODO Maybe spawn them only close to enemy bases!

-- TODO

