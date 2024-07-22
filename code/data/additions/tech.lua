-- This file adds new science packs and their recipes, and also changes many parts of the tech tree, eg tech dependencies and their unlocks.

-- Several reasons:
-- * Move various techs around to different places, to fit with the new progression introduced by the modpack, eg geothermal energy should come early.
-- * Compat between the various mods. Eg we want to insert steam locomotives and cargo ships in the right places.
-- * Add more complexity in early game, by introducing multiple science packs early on.
-- * We want to avoid "dead ends" in the tech tree, because evolution depends on techs.
-- * Consolidate techs somewhat, since techs are so expensive. Eg I don't want to have a separate tech for each tier of IR3 stacking beltbox, or containerization machine, or AAI loader.

local Tech = require("code.util.tech")
local Recipe = require("code.util.recipe")

-- Glass bottle recipe unlocked by tech glass working (ir-glass-milestone).
Tech.addRecipeToTech("glass-bottle", "ir-glass-milestone")

-- Needed because I want the stacking beltboxes to be ordered correctly.
-- Also, IR3 changes things so that logistics-2 is no longer a prereq for things like cars, like it is in vanilla.
Tech.addTechDependency("automation-2", "logistics-2")

-- I'm using IR3's tech ir-inserters-3 (stack inserters) as "Robotics 3". That's a dead end, so let's switch some prereqs from ir-electronics-3 to ir-inserters-3.
Tech.replacePrereq("rocket-silo", "ir-electronics-3", "ir-inserters-3")
Tech.replacePrereq("ir-mining-2", "ir-electronics-3", "ir-inserters-3")

-- To avoid telescopes being a dead end, I'm renaming the tech to "viewfinders" and adding as prereq to military (which is a prereq of autogun turrets).
--Tech.addTechDependency("ir-bronze-telescope", "military")
-- Actually, rather renaming it to "optics", and then making it a prereq of electric lamps.
Tech.addTechDependency("ir-bronze-telescope", "optics")

-- Night-vision shouldn't depend on electric lighting, and should be pretty easy to get early on.
Tech.setPrereqs("night-vision-equipment", {"modular-armor"})

-- To avoid heavy roller and heavy armor from being dead ends, I'm going to merge them into the bronze furnace tech.
-- Also move the heavy bronze plate recipe, since that makes sense thematically, though it's breaking with all the other material milestone techs.
Tech.addTechDependency("ir-monowheel", "ir-bronze-furnace")
Tech.addRecipeToTech("bronze-plate-heavy", "ir-bronze-furnace", 1)
Tech.removeRecipeFromTech("bronze-plate-heavy", "ir-bronze-milestone")
Tech.addRecipeToTech("heavy-roller", "ir-bronze-furnace")
Tech.hideTech("ir-heavy-roller")
Tech.addRecipeToTech("heavy-armor", "ir-bronze-furnace")
Tech.hideTech("heavy-armor")

-- Change clockwork scatterbot to depend on the new heavy bronze plate tech.
Tech.replacePrereq("ir-scatterbot", "ir-bronze-milestone", "ir-bronze-furnace")
-- Add prereq on telescope, since it makes logical sense.
Tech.addTechDependency("ir-bronze-telescope", "ir-scatterbot")

-- Make scatterbots and lampbots not dead ends.
Tech.addTechDependency("ir-scatterbot", "ir-lampbot")
Tech.addTechDependency("ir-lampbot", "defender")

-- Add forestry => advanced forestry, to avoid a dead end. Except at the chrome forestry - not sure how to prevent that while still being plausible.
Tech.addTechDependency("ir-bronze-forestry", "ir-iron-forestry")
Tech.addTechDependency("ir-iron-forestry", "ir-chrome-forestry")

-- Add logistics-3 as prereq for some higher-tier stuff, to avoid dead end.
Tech.addTechDependency("logistics-3", "logistic-system")

-- Move petrochemical generator to crude oil processing, bc it's a dead end.
-- Also add dependency combustion engine => crude oil processing, bc combustion engine is needed to make the petrochemical generator.
Tech.hideTech("ir-petro-generator")
Tech.addTechDependency("engine", "ir-crude-oil-processing")
Tech.addRecipeToTech("petro-generator", "ir-crude-oil-processing")

-- Radar is a dead end. We could remove it, eg:
-- Tech.addTechDependency("ir-radar", "ir-robotower")
-- But, I don't think this is actually necessary - surely nobody's going to continue using telescopes into late-game, and if they do, alright, they can get a reduction in evolution.

