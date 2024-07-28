-- This file changes what tiles get autoplaced where.
-- Use noise layers defined in other files to determine whether we need buildable tiles (eg at resources) or not.

local noise = require "noise"
local var = noise.var
local globalParams = require("code.global-params")
local C = require("code.data.terrain.constants")

-- Disable autoplace for the hotter volcanic terrain, bc we want to use the greyer rock ones as buildable land.
data.raw.tile["volcanic-orange-heat-3"].autoplace = nil
data.raw.tile["volcanic-orange-heat-4"].autoplace = nil

local temp = var("temperature")
local aux = var("aux")
local moisture = var("moisture")
local lt = noise.less_than
local lte = noise.less_or_equal

local function makeCondition(varMinMax, extraAndTerms)
	local andTerms = extraAndTerms or {}
	for varName, minMax in pairs(varMinMax) do
		local thisVar = var(varName)
		local varMin = minMax[1]
		local varMax = minMax[2]
		if varMin ~= nil then
			table.insert(andTerms, lt(varMin, thisVar))
		end
		if varMax ~= nil then
			table.insert(andTerms, lte(thisVar, varMax))
		end
	end
	-- We simply multiply together the terms to AND them, since 1*1=1 while 0*1=0 and 0*0=0.
	local result = andTerms[1]
	for i = 2, #andTerms do
		result = result * andTerms[i]
	end
	return result
end

local function setTileCondition(tileName, condition)
	data.raw.tile[tileName].autoplace = {
		probability_expression = condition,
		richness_expression = condition,
	}
end

local function setTileConditionVarMinMax(tileName, varMinMax, extraAndTerms)
	local condition = makeCondition(varMinMax, extraAndTerms)
	setTileCondition(tileName, condition)
end

-- Cache some values, to try to speed up the noise expressions.
local dryEnoughForVolcanic = noise.delimit_procedure(lte(moisture, 0.3))
local warmEnoughToBuild = noise.delimit_procedure(lt(C.temperatureThresholdForSnow, temp))
setTileConditionVarMinMax("volcanic-orange-heat-1", {
	temperature = {C.temperatureThresholdForSnow, C.temperatureBoundaryVolcanic1And2},
	--moisture = {nil, 0.3},
}, {dryEnoughForVolcanic})
setTileConditionVarMinMax("volcanic-orange-heat-2", {
	temperature = {C.temperatureBoundaryVolcanic1And2, nil},
	--moisture = {nil, 0.3},
}, {dryEnoughForVolcanic})
setTileConditionVarMinMax("vegetation-turquoise-grass-1", {
	--temperature = {15, nil},
	moisture = {C.moistureBoundaryVolcanicAndGrass, C.moistureBoundaryGrass1And2},
}, {warmEnoughToBuild})
setTileConditionVarMinMax("vegetation-turquoise-grass-2", {
	--temperature = {15, nil},
	moisture = {C.moistureBoundaryGrass1And2, nil},
}, {warmEnoughToBuild})
-- Set tile colors temporarily, so I can see what the conditions look like.
if globalParams.colorBuildableTiles then
	data.raw.tile["volcanic-orange-heat-1"].map_color = {r=0.0, g=0.0, b=1.0}
	data.raw.tile["volcanic-orange-heat-2"].map_color = {r=1, g=0.0, b=0.0}
	data.raw.tile["vegetation-turquoise-grass-1"].map_color = {r=0.0, g=1.0, b=0.0}
	data.raw.tile["vegetation-turquoise-grass-2"].map_color = {r=0.0, g=1.0, b=1.0}
end

local snowOrder = {0, 1, 3, 2, 4, 8, 9, 5, 6} -- Snow types in order from lightest to darkest.
	-- Not using type 7 bc it looks a bit weird.
data.raw.tile["frozen-snow-7"].autoplace = nil
local snowAuxes = {0.1, 0.3, 0.4, 0.55, 0.7, 0.8, 0.915, 0.95}
assert(#snowAuxes == 9 - 1) -- Each snow type occupies the range between consecutive snow aux values, including the endpoints with nil min/max.
local coldEnoughForSnow = noise.delimit_procedure(lte(temp, C.temperatureThresholdForSnow))
for i = 1, 9 do
	local snowAuxMin = snowAuxes[i - 1]
	local snowAuxMax = snowAuxes[i]
	assert((snowAuxMin ~= nil) or (snowAuxMax ~= nil))
	local snowName = "frozen-snow-"..snowOrder[i]
	setTileConditionVarMinMax(snowName, {
		--temperature = {nil, 15},
		aux = {snowAuxMin, snowAuxMax},
	}, {coldEnoughForSnow})
end

-- Muddy water should generate around buildable regions that touch the coast, ie where elevation is just barely underwater and temperature is high.
setTileConditionVarMinMax("water-mud", {
	elevation = {-1, 0},
}, {warmEnoughToBuild})
-- Multiply by 1000 to make it overpower the other water.
data.raw.tile["water-mud"].autoplace.probability_expression = 1000 * data.raw.tile["water-mud"].autoplace.probability_expression
data.raw.tile["water-mud"].autoplace.richness_expression = 1000 * data.raw.tile["water-mud"].autoplace.richness_expression
-- The above works; could use this to get different cutoffs for starting island vs other islands. But rather just change elevation for that.
--setTileCondition("water-shallow", noise.delimit_procedure(noise.if_else_chain(
--	tooColdToBuild, 0,
--	var("apply-start-island-resources"), noise.if_else_chain(
--		lt(var("elevation"), -4.5), 0,
--		lt(0, var("elevation")), 0,
--		1),
--	noise.if_else_chain(
--		lt(var("elevation"), -1), 0,
--		lt(0, var("elevation")), 0,
--		1)
--) * 1000)) -- Multiply by 1000 to make it overpower the other water.

-- There's a separate tile for "shallow water", which looks worse than the mud-water, so disable it.
data.raw.tile["water-shallow"].autoplace = nil
