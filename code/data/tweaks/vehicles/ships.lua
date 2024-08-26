-- This file tweaks the recipes for the ships from Cargo Ships, and the ironclad, and associated buildings (buoys and ports).

-- Recipe for the ironclad should be in the same row as cargo ships.
data.raw["item-with-entity-data"]["ironclad"].subgroup = data.raw["item-with-entity-data"]["cargo_ship"].subgroup

-- Adjust recipe for cargo ship, boat, ironclad
data.raw.recipe["cargo_ship"].ingredients = {
	{"computer-mk1", 1},
	{"engine-unit", 8},
	{"steel-plate-heavy", 40},
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

------------------------------------------------------------------------
-- Movement params

-- TODO


------------------------------------------------------------------------
-- Cargo ships mod makes pumps placeable on water, and changes their description to say that.
-- TODO fix that by adding the water collision layer back to them, and changing the description.