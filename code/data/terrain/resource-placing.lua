local noise = require "noise"
local tne = noise.to_noise_expression

local Util = require("code.data.terrain.util")
local C = require("code.data.terrain.constants")

local originalIronProb = data.raw.resource["iron-ore"].autoplace.probability_expression
data.raw.resource["iron-ore"].autoplace.probability_expression = noise.define_noise_function(function(x, y, tile, map)
	local scale = 1 / (C.terrainScaleSlider * map.segmentation_multiplier)
	local modifiedIronProb = originalIronProb

	-- Layer that's 0 on the starting island, 1 everywhere else.
	-- This says probability should always be 0 on the starting island, so no patches.
	local maxProbForStartIsland = noise.if_else_chain(Util.withinStartIsland(scale, x, y), 0, 1)
	modifiedIronProb = noise.min(maxProbForStartIsland, modifiedIronProb)

	-- Layer that's 1 at the starting iron patch, 0 everywhere else.
	local startingIronPos = Util.getStartIslandIronCenter(scale)
	local distFromStartIron = Util.dist(startingIronPos[1], startingIronPos[2], x, y) / scale
	local minProbForStartIronPatch = Util.ramp(distFromStartIron, C.startIronPatchMinRad, C.startIronPatchMaxRad, 1, 0)
	local probNoise = Util.multiBasisNoise(2, 2, 2, 1 / (scale * C.startIronPatchProbNoiseInputScale), tne(C.startIronPatchProbNoiseAmplitude))
	local minProbForStartWithNoise = noise.clamp(probNoise + minProbForStartIronPatch, 0, 1)
	modifiedIronProb = noise.max(minProbForStartWithNoise, modifiedIronProb)

	return modifiedIronProb
end)

local originalIronRichness = data.raw.resource["iron-ore"].autoplace.richness_expression
data.raw.resource["iron-ore"].autoplace.richness_expression = noise.define_noise_function(function(x, y, tile, map)
	local scale = 1 / (C.terrainScaleSlider * map.segmentation_multiplier)
	local startingIronPos = Util.getStartIslandIronCenter(scale)
	local distFromStartIron = Util.dist(startingIronPos[1], startingIronPos[2], x, y) / scale
	local minRichnessForStartIronPatch = noise.if_else_chain(noise.less_than(distFromStartIron, C.startIronPatchMaxRad), 1000, 0)
	-- TODO make this an actual cone again.
	return noise.max(minRichnessForStartIronPatch, originalIronRichness)
end)


-- TODO handle the starting patch resources with extra patches at edges: copper, tin, coal, stone.
-- TODO handle gas fissures.
-- TODO handle starting-area steam fissures; maybe multiple.
-- TODO handle crude oil.
-- TODO handle uranium and gold.