-- There's several other dead ends that I think are actually fine, because forgoing them could be fun and deserves a reward in lowered evolution. Namely:
-- Autogun turret
-- Fluid wagon
-- Helium airship, and airship station
-- Heavy picket
-- Land-mine
-- Geothermal exchange (once I buff geothermal energy)
-- Barrelling
-- Medical pack

-- Move light armor to the new "self-defense" tech.
Tech.addRecipeToTech("light-armor", "ir-blunderbuss")
Tech.removeRecipeFromTech("light-armor", "ir-tin-working-2")

-- Remove unwanted cargo ships techs: oversea energy distribution, train bridges, tanker ship
data.raw.technology["oversea-energy-distribution"] = nil
data.raw.technology["automated_bridges"] = nil
data.raw.technology["tank_ship"] = nil
data.raw.technology["cargo_ships"] = nil
data.raw.technology["water_transport_signals"] = nil
-- Move cargo ships, buoys, ports all to the same tech.
Tech.addRecipeToTech("cargo_ship", "automated_water_transport", 1)
Tech.addRecipeToTech("buoy", "automated_water_transport")
Tech.addRecipeToTech("chain_buoy", "automated_water_transport")
-- TODO check ingredients

Tech.addTechDependency("ir-radar", "automated_water_transport")

-- Rename landfill tech to earthworks, and move it to be after explosives, and before automated shipping.
Tech.addTechDependency("explosives", "landfill")
Tech.addTechDependency("landfill", "automated_water_transport")
Tech.removeRecipeFromTech("waterfill-explosive", "explosives")
Tech.addRecipeToTech("waterfill-explosive", "landfill")

data.raw.technology["fluid-wagon"] = nil
data.raw.technology["automated-rail-transportation"].enabled = false
Tech.removeRecipeFromTech("meat:sheet-metal-cargo-wagon", "meat:steam-locomotion-technology")
Tech.addRecipeToTech("train-stop", "meat:steam-locomotion-technology")
Tech.addRecipeToTech("rail-signal", "meat:steam-locomotion-technology")
Tech.addRecipeToTech("rail-chain-signal", "meat:steam-locomotion-technology")
--Tech.addRecipeToTech("rail", "meat:steam-locomotion-technology")
Tech.addRecipeToTech("cargo-wagon", "meat:steam-locomotion-technology")
Tech.removeRecipeFromTech("cargo-wagon", "railway")
Tech.removeRecipeFromTech("rail", "railway")
Tech.addTechDependency("ir-iron-milestone", "meat:steam-locomotion-technology")
Tech.addTechDependency("meat:steam-locomotion-technology", "railway")
-- TODO check ingredients

Tech.addTechDependency("ir-bronze-telescope", "radar")

-- Geothermal and electric derrick
data.raw.technology["ir-steel-derrick"].prerequisites = {"fluid-handling"}
data.raw.technology["ir-geothermal-exchange"].prerequisites = {"ir-steel-derrick"}
data.raw.recipe["steel-derrick"].ingredients = {{"pipe", 8}, {"iron-plate-heavy", 4}, {"iron-beam", 8}, {"iron-piston", 4}} -- Changed steel->iron, and reduced amounts.
data.raw.recipe["iron-geothermal-exchanger"].ingredients = {{"iron-frame-small", 1}, {"pump", 1}, {"steam-pipe", 6}, {"pipe", 4}} -- Changed to include pump

if false then
	Tech.addTechDependency("ir-scatterbot", "military")
	Tech.addTechDependency("ir-heavy-roller", "ir-heavy-picket")
	Tech.addTechDependency("ir-heavy-picket", "spidertron")
	Tech.addTechDependency("land-mine", "military-3")
	Tech.addTechDependency("ir-bronze-telescope", "gun-turret")
	Tech.addTechDependency("ir-steambot", "personal-roboport-equipment")
	Tech.addTechDependency("ir-petro-generator", "ir-petroleum-processing")
	Tech.addTechDependency("plastics-2", "logistics-3")
	Tech.addTechDependency("logistics-3", "automation-4")
	Tech.addTechDependency("effect-transmission", "ir-transmat")
	Tech.addTechDependency("ir-geothermal-exchange", "ir-mining-2")
	Tech.addTechDependency("ir-barrelling", "ir-high-pressure-canisters")
	Tech.tryAddTechDependency("ir-barrelling", "oversea-energy-distribution")
	Tech.tryAddTechDependency("ir-steel-milestone", "automated-water-transport")
end
-- TODO more of these?
-- TODO review all of these, make sure they're sensible.
