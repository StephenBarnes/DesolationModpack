-- This file is to debug the progression of the modpack.
-- It should be disabled in release.
-- It has multiple check functions, which return true if the check is fine, false if it failed.
-- Checks:
-- * The total of all possible +evolution effects should be +100%.
-- * For all techs, each required science pack should be unlocked by one of its prereqs.
-- * For all techs, for all recipes they unlock, all ingredients for those recipes should be unlocked by the tech's prereqs.
-- * Check that the only way to get to the final tech involves a total of +100% evolution.
-- * Check that all items have their stack sizes set in common/stack-sizes.lua, exactly once.

-- This might seem like more effort than just manually looking through the tech tree, but, so far it's already found multiple bugs that I hadn't noticed.
-- So, this is good. Keep it updated.

local Table = require("code.util.table")

-- TODO simplify this code by refactoring stuff to these modules. Instead of having a lot of nil-checks in here, etc.
local Recipe = require("code.util.recipe")
local Tech = require("code.util.tech")

local stackSizeCommon = require("code.common.stack-sizes")

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
				local prereqs = Tech.getPrereqList(tech)
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
					local prereqs = Tech.getPrereqList(tech)
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

------------------------------------------------------------------------
-- EVOLUTION CHECKS

local function checkTotalEvo()
	-- Checks that total evolution sums to 100%.
	local totalEvo = 0
	for _, tech in pairs(data.raw.technology) do
		totalEvo = totalEvo + Tech.getEvolutionPercent(tech)
	end

	if totalEvo == 100 then
		log("Tech total evo check: Over all techs, sum of evolution effects is 100, passed.")
		return true
	else
		log("Tech total evo check: ERROR: Sum of techs is not 100, instead it is "..(totalEvo or "nil"))
		return false
	end
end

local function checkEndTechEvo()
	-- Checks that getting to the final tech involves a total of +100% evolution.
	local finalTechId = "magnum-opus" -- TODO change this to the victory tech.
	local finalTechPrereqs = Tech.getRecursivePrereqs(finalTechId)
	if finalTechPrereqs == nil then
		log("ERROR: Couldn't find prereqs of "..finalTechId..".")
		return false
	end

	local totalEvo = 0
	for techId, _ in pairs(finalTechPrereqs) do
		if data.raw.technology[techId] == nil then
			log("ERROR: Tech "..techId.." is a recursive prereq of "..finalTechId..", but it doesn't exist.")
			return false
		end
		totalEvo = totalEvo + Tech.getEvolutionPercent(data.raw.technology[techId])
	end

	if totalEvo == 100 then
		log("End tech evo check: Over all techs, sum of evolution effects is 100, passed.")
		return true
	else
		log("End tech evo check: ERROR: Sum of techs is not 100, instead it is "..(totalEvo or "nil"))
		return false
	end
end

