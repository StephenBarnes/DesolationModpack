
local inspirationAmountMultiplier = 5 -- TODO make this a setting

local inspirationGlobals = require("__IndustrialRevolution3Inspiration__/data/globals")

-- Change the data in Inspiration's table. Might propagate to the event handlers in Inspiration, TODO test.
for techName, techData in pairs(inspirationGlobals.technologies) do
	if techData.IR_schematic_count_needed ~= nil then
		local newTechData = {}
		for k, v in pairs(techData) do
			newTechData[k] = v
		end
		newTechData.IR_schematic_count_needed = 2 -- techData.IR_schematic_count_needed * inspirationAmountMultiplier
		inspirationGlobals.technologies[techName] = newTechData
	end
end