
local updates = {}
local nextOrder = 0

function getNextOrderString()
    nextOrder = nextOrder + 1
    return string.format("%04d", nextOrder)
end

function addSetting(name, default_value, type, stage)
    table.insert(updates, {
        type = type.."-setting",
        name = "Desolation-"..name,
        setting_type = stage,
        default_value = default_value,
		order = getNextOrderString(),
    })
end

addSetting("unminable-vehicles", true, "bool", "startup")

addSetting("modify-vehicle-inventories", true, "bool", "startup")
addSetting("inventory-size-monowheel", 2, "int", "startup")
addSetting("inventory-size-heavy-roller", 300, "int", "startup")
addSetting("inventory-size-heavy-picket", 400, "int", "startup")
addSetting("inventory-size-car", 40, "int", "startup")
addSetting("inventory-size-tank", 60, "int", "startup")
addSetting("inventory-size-hydrogen-airship", 20, "int", "startup")
addSetting("inventory-size-helium-airship", 40, "int", "startup")
addSetting("inventory-size-spidertron", 80, "int", "startup")
-- TODO instead of having each of these repeated here and then also in data.tweaks.vehicles, rather make a table in constants.vehicles or something, then require that here.

addSetting("modify-stack-sizes", true, "bool", "startup")
local tweakStackSizeItems = require("constants.stack-sizes")
for item, newStackSize in pairs(tweakStackSizeItems) do
	addSetting("stack-size-" .. item, newStackSize, "int", "startup")
end

data:extend(updates)