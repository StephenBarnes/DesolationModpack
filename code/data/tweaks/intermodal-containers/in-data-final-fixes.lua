-- This file adjusts how the packing recipes from the Intermodal Containers mod work.
-- These are only changes that need to happen in data-final-fixes stage, so that we can copy existing recipes.

local bundleItems = require("code.common.bundle-items")

newData = {}
for _, itemId in pairs(bundleItems) do
	-- Add recipes to pack bundled ingots into containers, producing the ingot container.
	local packBundledIngotsRecipe = table.deepcopy(data.raw.recipe["ic-load-"..itemId])
	packBundledIngotsRecipe.name = "ic-load-stacked-"..itemId
	packBundledIngotsRecipe.icons[3].icon = data.raw.item["stacked-"..itemId].icons[1].icon
	packBundledIngotsRecipe.localised_name = {"stacking.pack-bundles", {"item-name."..itemId}}
	packBundledIngotsRecipe.ingredients[2] = {"stacked-"..itemId, math.floor(packBundledIngotsRecipe.ingredients[2][2] / 4)}
	packBundledIngotsRecipe.order = packBundledIngotsRecipe.order .. "_"
	table.insert(newData, packBundledIngotsRecipe)

	-- Add recipes to unpack ingot containers to produce bundled ingots.
	local unpackBundledIngotsRecipe = table.deepcopy(data.raw.recipe["ic-unload-"..itemId])
	unpackBundledIngotsRecipe.name = "ic-unload-stacked-"..itemId
	unpackBundledIngotsRecipe.icons[3].icon = data.raw.item["stacked-"..itemId].icons[1].icon
	unpackBundledIngotsRecipe.localised_name = {"stacking.unpack-to-bundles", {"item-name."..itemId}}
	unpackBundledIngotsRecipe.results[2] = {"stacked-"..itemId, math.floor(unpackBundledIngotsRecipe.results[2][2] / 4)}
	unpackBundledIngotsRecipe.order = unpackBundledIngotsRecipe.order .. "_"
	table.insert(newData, unpackBundledIngotsRecipe)
end
data:extend(newData)