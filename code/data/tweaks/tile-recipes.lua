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

-- TODO rather custom-tune the recipe costs of these. The above code was written before I decided to actually try hard with this modpack.

-- Remove cliff explosives, since there's no cliffs.
local Tech = require("code.util.tech")
Tech.removeRecipeFromTech("cliff-explosives", "explosives")