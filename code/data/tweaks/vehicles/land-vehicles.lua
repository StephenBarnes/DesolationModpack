-- This file tweaks land vehicles in several ways.
-- Also the heavy picket, which can travel on water.

-- Idea: make it impossible to walk while you have a vehicle in your inventory? Check how it's done by mods like the radioactivity mod, or Ultracube.
-- If you do this, could make vehicles more expensive to produce as well, like x10 cost, so you don't just place a new one every time.
-- Deciding against this because it would be somewhat annoying.

-- Make the big vehicles stronger.
data.raw.car["heavy-roller"].max_health = 2000 -- originally 700
data.raw.car["heavy-roller"].resistances = {
	{ type = "acid", decrease = 0, percent = 50 },
	{ type = "explosion", decrease = 10, percent = 75 },
	{ type = "fire", decrease = 0, percent = 75 },
	{ type = "impact", decrease = 0, percent = 100 },
	{ type = "physical", decrease = 1, percent = 50 },
}
data.raw.car["heavy-picket"].max_health = 4000 -- originally 3000
data.raw.car["heavy-picket"].resistances = {
	{ type = "acid", decrease = 0, percent = 90 },
	{ type = "explosion", decrease = 10, percent = 75 },
	{ type = "fire", decrease = 0, percent = 75 },
	{ type = "impact", decrease = 0, percent = 100 },
	{ type = "physical", decrease = 3, percent = 50 },
}

-- Could increase the .weight of the heavy roller and picket, so they cause more damage to stuff they crash into.
-- But they're already 12,500, while the car is 700 and tank is 20,000.
-- Ok, let's increase their weights, and also their fuel consumption. Makes sense with how big their inventories are.
data.raw.car["heavy-roller"].weight = 30000 -- originally 12,500
data.raw.car["heavy-roller"].consumption = "400kW" -- originally 300kW
data.raw.car["heavy-roller"].braking_power = "3000kW" -- originally 600kW
data.raw.car["heavy-picket"].weight = 15000 -- originally 12,500
data.raw.car["heavy-picket"].consumption = "4000kW" -- originally 500kW
data.raw.car["heavy-picket"].braking_power = "15000kW" -- originally 1500kW

-- Increase the number of fuel slots.
local function setFuelSlots(category, name, amount)
	data.raw[category][name].burner.fuel_inventory_size = amount
	data.raw[category][name].burner.burnt_inventory_size = amount
end
setFuelSlots("car", "heavy-roller", 4) -- originally 1
setFuelSlots("car", "heavy-picket", 6) -- originally 3
-- TODO other vehicles

-- Fuel types
data.raw.car["monowheel"].burner.fuel_categories = {"steam-cell"} -- Originally had steam-cell, canister, barrel, battery.
data.raw.car["heavy-roller"].burner.fuel_categories = {"steam-cell", "canister", "barrel"} -- Originally also had "battery", but I'm removing that.
-- 

-- Rotation speed, top speed, etc.
data.raw.car["heavy-roller"].rotation_speed = 0.003 -- originally 0.0035
data.raw.car["heavy-roller"].friction = 0.003 -- originally 0.002
data.raw.car["heavy-picket"].rotation_speed = 0.005 -- originally 0.005
data.raw.car["heavy-picket"].friction = 0.0003 -- originally 0.00125
-- TODO make both of these ignore terrain speed! So that heavy roller is good on the frigid terrain.
-- TODO other vehicles

-- TODO make the monowheel faster? Maybe halve the weight?