------------------------------------------------------------------------
-- TECH UNLOCK ORDER CHECKS

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
	local unlockedAtStart = Table.listToSet {
		"wood",
		"copper-ore",
		"tin-ore",
		"iron-ore",
		"coal",
		"stone",
		"gold-ore",

		"ruby-gem",
		"diamond-gem",

		"copper-scrap",
		"tin-scrap",

		-- Schematics that come from items available at start.
		"schematic-ir-charcoal", -- for stone furnace tech
		"schematic-stone-wall",

		-- "Lightbulb-only" schematics that are unlocked by their prereqs.
		"schematic-ir-basic-research", -- for steel mechanisms tech
		"schematic-ir-blunderbuss",
		"schematic-ir-basic-wood",
		"schematic-ir-electroplating",
		"schematic-ir-washing-2",
	}

	-- Table from tech to stuff that's unlocked by that tech, but not explicitly in its recipe list.
	local unlockedImplicitlyByTech = {
		-- TODO add water
		-- TODO add steam from the first steam mechanism thing
	}

	-- Table from item unlocked by tech to stuff that's also unlocked by that item.
	local unlockedImplicitlyByItem = {
		["transfer-plate-2x2"] = {"Desolation-transfer-plate-unlocks-tech"},
		["transfer-plate"] = {"Desolation-transfer-plate-unlocks-tech"},

		["pumpjack"] = {"schematic-ir-crude-oil-processing", "crude-oil"},

		["satellite"] = {"space-science-pack"},

		["gold-ingot"] = {"schematic-ir-gold-milestone", "gold-scrap"},
		["steel-ingot"] = {"schematic-ir-steel-milestone", "steel-scrap"},
		["iron-ingot"] = {"schematic-ir-iron-milestone", "iron-scrap"},
		["glass"] = {"schematic-ir-glass-milestone", "glass-scrap"},
		["bronze-ingot"] = {"schematic-ir-bronze-milestone", "bronze-scrap"},
		["copper-ingot"] = {"schematic-ir-copper-working-1"},
		["tin-ingot"] = {"schematic-ir-tin-working-1"},
		["copper-plate"] = {"schematic-ir-copper-working-2"},
		["tin-gear-wheel"] = {"schematic-ir-tin-working-2"},
		["brass-ingot"] = {"schematic-ir-brass-milestone", "brass-scrap"},
		["electrum-gem"] = {"schematic-ir-electrum-milestone"},
		["uranium-235"] = {"schematic-kovarex-enrichment-process"},

		["lead-ingot"] = {"schematic-ir-lead-smelting", "lead-scrap"},
		["chromium-ingot"] = {"schematic-ir-chromium-smelting", "chromium-scrap"},
		["nickel-ingot"] = {"schematic-ir-nickel-smelting", "nickel-scrap"},
		["platinum-ingot"] = {"schematic-ir-platinum-smelting", "platinum-scrap"},

		["steel-derrick"] = {"dirty-steam", "fossil-gas"},

		["sulfuric-acid"] = {"uranium-ore"},

		["uranium-fuel-cell"] = {"used-up-uranium-fuel-cell"},

		["quantum-satellite"] = {"comet-ice-ore"}, -- For deep space mining.
	}

	-- TODO special tables for stuff like the barrelling recipes.
	-- TODO figure out why the barrelling tech isn't currently reporting any errors.

	-- Tables from tech to stuff that's available before/after that tech is researched.
	-- Later, we require that the stuff available before the tech contains all science packs required by the tech.
	-- And we require that the stuff available after the tech contains all ingredients of the tech's unlocked recipes.
	local availableAfterTech = {}
	local availableBeforeTech = {}
	for _, techName in pairs(toposortedTechs) do
		local tech = data.raw.technology[techName]
		local prereqs = Tech.getPrereqList(tech)
		local availableBeforeThisTech = {}
		local availableAfterThisTech = {}
		if prereqs == nil or #prereqs == 0 then
			-- If no prereqs, it's only things unlocked at start.
			Table.overwriteInto(unlockedAtStart, availableBeforeThisTech)
		else
			-- If it has prereqs, copy in stuff from prereqs.
			for _, prereqName in pairs(prereqs) do
				local availableAfterPrereq = availableAfterTech[prereqName]
				if availableAfterPrereq == nil then
					log("ERROR: Tech "..techName.." has prereq "..prereqName.." which has not been processed; this should never happen.")
					return false
				end
				Table.overwriteInto(availableAfterPrereq, availableBeforeThisTech)
			end
		end

		availableBeforeTech[techName] = availableBeforeThisTech
		Table.overwriteInto(availableBeforeThisTech, availableAfterThisTech)

		-- Add products of unlocked recipes.
		if tech.effects == nil then
			log("ERROR: Tech "..techName.." has no effects. This should never happen.")
			successfulSoFar = false
		end
		for _, effect in pairs(tech.effects or {}) do
			if effect.type == "unlock-recipe" then
				local recipe = data.raw.recipe[effect.recipe]
				if recipe == nil then
					log("ERROR: Tech "..techName.." has recipe "..effect.recipe.." which is nil; this should never happen.")
					return false
				end
				local results = Recipe.getResults(recipe)
				for _, result in pairs(results) do
					local resultName = Recipe.resultToName(result)
					if resultName == nil then
						log("ERROR: Recipe "..effect.recipe.." has result "..serpent.block(result).." which has no name; this should never happen.")
						successfulSoFar = false
					else
						availableAfterThisTech[resultName] = true
						if unlockedImplicitlyByItem[resultName] ~= nil then
							for _, unlockedImplicitlyByItemName in pairs(unlockedImplicitlyByItem[resultName]) do
								availableAfterThisTech[unlockedImplicitlyByItemName] = true
							end
						end
					end
				end
			end
		end

		-- Add anything implicitly unlocked by this tech.
		if unlockedImplicitlyByTech[techName] ~= nil then
			Table.overwriteInto(unlockedImplicitlyByTech[techName], availableAfterThisTech)
		end
		availableAfterTech[techName] = availableAfterThisTech
	end

	-- Check that science packs of all techs are included in it's prereqs' available-after-tech.
	for _, techName in pairs(toposortedTechs) do
		local tech = data.raw.technology[techName]
		local sciencePacks = tech.unit.ingredients or Table.maybeGet(Table.maybeGet(tech.normal, "unit"), "ingredients")
		if sciencePacks == nil then
			log("ERROR: Tech "..techName.." has no science packs. This should never happen.")
			return false
		end
		for _, sciencePack in pairs(sciencePacks) do
			local sciencePackName = Recipe.resultToName(sciencePack)
			if sciencePackName == nil then
				log("ERROR: Tech "..techName.." has science pack "..serpent.block(sciencePack).." which has no name. This should never happen.")
				return false
			end
			--local isSchematic = string.match(sciencePackName, "^schematic-") -- IR3 Inspiration mod adds schematic items, which can't actually be produced.
			--if not isSchematic and not availableBeforeTech[techName][sciencePackName] then
			if not availableBeforeTech[techName][sciencePackName] then
				log("ERROR: Tech "..techName.." requires science pack "..sciencePackName.." which has not been unlocked yet.")
				successfulSoFar = false
			end
		end
	end

	-- Check all ingredients of all techs's unlocked recipes are included in available after tech.
	for _, techName in pairs(toposortedTechs) do
		local tech = data.raw.technology[techName]
		if tech.effects == nil then
			log("ERROR: Tech "..techName.." has no effects. This should never happen.")
			successfulSoFar = false
		end
		for _, effect in pairs(tech.effects or {}) do
			if effect.type == "unlock-recipe" then
				local recipe = data.raw.recipe[effect.recipe]
				if recipe == nil then
					log("ERROR: Tech "..techName.." has recipe "..effect.recipe.." which is nil; this should never happen.")
					return false
				end
				local ingredients = recipe.ingredients or Table.maybeGet(recipe.normal, "ingredients")
				if ingredients == nil then
					log("ERROR: Recipe "..effect.recipe.." has no ingredients; this should never happen. Recipe: "..serpent.block(recipe))
					log("recipe.normal.ingredients == "..serpent.block(recipe.normal.ingredients))
					return false
				end
				for _, ingredient in pairs(ingredients) do
					local ingredientName = Recipe.resultToName(ingredient)
					if ingredientName == nil then
						log("ERROR: Recipe "..effect.recipe.." has ingredient "..serpent.block(ingredient).." which has no name; this should never happen.")
						return false
					end
					if not availableAfterTech[techName][ingredientName] then
						log("ERROR: Tech "..techName.." unlocks recipe "..effect.recipe.." which requires ingredient "..ingredientName.." but that ingredient has not been unlocked yet.")
						successfulSoFar = false
					end
				end
			end
		end
	end

	return successfulSoFar
