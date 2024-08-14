local Settings = require("code.util.settings")

-- Tweak vehicle inventory sizes.
if Settings.startupSetting("modify-vehicle-inventories") then
	function setVehicleInventorySize(category, name, settingName)
		settingName = settingName or name
		data.raw[category][name].inventory_size = Settings.startupSetting("inventory-size-"..settingName)
	end
	setVehicleInventorySize("cargo-wagon", "cargo-wagon")
	setVehicleInventorySize("cargo-wagon", "cargo_ship", "cargo-ship")

	setVehicleInventorySize("car", "monowheel")
	setVehicleInventorySize("car", "heavy-roller")
	setVehicleInventorySize("car", "heavy-picket")
	setVehicleInventorySize("car", "car")
	setVehicleInventorySize("car", "tank")
	setVehicleInventorySize("spider-vehicle", "hydrogen-airship")
	setVehicleInventorySize("spider-vehicle", "helium-airship")
	setVehicleInventorySize("spider-vehicle", "spidertron")
	setVehicleInventorySize("car", "indep-boat", "boat")
	setVehicleInventorySize("cargo-wagon", "boat")
	setVehicleInventorySize("car", "ironclad")
end