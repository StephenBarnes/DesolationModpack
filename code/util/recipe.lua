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

return Recipe