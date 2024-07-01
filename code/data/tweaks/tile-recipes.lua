-- Increase cost of cliff explosives, landfill, waterfill.
-- TODO settings
function multiplyRecipeCosts(name, factor)
	local recipe = data.raw.recipe[name]
	for i = 1, #recipe.ingredients do
		if recipe.ingredients[i][2] ~= nil then
			recipe.ingredients[i][2] = recipe.ingredients[i][2] * factor
		else
			recipe.ingredients[i].amount = recipe.ingredients[i].amount * factor
		end
	end
end
multiplyRecipeCosts("landfill", 5)
multiplyRecipeCosts("cliff-explosives", 5)
-- TODO check - base mod has landfill from 15x gravel and 15x silica.
-- TODO rather just do this in Harder Basic Logistics, maybe.