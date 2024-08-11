local stackSizeCommon = require("code.common.stack-sizes")

-- Tweak stack sizes for ores etc.
if settings.startup["Desolation-modify-stack-sizes"] then
	for groupName, groupData in pairs(stackSizeCommon.stackSizeGroups) do
		local val = settings.startup["Desolation-stack-size-" .. groupName].value
		for _, itemSpecifier in pairs(groupData.items) do
			local item
			if type(itemSpecifier) == "string" then
				item = data.raw.item[itemSpecifier]
				if item == nil then item = data.raw["item-with-entity-data"][itemSpecifier] end
			else
				item = data.raw[itemSpecifier[1]][itemSpecifier[2]]
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