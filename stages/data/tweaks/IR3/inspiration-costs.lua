-- IR3 Inspiration mod doesn't change inspiration costs with the tech multiplier (and I can't think of any way to make it do that, even if I modified its code) so instead we change the cost of all of them.
-- This is necessary because eg I want the starting junkpiles to give you plates, which would otherwise trigger inspirations.
-- Note we don't need to increase these dramatically, just enough to make the starting junkpiles not cause inspirations, I think.

local inspirationAmountMultiplier = 5 -- TODO make this a setting

local function shouldChangeTech(techName, techData)
	-- Seems there's 2 types: IR_schematic_proxy = string (representing item that needs to be obtained), and IR_schematic_parents (ie it's discovered when its prereqs are discovered). For the latter, we don't need to change the cost.
	_ = techName
	return techData.IR_schematic_proxy ~= nil
end

local function changeTechDifficulty(techName, techDifficulty)
	if techDifficulty.unit == nil then
		log("ERROR: inspiration tech difficulty "..techName.." has no unit")
		return
	end
	if #techDifficulty.unit.ingredients ~= 1 then
		log("ERROR: inspiration tech difficulty "..techName.." has "..#techDifficulty.unit.ingredients.." ingredients, not expected")
		return
	end
	local ingredient = techDifficulty.unit.ingredients[1]
	if ingredient.type ~= nil then
		ingredient.amount = ingredient.amount * inspirationAmountMultiplier
	else
		ingredient[2] = ingredient[2] * inspirationAmountMultiplier
	end
end

local function changeTech(techName)
	local tech = data.raw["technology"][techName]
	if tech == nil then
		log("ERROR: inspiration tech "..techName.." not found")
		return
	end
	if tech.normal ~= nil then
		changeTechDifficulty(techName.."--normal", tech.normal)
	end
	if tech.expensive ~= nil then
		changeTechDifficulty(techName.."--expensive", tech.expensive)
	end
	if tech.normal == nil and tech.expensive == nil then
		changeTechDifficulty(techName, tech)
	end
end

local inspirationGlobals = require("__IndustrialRevolution3Inspiration__/data/globals")
--log("Inspiration global standard unlock size: "..inspirationGlobals.standard_unlock_size)
for techName, techData in pairs(inspirationGlobals.technologies) do
	if shouldChangeTech(techName, techData) then
		changeTech(techName)

		-- We could change the data in Inspiration's table, but that doesn't actually propagate to the event handler that uses it.
		-- Maybe we could rather do this in control?
		-- techData.IR_schematic_count_needed = techData.IR_schematic_count_needed * inspirationAmountMultiplier
	end
end
-- NOTE currently this code changes the icon, but the tech is still unlocked at the original amount of items. Not sure if that's fixable.