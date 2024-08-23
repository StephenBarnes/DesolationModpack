-- This file defines stack sizes of various groups of items.
-- General philosophy is that items should have higher stack sizes as they get more processed, to incentivise local processing.
-- Also, we want to make it hard to move around things like buildings and vehicles.

-- Note this file doesn't filter for existing items, bc we need to use it in settings stage.
-- For example, we could have stuff like "lead-rod" here, even though they don't exist in IR3.

local rawMaterials = {
	"copper-ore", "tin-ore", "gold-ore", "uranium-ore", "iron-ore", "coal", "stone",
	"wood", "rubber-wood",
	"ice", "comet-ice-ore",
	"spagyric-crystal",
}
local crushedMaterials = {
	"copper-crushed", "tin-crushed", "gold-crushed", "iron-crushed",
	"gravel", "silica",
	"carbon-crushed", -- This ID is used for crushed coal.
	"wood-chips",
	"ruby-powder", "diamond-powder",
	"copper-scrap", "tin-scrap", "iron-scrap", "steel-scrap", "bronze-scrap", "lead-scrap", "gold-scrap", "glass-scrap", "concrete-scrap", "brass-scrap",
}
local purifiedMaterials = {
	"copper-pure", "tin-pure", "iron-pure", "gold-pure", "lead-pure", "chromium-pure", "nickel-pure", "platinum-pure",

	"sulfur",
	"uranium-235", "uranium-238",
	"diamond-gem", "ruby-gem", "electrum-gem", "electrum-gem-charged",
	{"tool", "elixir-stone"},
	"silicon", "graphite", "silicon-block",
	"low-density-structure", -- IR3 uses this ID for steel foam. It's next to silicon and graphite and silicon-block (silicon carbide block), so putting it here.
	"rubber",
	"charcoal",
	"graphitic-coke",
	"solid-fuel", -- This ID is used for coke.
}
local standardizedIngotsBricks = {
	"copper-ingot", "tin-ingot", "iron-ingot", "steel-ingot", "bronze-ingot", "lead-ingot", "nickel-ingot", "chromium-ingot", "gold-ingot", "platinum-ingot", "brass-ingot",
	"stone-brick", "concrete-block",
	"plastic-bar",
	"glass", "nanoglass",
	"bitumen",
}
local smallItems = {
	"copper-plate", "tin-plate", "iron-plate", "steel-plate", "bronze-plate", "lead-plate", "gold-plate", "chromium-plate", "brass-plate",
	"electrum-plate", "electrum-plate-special",
	"bronze-plate-heavy", "iron-plate-heavy", "steel-plate-heavy", "chromium-plate-heavy",
	"copper-rivet", "bronze-rivet", "iron-rivet", "steel-rivet", "chromium-rivet",
	"copper-pellet", "bronze-pellet", "iron-pellet", "steel-pellet", "nickel-pellet", "platinum-pellet",
	"copper-cable", "tin-cable", "gold-cable",
	"copper-cable-heavy",
	"copper-foil", "gold-foil",
	"electrum-foil", -- Field-effect nano mesh.
	"carbon-foil", -- Graphene.
	"copper-rod", "tin-rod", "bronze-rod", "iron-stick", "steel-rod", "chromium-rod",
	"copper-gear-wheel", "tin-gear-wheel", "iron-gear-wheel", "steel-gear-wheel", "brass-gear-wheel",

	"red-wire", "green-wire",
	"electronic-circuit", "advanced-circuit", "processing-unit",
	"diamond-gear-wheel",
	"carbon-filter",

	"copper-gate", -- thermionic tube
	"gold-gate", -- semiconducting triode
	"electrum-gate", -- miniaturized gate array

	"battery", "charged-battery", "advanced-battery", "charged-advanced-battery",
	"hydrogen-battery", "charged-hydrogen-battery", -- Physically it might make more sense to categorize these as canisters? But that throws off per-stack fuel values.
	-- TODO fully analyze all forms of power storage and transport (all batteries, canisters, barrels, etc.) to ensure the tradeoffs are reasonable.
}
local bulkyItems = {
	"copper-piston", "iron-piston", "steel-piston", "chromium-piston",
	"junction-box", "copper-coil", "carbon-coil",

	"wood-beam", "copper-beam", "bronze-beam", "iron-beam", "steel-beam", "chromium-beam",

	"lead-plate-special", -- Radiation shielding
	"steel-hull", -- Hull section, used for rocket parts and satellites.
	"rocket-part", -- I don't think this is obtainable on its own, but including here anyway.
	"field-effector",

	"copper-motor", "iron-motor", "copper-rotor", "iron-rotor",
	"flying-robot-frame", -- IR3 uses this ID for the advanced (steel) rotor unit.

	"engine-unit", "copper-engine-unit", "chromium-engine-unit", "electric-engine-unit",
	"gyroscope",

	{"module", "speed-module"}, {"module", "speed-module-2"}, {"module", "speed-module-3"},
	{"module", "effectivity-module"}, {"module", "effectivity-module-2"}, {"module", "effectivity-module-3"},
	{"module", "productivity-module"}, {"module", "productivity-module-2"}, {"module", "productivity-module-3"},
	"computer-mk1", "computer-mk2", "computer-mk3",

	"ic-container",

	{"repair-tool", "copper-repair-tool"},
	{"repair-tool", "bronze-repair-tool"},
	{"repair-tool", "repair-pack"},
	{"repair-tool", "steel-repair-tool"},

	"copper-frame-small", "iron-frame-small", "steel-frame-small", "chromium-frame-small",

	"uranium-fuel-cell", "used-up-uranium-fuel-cell",

	"solar-panel-equipment", "fusion-reactor-equipment", "battery-equipment", "battery-mk2-equipment", "belt-immunity-equipment", "exoskeleton-equipment", "personal-roboport-equipment", "personal-roboport-mk2-equipment", "night-vision-equipment", "energy-shield-equipment", "energy-shield-mk2-equipment", "personal-laser-defense-equipment", "discharge-defense-equipment",
	"battery-discharge-equipment", "iron-burner-generator-equipment", "copper-roboport-equipment", "arc-turret-equipment",

	"space-mirror",
	"glass-bottle",
	"rocket-control-unit",
	"solar-subassembly",
	"explosives",

	"land-mine",

	"copper-heatsink", "graphite-electrode",
	"ruby-rod", "ruby-laser", "helium-laser",

	{"capsule", "ln-flare-capsule"},
	{"capsule", "ocean-scanner"},

	{"tool", "automation-science-pack"},
	{"tool", "logistic-science-pack"},
	{"tool", "chemical-science-pack"},
	{"tool", "military-science-pack"},
	{"tool", "production-science-pack"},
	{"tool", "utility-science-pack"},
	{"tool", "space-science-pack"},
}
local veryBulkyItems = {
	"copper-frame-large", "iron-frame-large", "steel-frame-large", "chromium-frame-large",
	"steel-frame-turret", "chromium-frame-turret",
	"solar-assembly", -- Used to make satellites.
	"quantum-ring",
}
local extraBigBuildings = {
	"chrome-drill",
	"quantum-lab",
	"oil-refinery", "chemical-plant",
	"nuclear-reactor",
	"bridge_base", -- Lifting train bridge from Cargo Ships mod. I've disabled this.

	-- Not actually buildings, but probably roughly the same size.
	"quantum-satellite",
	"satellite", -- Called "cosmic analysis satellite" in IR3.
}
local bigBuildings = {
	"ic-containerization-machine-1", "ic-containerization-machine-2", "ic-containerization-machine-3",
	"roboport",
	"electric-mining-drill",
	"pumpjack",
	"bronze-forestry", "iron-forestry", "chrome-forestry",
	"stone-furnace", "stone-alloy-furnace", "stone-charcoal-kiln",
	"bronze-furnace", "bronze-alloy-furnace",
	"electric-furnace", "electric-alloy-furnace",
	"steel-furnace", -- Gas furnace.
	"blast-furnace",
	"arc-furnace",
	"copper-grinder", "iron-grinder", "steel-grinder",
	"iron-mixer", "steel-mixer",
	"steel-washer",
	"iron-geothermal-exchanger",
	"chrome-press",
	"assembling-machine-1", "assembling-machine-2", "assembling-machine-3", "laser-assembler",
	"iron-scrapper",
	"steel-electroplater",
	"copper-lab", "lab",
	"rocket-silo",
	"steam-engine",
	"solar-array",
	"petro-generator",
	"iron-battery-charger", "steel-battery-charger",
	"iron-battery-discharger", "steel-battery-discharger",
	"supermagnet",
	"aai-signal-sender", "aai-signal-receiver", -- Radio towers.
	"air-purifier",
	"steel-cryo-tower",
	"steam-turbine",
	"centrifuge",
	"artillery-turret", "flamethrower-turret",
	"long-range-delivery-drone-depot",
}
local mediumBuildings = {
	"substation",
	"storage-tank",
	"chrome-transmat", "cargo-transmat",
	"airship-station",
	"robotower",
	"burner-mining-drill", "steam-drill", -- These are 7x7, vs the electric and chrome ones which are 9x9 or 11x11 and therefore placed in bigBuildings.
	"copper-derrick", "steel-derrick",
	"beacon", "beacon2-item",
	"long-range-delivery-drone-request-depot",
	"solar-panel",
	"accumulator",
	"deadlock-large-lamp", "deadlock-floor-lamp",
	"iron-ice-melter", "boiler",
	"copper-ice-melter", "electric-ice-melter",
	"copper-boiler", "steel-boiler",
	"heat-exchanger",
	"radar", "bronze-telescope",
	"seismic-scanner",
	"photon-turret", "rocket-turret", "laser-turret", "scattergun-turret", "arc-turret", "gun-turret",
}
local smallBuildings = {
	"wood-pallet", "tin-pallet", "wooden-chest", "tin-chest", "bronze-chest", "iron-chest", "steel-chest",
	"transfer-plate", "transfer-plate-2x2",
	"pit", "bottomless-pit",
	"underground-belt", "fast-underground-belt", "express-underground-belt",
	"splitter", "fast-splitter", "express-splitter",
	"ir3-loader-steam", "ir3-loader", "ir3-fast-loader", "ir3-express-loader",
	"ir3-beltbox-steam", "ir3-beltbox", "ir3-fast-beltbox", "ir3-express-beltbox",
	"burner-inserter", "steam-inserter", "inserter", "slow-filter-inserter", "fast-inserter", "filter-inserter", "stack-inserter", "stack-filter-inserter",
	"long-handed-inserter", "long-handed-steam-inserter",
	"small-electric-pole", "small-bronze-pole", "small-iron-pole", "medium-electric-pole", "big-wooden-pole", "big-electric-pole", "floating-electric-pole",
	"small-tank-steam", "small-tank",
	"copper-pump", "offshore-pump", "pump",
	"train-stop",
	"rail-signal", "rail-chain-signal",
	"port", "buoy", "chain_buoy",
	"logistic-chest-active-provider", "logistic-chest-passive-provider", "logistic-chest-requester", "logistic-chest-storage", "logistic-chest-buffer",
	"arithmetic-combinator", "decider-combinator", "constant-combinator", "power-switch", "programmable-speaker",
	"deadlock-copper-lamp", "copper-aetheric-lamp-straight", "small-lamp",
	"steel-cleaner", -- Polluted water cleaner.
	"small-assembler-1", "small-assembler-2", "small-assembler-3",
	"steel-cast", -- Metal cast machine
	"module-loader",
	"steam-barrelling-machine", "barrelling-machine",
	"iron-gas-vent", "air-compressor",
	"steel-vaporiser",
	"waterfill-explosive",
	"stone-wall", "gate", "steel-plate-wall", "concrete-wall",

	-- Planning to remove most of these tree types, maybe replace with Alien Biomes trees.
	"tree-planter-tree-01", "tree-planter-tree-02", "tree-planter-tree-03", "tree-planter-tree-04", "tree-planter-tree-05", "tree-planter-tree-07", "tree-planter-tree-09",
	"tree-planter-ir-rubber-tree",
}
local tinyPlaced = {
	"transport-belt", "fast-transport-belt", "express-transport-belt",
	"heat-pipe",
	"copper-pipe", "copper-valve", "copper-pipe-to-ground", "copper-pipe-to-ground-short",
	"steam-pipe", "steam-valve", "steam-pipe-to-ground", "steam-pipe-to-ground-short",
	"pipe", "valve", "pipe-to-ground", "pipe-to-ground-short",
	"air-pipe", "air-valve", "air-pipe-to-ground", "air-pipe-to-ground-short",
	{"rail-planner", "rail"},
}
local vehicles = {
	"meat:steam-locomotive-item", "locomotive", "cargo-wagon", "artillery-wagon",
	"fluid-wagon", "indep-boat", "boat_engine", "cargo_ship_engine", "oil_tanker",
	"meat:sheet-metal-cargo-wagon",
	"boat", "cargo_ship", "ironclad",
	"monowheel", "heavy-roller", "heavy-picket",
	"car", "tank",
	"hydrogen-airship", "helium-airship",
	"spidertron",
	"long-range-delivery-drone", -- The Long-Range Delivery Drone mod sets stack size of this to 1, so maybe it needs the stack size to be 1.
}
local robots = {
	"steambot", "construction-robot", "logistic-robot",
	{"capsule", "lampbot-capsule"},
}
local tiles = {
	"landfill",
	"concrete", "refined-concrete",
	"hazard-concrete", "refined-hazard-concrete",
	"tarmac",
}
local canisters = {
	"empty-canister", "empty-iron-canister", "hydrogen-canister", "oxygen-canister", "nitrogen-canister", "helium-canister", "carbon-canister", "natural-canister", "steam-iron-canister", "petroleum-gas-iron-canister", 
	"steam-cell", "empty-cell",
	"rocket-fuel", -- IR3 uses this for high-octane fuel.
	"nuclear-fuel", -- Not obtainable in IR3, but including here anyway.
}
local barrels = {
	"empty-barrel", "water-barrel", "sulfuric-acid-barrel", "crude-oil-barrel", "heavy-oil-barrel", "light-oil-barrel", "petroleum-gas-barrel", "lubricant-barrel", "dirty-water-barrel", "concrete-fluid-barrel", "ethanol-barrel", "liquid-fertiliser-barrel", "bitumen-fluid-barrel", "chromium-plating-solution-barrel", "gold-plating-solution-barrel"
}
local shotgunAmmo = {
	{"ammo", "shotgun-shell"}, -- This is the normal copper cartridge.
	{"ammo", "bronze-cartridge"},
	{"ammo", "iron-cartridge"},
	{"ammo", "piercing-shotgun-shell"}, -- This is the steel cartridge.
}
local submachineGunAmmo = {
	{"ammo", "firearm-magazine"}, -- This is the normal iron magazine.
	{"ammo", "piercing-rounds-magazine"}, -- This is the steel magazine.
	{"ammo", "chromium-magazine"},
	{"ammo", "uranium-rounds-magazine"},
}
local bigAmmo = {
	{"ammo", "flamethrower-ammo"},
	{"ammo", "rocket"},
	{"ammo", "explosive-rocket"},
	{"ammo", "atomic-bomb"},
	{"ammo", "cannon-shell"},
	{"ammo", "explosive-cannon-shell"},
	{"ammo", "explosive-uranium-cannon-shell"},
	{"ammo", "uranium-cannon-shell"},
	{"ammo", "artillery-shell"},
	{"ammo", "atomic-artillery-shell"},
	{"ammo", "mortar-bomb"},
	{"ammo", "mortar-cluster-bomb"},
}
local grenades = {
	{"capsule", "grenade"},
	{"capsule", "cluster-grenade"},
	{"capsule", "poison-capsule"},
	{"capsule", "slowdown-capsule"},
}
local robotCapsules = {
	{"capsule", "defender-capsule"},
	{"capsule", "distractor-capsule"},
	{"capsule", "destroyer-capsule"},
	{"capsule", "scatterbot-capsule"},
}
local healingItems = {
	{"capsule", "raw-fish"},
	{"capsule", "medical-pack"},
}

