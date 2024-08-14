-- This file tweaks land vehicles in several ways.
-- Also the heavy picket, which can travel on water.

local Vehicle = require("code.data.tweaks.vehicles.util")

-- Idea: make it impossible to walk while you have a vehicle in your inventory? Check how it's done by mods like the radioactivity mod, or Ultracube.
-- If you do this, could make vehicles more expensive to produce as well, like x10 cost, so you don't just place a new one every time.
-- Deciding against this because it would be somewhat annoying.

-- Adjusting vehicle health and resistances.
data.raw.car["heavy-roller"].max_health = 2000 -- originally 700
data.raw.car["heavy-roller"].resistances = {
	{ type = "acid", decrease = 0, percent = 50 },
	{ type = "explosion", decrease = 10, percent = 75 },
	{ type = "fire", decrease = 0, percent = 75 },
	{ type = "impact", decrease = 0, percent = 95 },
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
data.raw.car["monowheel"].max_health = 500 -- originally 250
data.raw.car["monowheel"].resistances = {
	{ type = "fire", decrease = 0, percent = 75 }, -- originally 0, 75
	{ type = "impact", decrease = 0, percent = 60 }, -- originally 0, 25; increasing so it's not so easy to wreck, especially since I'm increasing its speed.
}

-- Adjusting vehicle weights, fuel consumption, etc.
-- Reference for weights: car is 700 and tank is 20,000.
data.raw.car["heavy-roller"].weight = 30000 -- originally 12,500
data.raw.car["heavy-roller"].consumption = "400kW" -- originally 300kW
data.raw.car["heavy-roller"].braking_power = "3000kW" -- originally 600kW
data.raw.car["heavy-roller"].rotation_speed = 0.003 -- originally 0.0035
data.raw.car["heavy-roller"].friction = 0.003 -- originally 0.002
data.raw.car["heavy-picket"].weight = 15000 -- originally 12,500
data.raw.car["heavy-picket"].consumption = "4000kW" -- originally 500kW
data.raw.car["heavy-picket"].braking_power = "15000kW" -- originally 1500kW
data.raw.car["heavy-picket"].rotation_speed = 0.005 -- originally 0.005
data.raw.car["heavy-picket"].friction = 0.0003 -- originally 0.00125
data.raw.car["monowheel"].weight = 500 -- originally 800; I think it should be less than a car.
data.raw.car["monowheel"].consumption = "100kW" -- originally 125kW
data.raw.car["monowheel"].braking_power = "100kW" -- originally 100kW
data.raw.car["monowheel"].rotation_speed = 0.01 -- originally 0.01
data.raw.car["monowheel"].friction = 0.0013 -- originally 0.00175
-- TODO other vehicles

-- TODO make heavy vehicles ignore terrain speed! So that heavy roller is good on the frigid terrain.

-- Set fuel slots and categories.
Vehicle.setFuel("car", "heavy-roller", 8,
	{"chemical", "coke", "steam-cell", "canister", "barrel"}) -- originally 1 slot, and {"steam-cell", "canister", "barrel", "battery"}.
Vehicle.setFuel("car", "heavy-picket", 8, {"battery"}) -- originally 3 slots and {"battery"}.
Vehicle.setFuel("car", "monowheel", 4, {"steam-cell"}) -- originally 1 slot and {"steam-cell", "canister", "barrel", "battery"}.
-- TODO other vehicles

-- TODO make the monowheel faster? Maybe halve the weight?