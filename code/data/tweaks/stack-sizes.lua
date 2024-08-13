local T = require("code.util.table")

-- This file applies the stack size groups in common/stack-sizes.lua to item prototypes.
-- This is done in both data-updates and data-final-fixes stages.
-- Notes re staging:
-- * Most of the stack size changes are in data-updates, so that they can be used by other mods that create recipes, e.g. Intermodal Containers and Production Scrap.
-- * A few of the stack size changes are in data-final-fixes because their items are only created in that stage. Currently this is only the searchlights.
-- * The Searchlight Assault mod creates boosted ammo items in final-fixes stage. We change ammo stack sizes in data-updates stage, and the boosted ammo items copy our altered stack sizes.

local stackSizeCommon = require("code.common.stack-sizes")

local function adjustBundles()
	-- Tweak stack sizes for bundles.
	local bundleFactor = 4 -- number of items in a bundle, defined by IR3.
	for _, itemId in pairs(stackSizeCommon.bundleItems) do
		local baseItem = data.raw.item[itemId]
		if baseItem == nil then
			log("Warning: base item "..itemId.." not found, could not adjust stack size.")
		else
			local stackedItemId = "stacked-"..itemId
			local stackedItem = data.raw.item[stackedItemId]
			if stackedItem == nil then
				log("Warning: stacked item "..stackedItemId.." not found, could not adjust stack size.")
			else
				stackedItem.stack_size = baseItem.stack_size / bundleFactor
				if baseItem.default_request_amount ~= nil then
					stackedItem.default_request_amount = baseItem.default_request_amount / bundleFactor
				else
					stackedItem.default_request_amount = baseItem.stack_size / bundleFactor
				end
			end
		end
	end
end

local function adjustForStage(stage)
	-- Tweak stack sizes for ores etc.
	-- Stage is either "data-updates" or "data-final-fixes".
	if settings.startup["Desolation-modify-stack-sizes"] then
		for groupName, groupData in pairs(stackSizeCommon.stackSizeGroups) do
			local val = settings.startup["Desolation-stack-size-" .. groupName].value
			local itemList
			if stage == "data-updates" then
				itemList = groupData.items
			else
				itemList = groupData.dataFinalFixesItems
			end
			if itemList == nil then return end
			for _, itemSpecifier in pairs(itemList) do
				local item
				if type(itemSpecifier) == "string" then
					item = data.raw.item[itemSpecifier]
					if item == nil then item = data.raw["item-with-entity-data"][itemSpecifier] end
				else
					item = T.maybeGet(data.raw[itemSpecifier[1]], itemSpecifier[2])
				end
				if item == nil then
					log("Warning: item "..serpent.line(itemSpecifier).." not found, could not adjust stack size.")
				else
					item.stack_size = val
					item.default_request_amount = val
				end
			end
		end
	end

	if stage == "data-updates" then
		adjustBundles()
	end
end

return adjustForStage