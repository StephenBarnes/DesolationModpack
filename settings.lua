local updates = {
    {
        type = "bool-setting",
        name = "TweaksForIR3-unminable-vehicles",
        setting_type = "startup",
        default_value = true,
		order = "0-1"
    },
    {
        type = "bool-setting",
        name = "TweaksForIR3-modify-vehicle-inventories",
        setting_type = "startup",
        default_value = true,
		order = "1-1"
    },
    {
        type = "bool-setting",
        name = "TweaksForIR3-modify-stack-sizes",
        setting_type = "startup",
        default_value = true,
		order = "2-1"
    },
}

function addStartupIntSetting(name, default_value, order)
	table.insert(updates, {
        type = "int-setting",
        name = name,
        setting_type = "startup",
        default_value = default_value,
		order = order
    })
end

addStartupIntSetting("TweaksForIR3-inventory-size-monowheel", 2, "1-2")
addStartupIntSetting("TweaksForIR3-inventory-size-heavy-roller", 300, "1-2")
addStartupIntSetting("TweaksForIR3-inventory-size-heavy-picket", 400, "1-2")
addStartupIntSetting("TweaksForIR3-inventory-size-car", 40, "1-2")
addStartupIntSetting("TweaksForIR3-inventory-size-tank", 60, "1-2")
addStartupIntSetting("TweaksForIR3-inventory-size-hydrogen-airship", 20, "1-2")
addStartupIntSetting("TweaksForIR3-inventory-size-helium-airship", 40, "1-2")
addStartupIntSetting("TweaksForIR3-inventory-size-spidertron", 80, "1-2")

local tweakStackSizeItems = require("stack-sizes")
for item, newStackSize in pairs(tweakStackSizeItems) do
	addStartupIntSetting("TweaksForIR3-stack-size-" .. item, newStackSize, "2-2")
end

data:extend(updates)