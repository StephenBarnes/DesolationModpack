local noise = require "noise"
local tne = noise.to_noise_expression

local Util = require("code.data.terrain.util")
local C = require("code.data.terrain.constants")

-- Define a single basis noise function shared between all resources, since they don't overlap anyway.
local resourceNoise = noise.define_noise_function(function(x, y, tile, map)
	local scale = 1 / (C.terrainScaleSlider * map.segmentation_multiplier)
	return Util.multiBasisNoise(2, 2, 2, 1 / (scale * C.resourceNoiseInputScale), C.resourceNoiseAmplitude)
end)


------------------------------------------------------------------------
-- Iron

data.raw.resource["iron-ore"].map_color = {r=0, g=0, b=1} -- To make it more obvious against the white/greyblue background.

-- Define a starting patch iron factor, between 0 and 1. This is used for both probability and richness.
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

for resourceName, fadeDistances in pairs(C.resourceMinDist) do
	local originalProb = data.raw.resource[resourceName].autoplace.probability_expression
	data.raw.resource[resourceName].autoplace.probability_expression = noise.define_noise_function(function(x, y, tile, map)
		-- TODO: This is completely inadequate. Results in spray-paint style resource patches. I should rather just completely re-create the resource patch distribution functions.
		local scale = 1 / (C.terrainScaleSlider * map.segmentation_multiplier)
		local dist = Util.minDistToStartIslandCenterOrIronArcCenter(scale, x, y)
		local probMult = Util.rampDouble(dist,
			fadeDistances[1], fadeDistances[2], fadeDistances[3],
			0, 0.7, 1)
		return originalProb * probMult
	end)
end

------------------------------------------------------------------------

-- TODO handle the starting patch resources with extra patches at edges: copper, tin, coal, stone.
-- TODO handle gas fissures.
-- TODO handle starting-area steam fissures; maybe multiple.
-- TODO handle crude oil.
-- TODO handle uranium and gold.