end

------------------------------------------------------------------------
-- STACK SIZE CHECKS

local itemNamesToIgnore = Table.listToSet{
	"coin", "item-unknown",
	"simple-entity-with-force", "simple-entity-with-owner",
	"infinity-chest", "infinity-pipe",
	"loader", "fast-loader", "express-loader", -- Built-in loader items, not the IR3 ones.
	"Desolation-transfer-plate-unlocks-tech",
	"electric-energy-interface", "heat-interface",
	"item-with-label", "item-with-inventory", "item-with-tags",
	"waterway",
	"discharge-defense-remote", "artillery-targeting-remote",
	"cliff-explosives", -- No cliffs.
	"searchlight-assault-signal-interface",
}
local function itemNeedsStackSize(itemName)
	-- Return whether we actually care about a stack size for this item, since some items are just markers etc.
	if itemNamesToIgnore[itemName] then return false end
	if itemName:match("spill%-data") then return false end -- From IR3, used to store fluid spill pollution data.
	if itemName:match("^creative") then return false end -- From Creative Mod.
	if itemName:match("^schematic%-") then return false end -- From IR3 Inspiration mod.
	if itemName:match("^ic%-container%-") then return false end -- Items in containers, handled by Intermodal Containers mod.
	if itemName:match("sla_boosted") then return false end -- Ammo items boosted by the Searchlight Assault mod.
	return true
