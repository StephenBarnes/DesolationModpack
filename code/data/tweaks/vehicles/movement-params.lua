-- This file tweaks the movement parameters for vehicles.

-- Reference for weights: car is 700 and tank is 20,000.

data.raw.car["heavy-roller"].weight = 30000 -- originally 12,500
data.raw.car["heavy-roller"].consumption = "400kW" -- originally 300kW
data.raw.car["heavy-roller"].braking_power = "3000kW" -- originally 600kW
data.raw.car["heavy-roller"].rotation_speed = 0.003 -- originally 0.0035
data.raw.car["heavy-roller"].friction = 0.003 -- originally 0.002
-- TODO make heavy roller ignore terrain speed, so it's good on the frigid terrain.

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

-- Boats
data.raw.car["ironclad"].consumption = "2.2MW" -- Default is 1.1MW
data.raw.car["indep-boat"].consumption = "600kW" -- Default is 300kW
data.raw.locomotive["boat_engine"].max_power = "600kW" -- Default is 300kW

-- TODO other vehicles