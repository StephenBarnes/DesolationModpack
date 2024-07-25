-- This file changes what tiles get autoplaced where.
-- Use noise layers defined in other files to determine whether we need buildable tiles (eg at resources) or not.

local noise = require "noise"
local var = noise.var
local tne = noise.to_noise_expression
local U = require("code.data.terrain.util")
local C = require("code.data.terrain.constants")
local globalParams = require("code.global-params")

-- Disable autoplace for the hotter volcanic terrain, bc we want to use the greyer rock ones as buildable land.
data.raw.tile["volcanic-orange-heat-3"].autoplace = nil
data.raw.tile["volcanic-orange-heat-4"].autoplace = nil

local temp = var("temperature")
local aux = var("aux")
local moisture = var("moisture")
local lt = noise.less_than
local lte = noise.less_or_equal
local zero = tne(0)
local one = tne(1)

--local function noiseNand(a, b)
--	return noise.if_else_chain(a, 0, b, 0, 1)
--end

local function makeCondition(varMinMax, extraNandTerms)
	-- Takes a table mapping var names to min/max values, and returns a noise expression that yields 1 if all conditions are met, 0 otherwise.
	-- The arg extraNandTerms can be used to de-duplicate expressions.
	--log("Making a new condition")
	local nandedTerms = {} -- We collect all terms which would make this condition FALSE.
	if extraNandTerms ~= nil then
		for _, term in pairs(extraNandTerms) do
			table.insert(nandedTerms, term)
		end
	end
	for varName, minMax in pairs(varMinMax) do
		local thisVar = var(varName)
		local varMin = minMax[1]
		local varMax = minMax[2]
		--log("Var "..varName.." min/max: "..(varMin or "nil").." / "..(varMax or "nil"))
		if varMin ~= nil then
			--log("insert lt("..varName..", "..varMin..")")
			table.insert(nandedTerms, lt(thisVar, varMin))
		end
		if varMax ~= nil then
			--log("insert lte("..varMax..", "..varName..")")
			table.insert(nandedTerms, lte(varMax, thisVar))
				-- Use lte instead of lt, so that you can have two conditions like {nil, 10} and {10, nil} that will cover the whole range.
		end
	end
	local ifElseChainArgs = {}
	for _, term in pairs(nandedTerms) do
		table.insert(ifElseChainArgs, term)
		table.insert(ifElseChainArgs, zero)
	end
	table.insert(ifElseChainArgs, one)
	return tne {
		type = "if-else-chain",
		arguments = ifElseChainArgs,
	}
end

local function setTileCondition(tileName, condition)
	data.raw.tile[tileName].autoplace = {
		probability_expression = condition,
		richness_expression = condition,
	}
end

local function setTileConditionVarMinMax(tileName, varMinMax, extraNandTerms)
	local condition = makeCondition(varMinMax, extraNandTerms)
	setTileCondition(tileName, condition)
end

-- Cache some values, to try to speed up the noise expressions.
local tooMoistForVolcanic = noise.delimit_procedure(lte(0.3, moisture))
local tooColdToBuild = noise.delimit_procedure(lt(temp, 15))
setTileConditionVarMinMax("volcanic-orange-heat-1", {
	temperature = {15, 35},
	--moisture = {nil, 0.3},
}, {tooMoistForVolcanic})
setTileConditionVarMinMax("volcanic-orange-heat-2", {
	temperature = {35, nil},
	--moisture = {nil, 0.3},
}, {tooMoistForVolcanic})
setTileConditionVarMinMax("vegetation-turquoise-grass-1", {
	--temperature = {15, nil},
	moisture = {0.3, 5.0},
}, {tooColdToBuild})
setTileConditionVarMinMax("vegetation-turquoise-grass-2", {
	--temperature = {15, nil},
	moisture = {5.0, nil},
}, {tooColdToBuild})
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
local tooHotForSnow = noise.delimit_procedure(lte(15, temp))
for i = 1, 9 do
	local snowAuxMin = snowAuxes[i - 1]
	local snowAuxMax = snowAuxes[i]
	assert((snowAuxMin ~= nil) or (snowAuxMax ~= nil))
	local snowName = "frozen-snow-"..snowOrder[i]
	setTileConditionVarMinMax(snowName, {
		--temperature = {nil, 15},
		aux = {snowAuxMin, snowAuxMax},
	}, {tooHotForSnow})
end

-- Muddy water should generate around buildable regions that touch the coast, ie where elevation is just barely underwater and temperature is high.
setTileConditionVarMinMax("water-shallow", {
	elevation = {-1, 0},
}, {tooColdToBuild})
-- Multiply by 1000 to make it overpower the other water.
data.raw.tile["water-shallow"].autoplace.probability_expression = 1000 * data.raw.tile["water-shallow"].autoplace.probability_expression
data.raw.tile["water-shallow"].autoplace.richness_expression = 1000 * data.raw.tile["water-shallow"].autoplace.richness_expression
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

