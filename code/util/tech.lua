local Tech = {}

local Table = require("code.util.table")

-- TODO refactor these functions that operate on each recipe-difficulty, to just take in the per-difficulty function and produce the function for the whole recipe.

Tech.forEachTechDifficulty = function(tech, f)
	if tech.normal ~= nil then f(tech.normal) end
	if tech.expensive ~= nil then f(tech.expensive) end
	if tech.normal == nil or tech.expensive == nil then f(tech) end
end

Tech.addRecipeToTech = function(recipeName, techName, index)
	local unlock = {
		type = "unlock-recipe",
		recipe = recipeName,
	}
	local tech = data.raw.technology[techName]
	if tech == nil then
		log("ERROR: Couldn't find tech "..techName.." to add recipe "..recipeName.." to.")
		return
	end
	Tech.forEachTechDifficulty(tech, function(td)
		if not td.effects then
			td.effects = {unlock}
		else
			if index == nil then
				table.insert(td.effects, unlock)
			else
				table.insert(td.effects, index, unlock)
			end
		end
	end)
end

Tech.hideTech = function(techName)
	local tech = data.raw.technology[techName]
	if tech == nil then
		log("Couldn't find tech "..techName.." to hide.")
		return
	end
	Tech.forEachTechDifficulty(tech, function(td)
		td.enabled = false
		td.hidden = true
	end)
end

Tech.addTechDependency = function(firstTech, secondTech)
	local secondTechData = data.raw.technology[secondTech]
	if secondTechData == nil then
		log("ERROR: Couldn't find tech "..secondTech.." to add dependency "..firstTech.." to.")
		return
	end
	Tech.forEachTechDifficulty(secondTechData, function(td)
		if td.prerequisites == nil then
			td.prerequisites = {}
		end
		table.insert(td.prerequisites, firstTech)
	end)
end

Tech.tryAddTechDependency = function(firstTech, secondTech)
	if data.raw.technology[secondTech] ~= nil and data.raw.technology[firstTech] ~= nil then
		Tech.addTechDependency(firstTech, secondTech)
	end
end

Tech.copyCosts = function(firstTech, secondTech)
	local first = data.raw.technology[firstTech]
	local second = data.raw.technology[secondTech]
	second.unit = first.unit
	for _, val in pairs({"normal", "expensive"}) do
		if first[val] then
			second[val] = first[val]
		else
			second[val] = nil
		end
	end
end

Tech.setPrereqs = function(techName, prereqs)
	Tech.forEachTechDifficulty(data.raw.technology[techName], function(td)
		td.prerequisites = prereqs
	end)
end

Tech.replacePrereq = function(techName, oldPrereq, newPrereq)
	Tech.forEachTechDifficulty(
		data.raw.technology[techName],
		function(td)
			for i, prereq in pairs(td.prerequisites) do
				if prereq == oldPrereq then
					td.prerequisites[i] = newPrereq
					return
				end
			end
		end
	)
end

Tech.removePrereq = function(techName, oldPrereq)
	Tech.forEachTechDifficulty(
		data.raw.technology[techName],
		function(td)
			for i, prereq in pairs(td.prerequisites) do
				if prereq == oldPrereq then
					table.remove(td.prerequisites, i)
					return
				end
			end
		end
	)
end

Tech.removeRecipeFromTech = function(recipeName, techName)
	Tech.forEachTechDifficulty(
		data.raw.technology[techName],
		function(td)
			for i, effect in pairs(td.effects) do
				if effect.type == "unlock-recipe" and effect.recipe == recipeName then
					table.remove(td.effects, i)
					return
				end
			end
		end
	)
end

Tech.disable = function(techName)
	local tech = data.raw.technology[techName]
	if tech == nil then
		log("Couldn't find tech "..techName.." to disable.")
		return
	end
	Tech.forEachTechDifficulty(tech, function(td)
		td.enabled = false
		td.hidden = true
	end)
end

Tech.addEffect = function(tech, effect)
	Tech.forEachTechDifficulty(tech, function(td)
		if not td.effects then
			td.effects = {effect}
		else
			table.insert(td.effects, effect)
		end
	end)
end

Tech.addEvolutionEffect = function(techName, evolutionPercent)
	local tech = data.raw.technology[techName]
	if not tech then
		log("ERROR: Couldn't find tech "..techName.." to add evolution effect to. Tech: "..serpent.block(tech))
		return
	end

	local effect = {
		type = "nothing",
		icon = "__Desolation__/graphics/evolution.png",
		icon_size = 64,
		icon_mipmaps = 2,
		effect_description = {"effect-description.evolution", evolutionPercent},
			-- We use this localised string to store the evolution percent. Because there's no other way to store it on the tech, and I don't want to have like a file that gets imported in both the data and control stages.
	}
	Tech.addEffect(tech, effect)

	-- Add small icon in the corner of the tech.
	if tech.icons == nil then -- First, if it has one icon, switch to icons list.
		tech.icons = {{icon = tech.icon, icon_size = tech.icon_size, icon_mipmaps = tech.icon_mipmaps}}
	end
	table.insert(tech.icons, {
		icon = "__Desolation__/graphics/evolution-outlined.png",
		icon_size = 64,
		icon_mipmaps = 2,
		shift = {-90, 90},
	})
end

Tech.getPrereqList = function(tech)
	return tech.prerequisites or Table.maybeGet(tech.normal, "prerequisites") or Table.maybeGet(tech.expensive, "prerequisites") or {}
end

Tech.isEvolutionEffect = function(effect)
	return effect.type == "nothing" and effect.effect_description[1] == "effect-description.evolution"
end

Tech.getEvolutionPercent = function(tech)
	-- Given a tech, returns an int with the evolution percent from that tech's effects, or 0 if none.
	local effectList = tech.effects or Table.maybeGet(tech.normal, "effects") or Table.maybeGet(tech.expensive, "effects")
	if effectList == nil then return 0 end
	for _, effect in pairs(effectList) do
		if Tech.isEvolutionEffect(effect) then
			return effect.effect_description[2]
		end
	end
	return 0
end

Tech.getRecursivePrereqs = function(rootTechId)
	-- Given a tech ID, returns a set of tech IDs that are prereqs of that tech, or prereqs of its prereqs, etc.
	-- Returns nil if there's an error.
	local maxLoops = 10000
	local foundPrereqs = {} -- Set of prereqs, mapped to true.
	local frontier = {} -- List of tech IDs to check.
	-- Add initial prereqs
	for _, prereq in pairs(Tech.getPrereqList(data.raw.technology[rootTechId])) do
		table.insert(frontier, prereq)
	end
	local loops = 0 -- To prevent infinite loops.
	while #frontier > 0 do
		loops = loops + 1
		if loops > maxLoops then
			log("ERROR: Too many iterations when finding prereqs of tech "..rootTechId..".")
			return nil
		end
		local techId = table.remove(frontier)
		if techId == rootTechId then
			log("ERROR: Tech "..rootTechId.." has a prereq cycle.")
			return nil
		end
		if not foundPrereqs[techId] then
			foundPrereqs[techId] = true
			for _, prereq in pairs(Tech.getPrereqList(data.raw.technology[techId])) do
				table.insert(frontier, prereq)
			end
		end
	end
	return foundPrereqs
end

return Tech