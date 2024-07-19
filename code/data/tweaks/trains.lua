-- A few tweaks to trains.

-- Adjust locomotives.
local steamLocomotive = data.raw.locomotive["meat:steam-locomotive"]
local steelLocomotive = data.raw.locomotive.locomotive
-- Add description to explain the differences.
steamLocomotive.localised_description = {"", {"entity-description.locomotive"}, {"entity-description.steam-locomotive-extra"}}
steelLocomotive.localised_description = {"", {"entity-description.locomotive"}, {"entity-description.steel-locomotive-extra"}}
-- Stats changes
steamLocomotive.max_power = "200kW" -- vs 600kW for steel locomotive.
steamLocomotive.energy_source.effectivity = 0.7 -- vs 1.0 for steel locomotive.
steamLocomotive.max_health = 800 -- vs 1000 for steel locomotive.

-- Make all locomotives unminable.
-- For cargo wagons, I'm leaving them minable.
steamLocomotive.minable = nil
steelLocomotive.minable = nil

-- Disable fluid wagons. I'm rather using barrels.
data.raw.recipe["fluid-wagon"].hidden = true
