-- TODO

local noise = require "noise"
local tne = noise.to_noise_expression

local Util = require("code.data.terrain.util")
local C = require("code.data.terrain.constants")

local scaleSlider = noise.var("control-setting:Desolation-scale:frequency:multiplier")

log("Iron ore:")
log(serpent.block(data.raw.resource["iron-ore"].autoplace))
log("Tin ore:")
log(serpent.block(data.raw.resource["tin-ore"].autoplace))

local originalIronProb = data.raw.resource["iron-ore"].autoplace.probability_expression
data.raw.resource["iron-ore"].autoplace.probability_expression = noise.define_noise_function(function(x, y, tile, map)
	local scale = 1 / (scaleSlider * map.segmentation_multiplier)
	local modifiedIronProb = originalIronProb

	-- Layer that's 0 on the starting island, 1 everywhere else.
	-- This says probability should always be 0 on the starting island, so no patches.
	local maxProbForStartIsland = noise.if_else_chain(Util.withinStartIsland(scale, x, y), 0, 1)
	modifiedIronProb = noise.min(maxProbForStartIsland, modifiedIronProb)

	-- Layer that's 1 at the starting iron patch, 0 everywhere else.
	local startingIronPos = Util.getStartIslandIronCenter(scale)
	local distFromStartIron = Util.dist(startingIronPos[1], startingIronPos[2], x, y) / scale
	local minProbForStartIronPatch = noise.if_else_chain(noise.less_than(distFromStartIron, C.startIronPatchRad), 1, 0)
	modifiedIronProb = noise.max(minProbForStartIronPatch, modifiedIronProb)

	return modifiedIronProb
end)

local originalIronRichness = data.raw.resource["iron-ore"].autoplace.richness_expression
data.raw.resource["iron-ore"].autoplace.richness_expression = tne(1000)