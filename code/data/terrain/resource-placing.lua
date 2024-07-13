local noise = require "noise"
local tne = noise.to_noise_expression

local resourceAutoplace = require("resource-autoplace")

local Util = require("code.data.terrain.util")
local C = require("code.data.terrain.constants")


------------------------------------------------------------------------
-- Map colors
-- Trying to make the ores more obvious against the white/greyblue background.

data.raw.resource["iron-ore"].map_color = {r=0, g=0.5, b=1}
--data.raw.resource["tin-ore"].map_color = {r=0, g=0, b=0.7}

-- TODO give walls a darker color.

------------------------------------------------------------------------
-- Resources

-- Define a single basis noise function shared between all resources, since they don't overlap anyway.
local resourceNoise = noise.define_noise_function(function(x, y, tile, map)
	local scale = 1 / (C.terrainScaleSlider * map.segmentation_multiplier)
	return Util.multiBasisNoise(2, 2, 2, 1 / (scale * C.resourceNoiseInputScale), C.resourceNoiseAmplitude)
end)

------------------------------------------------------------------------
-- Iron

-- Define a starting patch iron factor, between 0 and 1. This is used for both probability and richness.
-- TODO maybe this should rather use spot noise?
local startingPatchIronFactor = noise.define_noise_function(function(x, y, tile, map)
	local scale = 1 / (C.terrainScaleSlider * map.segmentation_multiplier)
	local startingIronPos = Util.getStartIslandIronCenter(scale)
	local distFromStartIron = Util.dist(startingIronPos[1], startingIronPos[2], x, y) / scale
	local factor = Util.rampDouble(distFromStartIron,
		C.startIronPatchMinRad, C.startIronPatchMidRad, C.startIronPatchMaxRad,
		C.startIronPatchCenterWeight, 0, -C.startIronPatchCenterWeight)
	return factor + resourceNoise
end)

local originalIronProb = data.raw.resource["iron-ore"].autoplace.probability_expression
data.raw.resource["iron-ore"].autoplace.probability_expression = noise.define_noise_function(function(x, y, tile, map)
	local scale = 1 / (C.terrainScaleSlider * map.segmentation_multiplier)
	local modifiedIronProb = originalIronProb

	-- Layer that's 0 on the starting island, 1 everywhere else.
	-- This says probability should always be 0 on the starting island, so no patches.
	local maxProbForStartIsland = noise.if_else_chain(Util.withinStartIsland(scale, x, y), 0, 1)
	modifiedIronProb = noise.min(maxProbForStartIsland, modifiedIronProb)

	-- Layer that's high at the starting iron patch, 0 everywhere else.
	local minProbForStartWithNoise = noise.clamp(startingPatchIronFactor, 0, 1)
	local floorProb = 0.8 -- Set probability to 0 if it's below this value, so we don't get spatterings of ore like the spray can tool in MS Paint.
	minProbForStartWithNoise = noise.if_else_chain(noise.less_than(minProbForStartWithNoise, floorProb), 0, minProbForStartWithNoise)
	modifiedIronProb = noise.max(minProbForStartWithNoise, modifiedIronProb)

	return modifiedIronProb
end)

local originalIronRichness = data.raw.resource["iron-ore"].autoplace.richness_expression
data.raw.resource["iron-ore"].autoplace.richness_expression = noise.define_noise_function(function(x, y, tile, map)
	local richness = 400 * startingPatchIronFactor * noise.var("control-setting:iron-ore:richness:multiplier")
	return noise.if_else_chain(noise.less_than(1, richness), richness, originalIronRichness)
end)

------------------------------------------------------------------------
-- All resources that fade in at a certain distance from the starting island.

-- TODO I want these to be partially dependent on elevation, so they spawn near the centers of islands, not overlapping the edges of islands.
data.raw.resource["uranium-ore"].autoplace.richness_expression = tne(100) -- TODO
data.raw.resource["uranium-ore"].autoplace.probability_expression = noise.define_noise_function(function(x, y, tile, map)
	local scale = 1 / (C.terrainScaleSlider * map.segmentation_multiplier)

	if false then
		local frequency_multiplier = noise.var("control-setting:uranium-ore:frequency:multiplier")
		local size_multiplier = noise.var("control-setting:uranium-ore:size:multiplier")
		local density_multiplier = frequency_multiplier * size_multiplier
		local base_density = 10
		local double_density_distance = 1300 -- distance at which patches have twice as much stuff in them
		-- Maximum distance at which blob amplitude should keep increasing along with spot height
		local regular_blob_amplitude_maximum_distance = double_density_distance
		local spot_enlargement_maximum_distance = regular_blob_amplitude_maximum_distance
		local function regular_density_at(dist)
			-- Don't increase density beyond spot_enlargement_maximum_distance
			-- because large spots get unwieldy.  We'll increase richness after that, instead.
			effective_distance = noise.clamp(dist, 0, spot_enlargement_maximum_distance)
			local distance_density_multiplier = 1 + effective_distance / double_density_distance
			return base_density * density_multiplier * distance_density_multiplier
		end
		local base_spots_per_km2 = 2.5
		local spots_per_km2_near_start = base_spots_per_km2 * frequency_multiplier
		-- Regular spot quantity without randomization added
		local function regular_spot_quantity_base_at(dist)
			return regular_density_at(dist) * 1000000 / spots_per_km2_near_start
		end
		local random_spot_size_minimum = 0.25
		local random_spot_size_maximum = 2.0
		-- Regular spot quantity averaging over randomization
		local function regular_spot_quantity_typical_at(dist)
			local average_random_size_multiplier = (random_spot_size_minimum + random_spot_size_maximum) / 2
			return average_random_size_multiplier * regular_spot_quantity_base_at(dist)
		end
		local regular_rq_factor = 1/10
		local function regular_spot_height_typical_at(dist)
			return regular_spot_quantity_typical_at(dist)^(1/3) / ((math.pi/3) * regular_rq_factor^2)
		end
		local function regular_blob_amplitude_at(dist)
			return noise.min(
				regular_spot_height_typical_at(regular_blob_amplitude_maximum_distance),
				regular_spot_height_typical_at(dist)
			)
		end
		--local basement_value = regular_blob_amplitude_at(regular_blob_amplitude_maximum_distance)
		basement_value = -1000

		local spotProb = tne{
			type = "function-application",
			function_name = "factorio-basis-noise",
			arguments = {
				x = noise.var("x") / scale + C.artifactShift,
				y = noise.var("y") / scale,
				seed0 = noise.var("map_seed"),
				seed1 = tne(Util.getNextSeed1()),
				region_size = 1024,
				density_expression = tne(600),
				spot_quantity_expression = noise.random_between(0.25, 1) * 600 * 1000000 / (2.5 * noise.var("control-setting:uranium-ore:frequency:multiplier")),
				spot_radius_expression = tne(32),
				hard_region_target_quantity = tne(false),
				spot_favorability_expression = tne(1),
				basement_value = basement_value,
				maximum_spot_basement_radius = tne(128),
			}
		}
		return spotProb
	end

	
end)

------------------------------------------------------------------------

-- TODO handle the starting patch resources with extra patches at edges: copper, tin, coal, stone.
-- TODO handle gas fissures.
-- TODO handle starting-area steam fissures; maybe multiple.
-- TODO handle crude oil.
-- TODO handle uranium and gold.