end

local function checkStackSizeGroupsOfItem(typeName, itemName)
	-- Check that this specific item is in exactly one stack size group.
	if not itemNeedsStackSize(itemName) then return true end
	local groupsOfThisItem = {}
	for groupName, groupData in pairs(stackSizeCommon.stackSizeGroups) do
		for _, itemList in pairs({groupData.items, groupData.dataFinalFixesItems}) do
			for _, itemSpecifier in pairs(itemList) do
				local itemId
				if type(itemSpecifier) == "string" then
					itemId = itemSpecifier
				else
					itemId = itemSpecifier[2]
				end
				if itemId == itemName then
					table.insert(groupsOfThisItem, groupName)
				end
			end
		end
	end
	for _, itemId in pairs(stackSizeCommon.bundleItems) do
		local bundleItemName = "stacked-"..itemId
		if itemName == bundleItemName then
			table.insert(groupsOfThisItem, "bundles")
		end
	end
	if #groupsOfThisItem > 1 then
		log("ERROR: Item "..itemName.." with type "..typeName.." has stack sizes set in more than one group: "..serpent.block(groupsOfThisItem))
		return false
	elseif #groupsOfThisItem == 0 then
		log("ERROR: Item "..itemName.." with type "..typeName.." is not in any stack size group.")
		return false
	end
	return true
end

local function checkStackSizesSet()
	-- Checks that all items have their stack sizes set in common/stack-sizes.lua, exactly once.
	local success = true
	local typesToCheck = {"item", "item-with-entity-data", "ammo", "capsule", "item-with-entity-data", "item-with-label", "item-with-inventory", "item-with-tags", "module", "rail-planner", "tool", "repair-tool"}
		-- We check all entries in data.raw.TYPE for all TYPE that is a subclass of ItemPrototype.
		-- Except for selection-tool (and subclasses), blueprint, blueprint-book, spidertron-remote, gun, armor, mining-tool
	for _, typeName in pairs(typesToCheck) do
		for itemName, _ in pairs(data.raw[typeName]) do
			if not checkStackSizeGroupsOfItem(typeName, itemName) then success = false end
				-- Avoiding short-circuit evaluation, bc I want to check all items.
		end
	end
	return success
end

------------------------------------------------------------------------
-- MAIN

local function runFullDebug()
	log("Desolation: running full progression debug.")
	local success = true
	success = toposortTechsAndCache() and success
	if not success then return end -- if we can't toposort the techs, many other checks won't work anyway.
	success = checkTotalEvo() and success
	success = checkEndTechEvo() and success
	success = checkTechUnlockOrder() and success
	success = checkStackSizesSet() and success
	if success then
		log("Desolation: full progression debug passed.")
	else
		log("Desolation ERROR: one or more progression debug checks failed.")
	end
end

return {
	runFullDebug = runFullDebug,
}