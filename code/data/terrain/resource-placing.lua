local noise = require "noise"
local tne = noise.to_noise_expression
local litexp = noise.literal_expression

local resourceAutoplace = require("resource-autoplace")

local Util = require("code.data.terrain.util")
local C = require("code.data.terrain.constants")


------------------------------------------------------------------------
-- Map colors
-- Trying to make the ores more obvious against the white/greyblue background.

data.raw.resource["iron-ore"].map_color = {r=0, g=0.5, b=1}
--data.raw.resource["tin-ore"].map_color = {r=0, g=0, b=0.7}


------------------------------------------------------------------------
-- Common functions for resources.

local function slider(ore, dim)
	return noise.var("control-setting:"..ore..":"..dim..":multiplier")
end

local function makeResourceNoise()
	-- Returns a multi-basis noise function to be used for a specific resource. Probably don't share between resources.
	return noise.define_noise_function(function(x, y, tile, map)
		local scale = 1 / (C.terrainScaleSlider * map.segmentation_multiplier)
		return Util.multiBasisNoise(2, 2, 2, 1 / (scale * C.resourceNoiseInputScale), C.resourceNoiseAmplitude)
	end)
end

local function makeResourceFactorForPatch(patchPosFunc, minRad, midRad, maxRad, centerWeight)
	-- Makes a resource factor, which is a value used for both probability and richness of the given resource.
	-- This is for a patch at a specific position. So use `noise.max` to combine with other factors.
	-- Argument `patchPosFunc` is a function that returns the position of the patch, given scale.
	-- This doesn't have noise added yet. So make noise with makeResourceNoise(), and add it to these.
	-- From this factor, obtain probability by clamping it to [0, 1] and then setting it to 0 below floor prob.
	return noise.define_noise_function(function(x, y, tile, map)
		local scale = 1 / (C.terrainScaleSlider * map.segmentation_multiplier)
		local pos = patchPosFunc(scale)
		local distFromPatch = Util.dist(pos[1], pos[2], x, y) / scale
		return Util.rampDouble(distFromPatch,
			minRad, midRad, maxRad,
			centerWeight, 0, -100)
	end)
end

local function factorToProb(factor, floorProb)
	-- Given a resource factor, return a probability of resource. Probability lower than floorProb is set to 0.
	return noise.if_else_chain(noise.less_than(factor, floorProb), 0, noise.clamp(factor, 0, 1))
end

local zeroOnStartIsland = noise.if_else_chain(Util.withinStartingIsland, 0, 10000)
-- Noise expression that's 0 on the starting island, high number everywhere else.
-- Should be min'd with the resource factor that spawns stuff outside the starting island, then max'd with the resource factors that spawn patches inside the starting island.
-- Actually, rather than using this, just use a noise.if_else_chain.

local function makeSpotNoiseFactor(params)
	return noise.define_noise_function(function(x, y, tile, map)
		local scale = 1 / (C.terrainScaleSlider * map.segmentation_multiplier)
		return tne {
			type = "function-application",
			function_name = "spot-noise",
			arguments = {
				x = x / scale,
				y = y / scale,
				seed0 = noise.var("map_seed"),
				seed1 = tne(Util.getNextSeed1()),

				candidate_spot_count = tne(params.candidateSpotCount), -- Maybe more points will make the favorability bias work better? Default is 21.
				density_expression = litexp(params.density), -- Makes more patches, it seems.
				spot_quantity_expression = litexp(params.patchResourceAmt), -- Amount of resource per patch, from totalling up all the tiles.
				spot_radius_expression = litexp(params.patchRad), -- Radius of each resource patch, in tiles.
				spot_favorability_expression = litexp(params.patchFavorability),
				basement_value = tne(C.resourceNoiseAmplitude) * (-2), -- This value is placed wherever we don't have spots. So it should be negative enough to ensure that even with the noise we're still always below zero, so we don't have any ore other than at the spots.
				maximum_spot_basement_radius = tne(params.patchRad) * 2, -- This is the radius until we use the basement value. So it should be larger than the patch radius.
				region_size = tne(params.regionSize), -- Probably want to use large regions, because we're using much higher overall terrain scale than in vanilla.
			},
		}
	end)
end
-- Example patchFavorability:
--   0.5 - uniform
--   Util.ramp(noise.var("elevation"), 30, 100, -10, 10) -- more likely at higher elevations
--   noise.var("elevation") -- more likely at higher elevations
--   Util.minDistToStartIsland

------------------------------------------------------------------------
-- Iron goes on the starting island (at the end of the land route) and then in patches on other islands.

local ironNoise = makeResourceNoise()

local startingPatchIronFactor = ironNoise + makeResourceFactorForPatch(
	Util.getStartIslandIronCenter,
	C.startIronPatchMinRad,
	C.startIronPatchMidRad,
	C.startIronPatchMaxRad,
	C.startIronPatchCenterWeight)

local otherIslandIronFactor = ironNoise + makeSpotNoiseFactor {
	candidateSpotCount = 32,
	density = 0.05,
	patchResourceAmt = 10000, -- TODO take distance into account
	patchRad = slider("iron-ore", "size") * 32, -- TODO take distance into account
	patchFavorability = noise.var("elevation"), -- TODO take something else into account, eg temperature
	regionSize = 2048,
}

local ironFactor = noise.if_else_chain(Util.withinStartingIsland, startingPatchIronFactor, otherIslandIronFactor)

data.raw.resource["iron-ore"].autoplace.probability_expression = factorToProb(ironFactor, 0.8)
-- For some reason these always have the same radius. TODO fix. Even this doesn't work:
--data.raw.resource["iron-ore"].autoplace.probability_expression = noise.if_else_chain(Util.withinStartingIsland, factorToProb(ironFactor, 0.8),
--noise.less_than(0, ironFactor), 1, 0)

data.raw.resource["iron-ore"].autoplace.richness_expression = (ironFactor
	* slider("iron-ore", "richness")
	* (C.ironPatchDesiredAmount / 2500)) -- This 2500 number was found by experimenting. Should experiment more, especially since this is with the marker lake.
	-- TODO this uses the same startIronPatchDesiredAmount constant for patches outside the starting island. Maybe adjust, use noise.if_else_chain to choose between a within-island and outside-island multiplier.

------------------------------------------------------------------------
-- Coal on starting island, near the starting iron patch.


------------------------------------------------------------------------
-- Copper and tin on starting island, at the end of the copper+tin circular arc.

-- TODO

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
	patchFavorability = Util.minDistToStartIsland,
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