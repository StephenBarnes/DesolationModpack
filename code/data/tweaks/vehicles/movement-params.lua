-- This file tweaks the movement parameters for vehicles.

-- Reference for weights: car is 700 and tank is 20,000.

data.raw.car["heavy-roller"].weight = 30000 -- originally 12,500
data.raw.car["heavy-roller"].consumption = "400kW" -- originally 300kW
data.raw.car["heavy-roller"].braking_power = "600kW" -- originally 600kW. Can't be adjusted too much, or the vehicle can't reverse - seems pressing S both brakes and accelerates backwards at the same time, or something.
data.raw.car["heavy-roller"].rotation_speed = 0.003 -- originally 0.0035
data.raw.car["heavy-roller"].friction = 0.003 -- originally 0.002
-- TODO make heavy roller ignore terrain speed, so it's good on the frigid terrain.

data.raw.car["heavy-picket"].weight = 10000 -- originally 12,500
data.raw.car["heavy-picket"].consumption = "3000kW" -- originally 500kW
data.raw.car["heavy-picket"].braking_power = "10000kW" -- originally 1500kW
data.raw.car["heavy-picket"].rotation_speed = 0.005 -- originally 0.005
data.raw.car["heavy-picket"].friction = 0.0003 -- originally 0.00125

data.raw.car["monowheel"].weight = 500 -- originally 800; I think it should be less than a car.
data.raw.car["monowheel"].consumption = "100kW" -- originally 125kW
data.raw.car["monowheel"].braking_power = "100kW" -- originally 100kW
data.raw.car["monowheel"].rotation_speed = 0.01 -- originally 0.01
data.raw.car["monowheel"].friction = 0.0013 -- originally 0.00175

-- Boats
data.raw.car["ironclad"].consumption = "2.2MW" -- Default is 1.1MW
data.raw.car["indep-boat"].consumption = "600kW" -- Default is 300kW
data.raw.locomotive["boat_engine"].max_power = "600kW" -- Default is 300kW
-- adjust speed of boat, ironclad, and cargo ships. I think cargo ships should be very slow, like airships.

-- Airships
-- I want to make both of these slower, especially the hydrogen airship, so that there's more benefit to upgrading to helium.
-- Note looks like IR3-Airships is setting vehicle speed using "stickers", which were originally intended for eg when a worm-turret spits at you.
-- Seems the stickers' vehicle_speed_modifier is very non-linear. I think it's because of how the invisible legs work.
data.raw["sticker"]["hydrogen-airship-flight-speed"].vehicle_speed_modifier = 0.2 -- originally 0.5
data.raw["sticker"]["helium-airship-flight-speed"].vehicle_speed_modifier = 0.4 -- originally 0.55
-- Changing the leg length, initial_movement_speed, or movement_acceleration doesn't seem to have any effect.
-- To make the legs visible:
--data.raw["spider-leg"]["helium-airship-leg"].graphics_set = data.raw["spider-leg"]["spidertron-leg-1"].graphics_set
--data.raw["spider-leg"]["hydrogen-airship-leg"].graphics_set = data.raw["spider-leg"]["spidertron-leg-1"].graphics_set
-- With the vehicle_speed_modifiers above set to small values, the airships sometimes get stuck. Seems to happen because there's only 1 leg, and it gets stuck. So add more legs.
local function makeLeg(name, pos)
	return {
		leg = name .. "-leg",
		mount_position = {0, 0},
		ground_position = pos,
		blocking_legs = {},
	}
end
local legDist = 3
for _, name in pairs({"helium-airship", "hydrogen-airship"}) do
	data.raw["spider-vehicle"][name].spider_engine.legs = {
		makeLeg(name, {-legDist, 0}),
		makeLeg(name, {legDist, 0}),
		makeLeg(name, {0, -legDist}),
		makeLeg(name, {0, legDist}),
	}
end

-- TODO other vehicles?