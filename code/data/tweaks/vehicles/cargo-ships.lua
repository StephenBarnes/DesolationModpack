

-- Recipe for the ironclad should be in the same row as cargo ships.
data.raw["item-with-entity-data"]["ironclad"].subgroup = data.raw["item-with-entity-data"]["cargo_ship"].subgroup

-- Make the boat and the ironclad faster
data.raw.car["ironclad"].consumption = "2.2MW" -- Default is 1.1MW
data.raw.car["indep-boat"].consumption = "600kW" -- Default is 300kW
data.raw.locomotive["boat_engine"].max_power = "600kW" -- Default is 300kW

-- TODO make all the ships accept more fuel types. Currently it's only burnable stuff, should also allow canisters etc.

-- Adjust recipe for cargo ship, boat, ironclad
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
data.raw.recipe["ironclad"].ingredients = {
	{"electronic-circuit", 4},
	{"engine-unit", 8},
	{"steel-plate-heavy", 40},
	{"steel-beam", 10},
}

-- Adjust recipes for port, signal buoys, and chain buoys
data.raw.recipe["port"].ingredients = {
	{"steel-beam", 2},
	{"steel-rivet", 2},
	{"electronic-circuit", 1},
}
data.raw.recipe["buoy"].ingredients = { -- signal buoy
	{"steel-rod", 2},
	{"steel-rivet", 1},
	{"steel-plate", 2},
	{"electronic-circuit", 1},
}
data.raw.recipe["chain_buoy"].ingredients = { -- signal buoy
	{"steel-rod", 2},
	{"steel-rivet", 1},
	{"steel-plate", 2},
	{"electronic-circuit", 1},
}
data.raw.recipe["port"].energy_required = 5
data.raw.recipe["buoy"].energy_required = 5
data.raw.recipe["chain_buoy"].energy_required = 5

data.raw.recipe["mortar-bomb"].ingredients = {
	{"explosives", 2},
	{"steel-plate", 4},
}