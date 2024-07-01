tech = {}

tech.addRecipeToTech = function(recipeName, techName)
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

tech.hideTech = function(techName)
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

tech.addTechDependency = function(firstTech, secondTech)
	table.insert(data.raw.technology[secondTech].prerequisites, firstTech)
end

tech.tryAddTechDependency = function(firstTech, secondTech)
	if data.raw.technology[secondTech] ~= nil and data.raw.technology[firstTech] ~= nil then
		tech.addTechDependency(firstTech, secondTech)
	end
end

tech.copyCosts = function(firstTech, secondTech)
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

tech.setPrereqs = function(techName, prereqs)
	data.raw.technology[techName].prerequisites = prereqs
end

return tech