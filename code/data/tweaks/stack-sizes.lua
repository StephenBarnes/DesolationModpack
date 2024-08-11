-- Tweak stack sizes for ores etc.
if settings.startup["Desolation-modify-stack-sizes"] then
	local stackSizeGroups = require("code.common.stack-sizes")
	for groupName, groupData in pairs(stackSizeGroups) do
		local val = settings.startup["Desolation-stack-size-" .. groupName].value
		for _, item in pairs(groupData.items) do
			if data.raw.item[item] ~= nil then
				data.raw.item[item].stack_size = val
				data.raw.item[item].default_request_amount = val
			end
		end
	end
end