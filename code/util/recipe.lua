local Table = require("code.util.table")

local Recipe = {}

Recipe.setIngredients = function(recipeName, ingredients)
	local recipe = data.raw.recipe[recipeName]
	if recipe.normal ~= nil then
		recipe.normal.ingredients = ingredients
	end
	if recipe.expensive ~= nil then
		recipe.expensive.ingredients = ingredients
	end
	if recipe.normal == nil and recipe.expensive == nil then
		recipe.ingredients = ingredients
	end
end

Recipe.copyIngredients = function(firstRecipeName, secondRecipeName)
	local first = data.raw.recipe[firstRecipeName]
	local second = data.raw.recipe[secondRecipeName]
	if first.normal ~= nil then
		second.normal = Table.copy(first.normal)
	end
	if first.expensive ~= nil then
		second.expensive = Table.copy(first.expensive)
	end
	if first.normal == nil and first.expensive == nil then
		second.ingredients = Table.copy(first.ingredients)
	end
end

Recipe.addIngredients = function(recipeName, extraIngredients)
	local recipe = data.raw.recipe[recipeName]
	if recipe.normal ~= nil then
		Table.extend(recipe.normal.ingredients, extraIngredients)
	end
	if recipe.expensive ~= nil then
		Table.extend(recipe.expensive.ingredients, extraIngredients)
	end
	if recipe.normal == nil and recipe.expensive == nil then
		Table.extend(recipe.ingredients, extraIngredients)
	end
end

Recipe.copyIngredientsAndAdd = function(firstRecipeName, secondRecipeName, extraIngredients)
	Recipe.copyIngredients(firstRecipeName, secondRecipeName)
	Recipe.addIngredients(secondRecipeName, extraIngredients)
end

Recipe.removeIngredient = function(recipeName, ingredientName)
	local recipe = data.raw.recipe[recipeName]
	for i, ingredient in pairs(recipe.ingredients) do
		if ingredientName == (ingredient.name or ingredient[1]) then
			table.remove(recipe.ingredients, i)
			return
		end
	end
end

Recipe.substituteIngredientForDifficulty = function(recipeDifficulty, ingredientName, newIngredientName)
	for _, ingredient in pairs(recipeDifficulty.ingredients) do
		if ingredient.name ~= nil then
			if ingredientName == ingredient.name then
				ingredient.name = newIngredientName
				return
			end
		elseif ingredient[1] ~= nil then
			if ingredientName == ingredient[1] then
				ingredient[1] = newIngredientName
				return
			end
		end
	end
end

Recipe.substituteIngredient = function(recipeName, ingredientName, newIngredientName)
	local recipe = data.raw.recipe[recipeName]
	if recipe.normal ~= nil then
		Recipe.substituteIngredientForDifficulty(recipe.normal, ingredientName, newIngredientName)
	end
	if recipe.expensive ~= nil then
		Recipe.substituteIngredientForDifficulty(recipe.expensive, ingredientName, newIngredientName)
	end
	if recipe.normal == nil and recipe.expensive == nil then
		Recipe.substituteIngredientForDifficulty(recipe, ingredientName, newIngredientName)
	end
end

Recipe.setResults = function(recipeName, results)
	local recipe = data.raw.recipe[recipeName]
	if recipe.normal ~= nil then
		recipe.normal.results = results
	end
	if recipe.expensive ~= nil then
		recipe.expensive.results = results
	end
	if recipe.normal == nil and recipe.expensive == nil then
		recipe.results = results
	end
end

Recipe.getResults = function(recipe)
	local r = recipe.results or Table.maybeGet(recipe.normal, "results")
	if r ~= nil then return r end

	local singleResult = recipe.result or Table.maybeGet(recipe.normal, "result")
	if singleResult == nil then
		return {}
	else
		local singleResultAmount = recipe.result_count or Table.maybeGet(recipe.normal, "result_count")
		return {{singleResult, singleResultAmount}}
	end
end

Recipe.resultToName = function(result)
	-- Given an entry of format {itemName, amount}, or {type="fluid", name="fluidName", amount=amount}, return the name of the item.
	-- If the latter format, and type is "fluid", then prefix the name with "fluid:".
	-- Also works for entries of recipe.ingredients, and tech.unit.ingredients.
	local name = result.name or result[1]
	if result.type == "fluid" then
		return "fluid:"..name
	else
		return name
	end
end

Recipe.orderRecipes = function(recipeNames)
	local order = 1
	for _, recipeName in pairs(recipeNames) do
		local recipe = data.raw.recipe[recipeName]
		if recipe == nil then
			log("ERROR: Couldn't find recipe "..recipeName.." to order.")
			return
		end
		recipe.order = string.format("%02d", order)
		order = order + 1
	end
end

Recipe.hide = function(recipeName)
	local recipe = data.raw.recipe[recipeName]
	if recipe == nil then
		log("ERROR: Couldn't find recipe "..recipeName.." to hide.")
		return
	else
		if recipe.normal then -- Recipe has separate normal and expensive
			recipe.normal.hidden = true
			recipe.expensive.hidden = true
		else
			recipe.hidden = true
		end
	end
end


return Recipe