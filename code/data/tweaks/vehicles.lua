local Settings = require("code.util.settings")

-- Tweak vehicle inventory sizes.
if Settings.startupSetting("modify-vehicle-inventories") then
	function setVehicleInventorySize(category, name)
		data.raw[category][name].inventory_size = Settings.startupSetting("inventory-size-"..name)
	end
	setVehicleInventorySize("car", "monowheel")
	setVehicleInventorySize("car", "heavy-roller")
	setVehicleInventorySize("car", "heavy-picket")
	setVehicleInventorySize("car", "car")
	setVehicleInventorySize("car", "tank")
	setVehicleInventorySize("spider-vehicle", "hydrogen-airship")
	setVehicleInventorySize("spider-vehicle", "helium-airship")
	setVehicleInventorySize("spider-vehicle", "spidertron")
	-- TODO do cargo ships
end

-- Make vehicles non-minable.
function setUnminable(category)
	for _, v in pairs(data.raw[category]) do
		v.minable = nil
	end
end
if settings.startup["Desolation-unminable-vehicles"] then
	setUnminable("car")
	setUnminable("spider-vehicle")
end
if settings.startup["Desolation-unminable-trains"] then
	setUnminable("locomotive")
	setUnminable("cargo-wagon")
	setUnminable("fluid-wagon")
end

-- TODO make vehicles more expensive to produce as well, like x10 cost, so you don't just place a new one every time.

-- TODO make it impossible to walk while you have a vehicle in your inventory! Check how it's done by mods like the radioactivity mod, or Ultracube.

-- TODO undo IR3's increase in cargo wagon inventory space.