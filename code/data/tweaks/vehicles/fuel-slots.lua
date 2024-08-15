local function setFuel(type, name, slots, categories)
	local ent = data.raw[type][name]
	local toChange = ent.energy_source or ent.burner
	toChange.fuel_inventory_size = slots
	toChange.burnt_inventory_size = slots
	toChange.fuel_categories = categories
	toChange.fuel_category = nil
end

-- Light land vehicles
setFuel("car", "monowheel", 4, {"steam-cell"}) -- originally 1 slot and {"steam-cell", "canister", "barrel", "battery"}.
setFuel("car", "car", 4, {"canister", "barrel"}) -- originally 1 slot and {"steam-cell", "canister", "barrel", "battery"}.

-- Heavy vehicles
setFuel("car", "heavy-roller", 8,
	{"chemical", "coke", "steam-cell", "canister", "barrel"}) -- originally 1 slot, and {"steam-cell", "canister", "barrel", "battery"}.
setFuel("car", "tank", 8, {"canister", "barrel"}) -- originally 2 slots and {"steam-cell", "canister", "barrel", "battery"}.
setFuel("car", "heavy-picket", 8, {"battery"}) -- originally 3 slots and {"battery"}.

-- Ships and boats
setFuel("locomotive", "cargo_ship_engine", 10, {"chemical", "coke", "canister", "barrel", "battery"})
setFuel("locomotive", "boat_engine", 6, {"chemical", "coke", "canister", "barrel"})
setFuel("car", "indep-boat", 6, {"chemical", "coke", "canister", "barrel"})
setFuel("car", "ironclad", 6, {"canister", "barrel"})

-- Locomotives
setFuel("locomotive", "locomotive", 8, {"chemical", "coke", "steam-cell", "canister", "barrel", "battery"})
setFuel("locomotive", "meat:steam-locomotive", 6, {"chemical", "coke", "steam-cell",})
setFuel("locomotive", "meat:steam-locomotive-placement-entity", 6, {"chemical", "coke", "steam-cell"})

-- Airships
setFuel("spider-vehicle", "hydrogen-airship", 8, {"canister", "barrel"})
setFuel("spider-vehicle", "helium-airship", 8, {"canister", "barrel", "battery"})
