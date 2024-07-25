-- This file is to debug the progression of the modpack.
-- It should be disabled in release.
-- It has multiple check functions, which return true if the check is fine, false if it failed.
-- Checks:
-- * The total of all possible +evolution effects should be +100%.
-- * TODO check that the only way to get to the final tech involves a total of +100% evolution.
-- * TODO for all techs, check required science packs and that there's a recipe for that science pack unlocked by one of its prereqs.
-- * TODO for all techs, for all recipes they unlock, check that all ingredients have been unlocked by that point.

local Table = require("code.util.table")

-- Local var to hold a list of all techs' names, sorted so that all dependencies only go forwards.
local toposortedTechs = nil

local function toposortTechsAndCache()
	-- Topologically sort the techs, storing the result in toposortedTechs.
	-- If there's a cycle, return false.
	local currToposortedTechs = {}
	local techsAdded = {} -- maps tech name to true/false for whether it's been added yet
	local numTechs = 0
	local numTechsAdded = 0
	for techName, tech in pairs(data.raw.technology) do
		if tech.enabled ~= false and not tech.hidden then
			techsAdded[techName] = false
			numTechs = numTechs + 1
		else
			--log("Skipping disabled tech "..techName)
			--log("Tech: "..serpent.block(tech))
		end
	end
	while numTechsAdded < numTechs do
		local anyAddedThisLoop = false
		for techName, beenAdded in pairs(techsAdded) do
			if not beenAdded then
				local allPrereqsAdded = true
				local tech = data.raw.technology[techName]
				local prereqs = tech.prerequisites or Table.maybeGet(tech.normal, "prerequisites") or {}
				for _, prereqName in pairs(prereqs) do
					if not techsAdded[prereqName] then
						allPrereqsAdded = false
						break
					end
				end
				if allPrereqsAdded then
					table.insert(currToposortedTechs, techName)
					numTechsAdded = numTechsAdded + 1
					anyAddedThisLoop = true
					techsAdded[techName] = true
				end
			end
		end

		if not anyAddedThisLoop then
			log("ERROR: Cycle or unreachable tech detected in tech dependency graph. This shouldn't happen.")
			for techName, beenAdded in pairs(techsAdded) do
				if not beenAdded then
					local tech = data.raw.technology[techName]
					local prereqs = tech.prerequisites or Table.maybeGet(tech.normal, "prerequisites") or {}
					log("Could not rearch tech "..techName..", which has prereqs: "..serpent.line(prereqs))
				end
			end
			log("Techs added: "..serpent.block(techsAdded))
			return false
		end
	end
	log("Toposorted techs successfully.")
	toposortedTechs = currToposortedTechs
	return true
end

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

local function checkTechUnlockOrder()
	-- Check that whenever a recipe is unlocked, all ingredients of it have been unlocked.
	-- Also checks that for every science pack required by a tech, that science pack is unlocked by one of its prereqs.

	-- Every tech has a certain set of "required things", which includes its science packs and all ingredients of its unlocked recipes.
	-- And for every tech, there's a "minimal unlocked set" of things that can be produced at that point.
	-- Here "things" can mean both items and fluids.
	-- We want to compute that minimal unlocked set for every tech, and then check that the set of required items is a subset of the minimal unlocked set.

	local successfulSoFar = true
	if toposortedTechs == nil then
		log("ERROR: Cannot check tech unlock order without toposorted techs.")
		return false
	end

	-- Table of stuff that's already available when the game starts.
	local unlockedAtStart = {
		["wood"] = true,
		["copper-ore"] = true,
		["tin-ore"] = true,
		["iron-ore"] = true,
		["coal"] = true,
		["stone"] = true,
	}

	-- Table from tech to stuff that's unlocked by that tech, but not explicitly in its recipe list.
	local unlockedImplicitlyByTech = {
		-- TODO add water
		-- TODO add steam from the first steam mechanism thing
	}

	-- TODO special tables for stuff like the barrelling recipes.

	-- Table from tech to stuff that's available after that tech is researched.
	-- This is later required to be a superset of the tech's required things.
	local availableAfterTech = {}
	for _, techName in pairs(toposortedTechs) do
		local tech = data.raw.technology[techName]
		local prereqs = tech.prerequisites or Table.maybeGet(tech.normal, "prerequisites")
		local availableAfterThisTech = {}
		if prereqs == nil or #prereqs == 0 then
			-- If no prereqs, it's only things unlocked at start.
			Table.overwriteInto(unlockedAtStart, availableAfterThisTech)
		else
			-- If it has prereqs, copy in stuff from prereqs.
			for _, prereqName in pairs(prereqs) do
				local availableAfterPrereq = availableAfterTech[prereqName]
				if availableAfterPrereq == nil then
					log("ERROR: Tech "..techName.." has prereq "..prereqName.." which has not been processed; this should never happen.")
					return false
				end
				Table.overwriteInto(availableAfterPrereq, availableAfterThisTech)
			end
		end

		-- Add products of unlocked recipes.
		-- TODO
		if tech.effects == nil then
			log("ERROR: Tech "..techName.." has no effects.")
			return false
		end
		for _, effect in pairs(tech.effects or {}) do
			if effect.type == "unlock-recipe" then
				local recipe = data.raw.recipe[effect.recipe]
				if recipe == nil then
					log("ERROR: Tech "..techName.." has recipe "..effect.recipe.." which is nil; this should never happen.")
					return false
				end
				local results = recipe.results or Table.maybeGet(recipe.normal, "results")
				if results == nil then
					local singleResult = recipe.result or Table.maybeGet(recipe.normal, "result")
					if singleResult == nil then
						results = {}
					else
						results = {{singleResult}}
					end
				end

				for _, result in pairs(results) do
					local resultName = result.name or result[1]
					if resultName == nil then
						log("ERROR: Recipe "..effect.recipe.." has result "..serpent.block(result).." which has no name; this should never happen.")
						return false
					end
					availableAfterThisTech[resultName] = true
				end
			end
		end

		-- Add anything implicitly unlocked by this tech.
		if unlockedImplicitlyByTech[techName] ~= nil then
			Table.overwriteInto(unlockedImplicitlyByTech[techName], availableAfterThisTech)
		end
		availableAfterTech[techName] = availableAfterThisTech
	end

	--log(serpent.block(availableAfterTech["ir-copper-working-1"]))
	--log(serpent.block(availableAfterTech["ir-copper-working-2"]))
	--log(serpent.block(availableAfterTech["automation"]))
	-- So far, this seems to run correctly. TODO the rest.

	-- TODO check that science packs of all techs are included in it's prereqs' available-after-tech.

	-- TODO check all requirements of all techs are included in available after tech.

	return successfulSoFar
end

local function runFullDebug()
	log("Desolation: running full progression debug.")
	local success = true
	success = toposortTechsAndCache() and success
	if not success then return end -- if we can't toposort the techs, many other checks won't work anyway.
	success = checkTotalEvo() and success
	success = checkTechUnlockOrder() and success
	if success then
		log("Desolation: full progression debug passed.")
	else
		log("Desolation ERROR: one or more progression debug checks failed.")
	end
end

return {
	runFullDebug = runFullDebug,
}