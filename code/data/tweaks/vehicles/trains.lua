-- A few tweaks to trains.

local Recipe = require("code.util.recipe")

-- Adjust locomotives.
local steamLocomotive = data.raw.locomotive["meat:steam-locomotive"]
local steamLocomotive2 = data.raw.locomotive["meat:steam-locomotive-placement-entity"] -- Edit this as well, so the item correctly shows the stats.
local steelLocomotive = data.raw.locomotive.locomotive
-- Add description to explain the differences.
steamLocomotive.localised_description = {"", {"entity-description.locomotive"}, {"entity-description.steam-locomotive-extra"}}
steamLocomotive2.localised_description = {"", {"entity-description.locomotive"}, {"entity-description.steam-locomotive-extra"}}
steelLocomotive.localised_description = {"", {"entity-description.locomotive"}, {"entity-description.steel-locomotive-extra"}}
-- Stats changes
steamLocomotive.max_power = "200kW" -- vs 600kW for steel locomotive.
steamLocomotive2.max_power = "200kW"
steamLocomotive.energy_source.effectivity = 0.7 -- vs 1.0 for steel locomotive.
steamLocomotive2.energy_source.effectivity = 0.7
steamLocomotive.max_health = 800 -- vs 1000 for steel locomotive.
steamLocomotive2.max_health = 800

-- Make all locomotives unminable.
-- For cargo wagons, I'm leaving them minable.
-- TODO we have those settings, rather make this depend on that.
steamLocomotive.minable = nil
steamLocomotive2.minable = nil
steelLocomotive.minable = nil

-- Disable fluid wagons. I'm rather using barrels.
data.raw.recipe["fluid-wagon"].hidden = true

Recipe.orderRecipes{"rail", "train-stop", "rail-signal", "rail-chain-signal", "meat:steam-locomotive-recipe", "locomotive", "cargo-wagon", "artillery-wagon", "chrome-transmat", "cargo-transmat"}

-- Adjust the recipe for the steam locomotive.
Recipe.setIngredients("meat:steam-locomotive-recipe", {
	{"copper-engine-unit", 1},
	{"steam-pipe", 16},
	{"iron-plate-heavy", 16},
	{"iron-beam", 4},
	{"iron-piston", 8},
})