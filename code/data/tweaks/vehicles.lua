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
local function setUnminable(category)
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

-- Make the big vehicles stronger.
data.raw.car["heavy-roller"].max_health = 1500 -- originally 700
data.raw.car["heavy-roller"].resistances = {
	{ type = "acid", decrease = 0, percent = 50 },
	{ type = "explosion", decrease = 10, percent = 75 },
	{ type = "fire", decrease = 0, percent = 75 },
	{ type = "impact", decrease = 0, percent = 100 }, -- TODO checking this
	{ type = "physical", decrease = 1, percent = 50 },
}
data.raw.car["heavy-picket"].max_health = 3000 -- originally 3000
data.raw.car["heavy-picket"].resistances = {
	{ type = "acid", decrease = 0, percent = 90 },
	{ type = "explosion", decrease = 10, percent = 75 },
	{ type = "fire", decrease = 0, percent = 75 },
	{ type = "impact", decrease = 0, percent = 100 }, -- TODO checking this
	{ type = "physical", decrease = 3, percent = 50 },
}

-- TODO maybe complete impact resistance for the heavy roller and picket?

-- TODO make vehicles more expensive to produce as well, like x10 cost, so you don't just place a new one every time.

-- TODO make it impossible to walk while you have a vehicle in your inventory! Check how it's done by mods like the radioactivity mod, or Ultracube.

-- TODO undo IR3's increase in cargo wagon inventory space.
-- TODO reduce vehicle inventory sizes more, bc I want to encourage containerization (like Freight Forwarding) and local processing. Should have like 4 slots in a train cargo wagon, but each could hold like 5x containers each with one stack of ore or whatever.

-- TODO increase the .weight of the heavy roller and picket, so they cause more damage to stuff they crash into.
-- TODO also try making them bigger? Could maybe just scale up the sprites and collision box by a factor of 2.
-- "immune to belts" -> "immune to belts, trees, rocks, walls, and other lesser vehicles. Unfortunately, its lack of weaponry and maneuverability make it less effective for mounting assaults on enemy nests."

-- Recipe for the ironclad should be in the same row as cargo ships.
data.raw["item-with-entity-data"]["ironclad"].subgroup = data.raw["item-with-entity-data"]["cargo_ship"].subgroup