-- Define stackSizeGroups, table mapping group name to: {
--    defaultStackSize = d,
--    items = {a, b, c}, -- Items whose stack sizes should be changed in data-updates stage.
--    dataFinalFixesItems = {a, b, c}, -- Items whose stack sizes should be changed in data-final-fixes stage.
-- }
-- Note these are also used in the names of settings.
local stackSizeGroups = {
	raw = {
		defaultStackSize = 40,
		items = rawMaterials,
	},
	crushed = {
		defaultStackSize = 60,
		items = crushedMaterials,
	},
	purified = {
		defaultStackSize = 80,
		items = purifiedMaterials,
	},
	standardizedIngotsBricks = {
		defaultStackSize = 120,
			-- Should be divisible by 4, so that bundling recipes have round numbers.
		items = standardizedIngotsBricks,
	},
	smallItems = {
		defaultStackSize = 80,
		items = smallItems,
	},
	bulkyItems = {
		defaultStackSize = 40,
		items = bulkyItems,
	},
	veryBulkyItems = {
		defaultStackSize = 20,
		items = veryBulkyItems,
	},
	tinyPlaced = {
		defaultStackSize = 100,
		items = tinyPlaced,
	},
	smallBuildings = {
		defaultStackSize = 40,
		items = smallBuildings,
	},
	mediumBuildings = {
		defaultStackSize = 20,
		items = mediumBuildings,
		dataFinalFixesItems = {"searchlight-assault"},
	},
	bigBuildings = {
		defaultStackSize = 10,
		items = bigBuildings,
	},
	extraBigBuildings = {
		defaultStackSize = 5,
		items = extraBigBuildings,
	},
	robots = {
		defaultStackSize = 40, -- In vanilla, this is 50.
		items = robots,
	},
	vehicles = {
		defaultStackSize = 1,
		items = vehicles,
	},
	tiles = {
		defaultStackSize = 100,
		items = tiles,
	},
	canisters = {
		defaultStackSize = 10, -- This is 10 in base IR3.
		items = canisters,
	},
	barrels = {
		defaultStackSize = 10, -- This is 10 in base IR3.
		items = barrels,
	},
	shotgunAmmo = {
		defaultStackSize = 20,
		items = shotgunAmmo,
	},
	submachineGunAmmo = {
		defaultStackSize = 20,
		items = submachineGunAmmo,
	},
	bigAmmo = {
		defaultStackSize = 10,
		items = bigAmmo,
	},
	grenades = {
		defaultStackSize = 20,
		items = grenades,
	},
	robotCapsules = {
		defaultStackSize = 20,
		items = robotCapsules,
	},
	healingItems = {
		defaultStackSize = 20,
		items = healingItems,
	},
}

return {
	stackSizeGroups = stackSizeGroups,
}