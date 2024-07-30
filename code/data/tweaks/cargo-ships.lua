

-- Recipe for the ironclad should be in the same row as cargo ships.
data.raw["item-with-entity-data"]["ironclad"].subgroup = data.raw["item-with-entity-data"]["cargo_ship"].subgroup

-- Make the boat and the ironclad faster
data.raw.car["ironclad"].consumption = "2.2MW" -- Default is 1.1MW
data.raw.car["indep-boat"].consumption = "600kW" -- Default is 300kW
data.raw.locomotive["boat_engine"].max_power = "600kW" -- Default is 300kW

-- TODO make the boat and ironclad accept more fuel types

-- Adjust recipe for cargo ships
data.raw.recipe["cargo_ship"].ingredients = {
	{"telemetry-unit", 1},
	{"engine-unit", 8},
	{"steel-plate", 40},
	{"steel-plate-heavy", 20},
	{"steel-beam", 20},
}

data.raw.recipe["boat"].ingredients = {
	{"electronic-circuit", 4},
	{"engine-unit", 4},
	{"steel-plate", 20},
	{"steel-plate-heavy", 8},
	{"steel-beam", 8},
}

-- TODO adjust recipes for boat, ironclad, port, signal buoys.
