-- This file is to debug the progression of the modpack.
-- It should be disabled in release.
-- It has multiple check functions, which return true if the check is fine, false if it failed.
-- Checks:
-- * The total of all possible +evolution effects should be +100%.
-- * TODO check that the only way to get to the final tech involves a total of +100% evolution.
-- * TODO for all techs, check required science packs and that there's a recipe for that science pack unlocked by one of its prereqs.
-- * TODO for all techs, for all recipes they unlock, check that all ingredients have been unlocked by that point.


local function checkTotalEvo()
	local totalEvo = 0
	for _, tech in pairs(data.raw.technology) do
		if tech.effects ~= nil then
			for _, effect in pairs(tech.effects) do
				if effect.type == "nothing" and effect.effect_description[1] == "effect-description.evolution" then
					totalEvo = totalEvo + effect.effect_description[2]
				end
			end
		end
	end
	if totalEvo == 100 then
		log("Tech total evo check: Over all techs, sum of evolution effects is 100, passed.")
		return true
	else
		log("Tech total evo check: ERROR: Sum of techs is not 100, instead it is "..(totalEvo or "nil"))
		return false
	end
end

local function checkTechPrereqsHaveSciPackRecipe()
	return true -- TODO
end

local function runFullDebug()
	log("Desolation: running full progression debug.")
	local success = true
	success = checkTotalEvo() and success
	success = checkTechPrereqsHaveSciPackRecipe() and success
	if success then
		log("Desolation: full progression debug passed.")
	else
		log("Desolation ERROR: one or more progression debug checks failed.")
	end
end

return {
	runFullDebug = runFullDebug,
}