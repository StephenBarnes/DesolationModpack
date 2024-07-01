Tech = {}

Tech.addRecipeToTech = function(recipeName, techName)
	local unlock = {
		type = "unlock-recipe",
		recipe = recipeName,
	}
	local tech = data.raw.technology[techName]
	if not tech.effects then
		tech.effects = {unlock}
	else
		table.insert(tech.effects, unlock)
	end
end

Tech.hideTech = function(techName)
	local tech = data.raw.technology[techName]
	if tech == nil then
		log("Couldn't find tech "..techName.." to hide.")
		return
	end
	if tech.normal then
		tech.normal.enabled = false
		tech.normal.hidden = true
	end
	if tech.expensive then
		tech.expensive.enabled = false
		tech.expensive.hidden = true
	end
	tech.enabled = false
	tech.hidden = true
end

Tech.addTechDependency = function(firstTech, secondTech)
	table.insert(data.raw.technology[secondTech].prerequisites, firstTech)
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
	data.raw.technology[techName].prerequisites = prereqs
end

Tech.replacePrereqForDifficulty = function(techDifficulty, oldPrereq, newPrereq)
	for i, prereq in pairs(techDifficulty.prerequisites) do
		if prereq == oldPrereq then
			techDifficulty.prerequisites[i] = newPrereq
			return
		end
	end
end

Tech.replacePrereq = function(techName, oldPrereq, newPrereq)
	local tech = data.raw.technology[techName]
	if tech.normal ~= nil then
		Tech.replacePrereqForDifficulty(tech.normal, oldPrereq, newPrereq)
	end
	if tech.expensive ~= nil then
		Tech.replacePrereqForDifficulty(tech.expensive, oldPrereq, newPrereq)
	end
	if tech.normal == nil and tech.expensive == nil then
		Tech.replacePrereqForDifficulty(tech, oldPrereq, newPrereq)
	end
end

return Tech