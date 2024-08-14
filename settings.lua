local updates = {}
local nextOrder = 0

function getNextOrderString()
    nextOrder = nextOrder + 1
    return string.format("%03d", nextOrder)
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

addSetting("complex-sliders", false, "bool", "startup")

addSetting("remove-mapgen-presets", true, "bool", "startup")

addSetting("unminable-vehicles", false, "bool", "startup")
addSetting("unminable-trains", false, "bool", "startup")

addSetting("modify-vehicle-inventories", true, "bool", "startup")

addSetting("inventory-size-cargo-wagon", 10, "int", "startup")
addSetting("inventory-size-cargo-ship", 80, "int", "startup")

addSetting("inventory-size-monowheel", 2, "int", "startup")
addSetting("inventory-size-heavy-roller", 200, "int", "startup")
addSetting("inventory-size-heavy-picket", 200, "int", "startup")
addSetting("inventory-size-car", 10, "int", "startup")
addSetting("inventory-size-tank", 10, "int", "startup")
addSetting("inventory-size-hydrogen-airship", 5, "int", "startup")
addSetting("inventory-size-helium-airship", 10, "int", "startup")
addSetting("inventory-size-spidertron", 10, "int", "startup")
addSetting("inventory-size-boat", 10, "int", "startup")
addSetting("inventory-size-ironclad", 10, "int", "startup")

addSetting("modify-stack-sizes", true, "bool", "startup")
local stackSizeGroups = require("code.common.stack-sizes").stackSizeGroups
for groupName, groupData in pairs(stackSizeGroups) do
	addSetting("stack-size-" .. groupName, groupData.defaultStackSize, "int", "startup")
end

data:extend(updates)