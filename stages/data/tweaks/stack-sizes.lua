-- Tweak stack sizes for ores etc.
if settings.startup["Desolation-modify-stack-sizes"] then
	local tweakStackSizeItems = require("constants.stack-sizes")
	for item, _ in pairs(tweakStackSizeItems) do
		local val = settings.startup["Desolation-stack-size-" .. item].value
		data.raw.item[item].stack_size = val
		data.raw.item[item].default_request_amount = val
	end
end