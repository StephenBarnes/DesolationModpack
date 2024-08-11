local stackSizeCommon = require("code.common.stack-sizes")

-- Tweak stack sizes for ores etc.
if settings.startup["Desolation-modify-stack-sizes"] then
	for groupName, groupData in pairs(stackSizeCommon.stackSizeGroups) do
		local val = settings.startup["Desolation-stack-size-" .. groupName].value
		for _, item in pairs(groupData.items) do
			if data.raw.item[item] ~= nil then
				data.raw.item[item].stack_size = val
				data.raw.item[item].default_request_amount = val
			end
		end
	end
end

-- Tweak stack sizes for bundles.
local bundleFactor = 4 -- number of items in a bundle, defined by IR3.
for _, itemId in pairs(stackSizeCommon.bundleItems) do
	local baseItem = data.raw.item[itemId]
	if baseItem ~= nil then
		local stackedItemId = "stacked-"..itemId
		local stackedItem = data.raw.item[stackedItemId]
		if stackedItem ~= nil then
			stackedItem.stack_size = baseItem.stack_size / bundleFactor
			if baseItem.default_request_amount ~= nil then
				stackedItem.default_request_amount = baseItem.default_request_amount / bundleFactor
			else
				stackedItem.default_request_amount = baseItem.stack_size / bundleFactor
			end
		end
	end
end