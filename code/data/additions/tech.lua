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
Tech.addRecipeToTech("petro-generator", "ir-crude-oil-processing", 1)

-- Radar is a dead end. We could remove it, eg:
-- Tech.addTechDependency("ir-radar", "ir-robotower")
-- But, I don't think this is actually necessary - surely nobody's going to continue using telescopes into late-game, and if they do, alright, they can get a reduction in evolution.

-- There's several other dead ends that I think are actually fine, because forgoing them could be fun and deserves a reward in lowered evolution. Namely:
-- Autogun turret
-- Fluid wagon
-- Helium airship, and airship station
-- Heavy picket
-- Land-mine
-- Medical pack

-- Move light armor to the new "self-defense" tech.
Tech.addRecipeToTech("light-armor", "ir-blunderbuss")
Tech.removeRecipeFromTech("light-armor", "ir-tin-working-2")

-- Remove unwanted cargo ships techs: oversea energy distribution, train bridges, tanker ship
Tech.disable("oversea-energy-distribution")
Tech.disable("automated_bridges")
Tech.disable("tank_ship")
Tech.disable("cargo_ships")
Tech.disable("water_transport_signals")
-- Move cargo ships, buoys, ports all to the same tech.
Tech.addRecipeToTech("cargo_ship", "automated_water_transport", 1)
Tech.addRecipeToTech("buoy", "automated_water_transport")
Tech.addRecipeToTech("chain_buoy", "automated_water_transport")
data.raw.technology["water_transport"].prerequisites = {"ir-steel-milestone"}
data.raw.technology["automated_water_transport"].prerequisites = {"water_transport", "ir-radar"}
-- TODO check ingredients

-- Rename landfill tech to earthworks, and add waterfill explosive.
-- Want to place it before automated shipping, but not after explosives. So also change recipe to not require explosives.
data.raw.technology["landfill"].prerequisites = {"automated_water_transport"}
Tech.removeRecipeFromTech("waterfill-explosive", "explosives")
Tech.addRecipeToTech("waterfill-explosive", "landfill")
data.raw.recipe["waterfill-explosive"].ingredients = {{"copper-gate", 1}, {"wooden-chest", 1}, {"solid-fuel", 4}}

Tech.disable("fluid-wagon")
Tech.disable("automated-rail-transportation")
Tech.removeRecipeFromTech("meat:sheet-metal-cargo-wagon", "meat:steam-locomotion-technology")
Tech.addRecipeToTech("train-stop", "meat:steam-locomotion-technology")
Tech.addRecipeToTech("rail-signal", "meat:steam-locomotion-technology")
Tech.addRecipeToTech("rail-chain-signal", "meat:steam-locomotion-technology")
--Tech.addRecipeToTech("rail", "meat:steam-locomotion-technology")
Tech.addRecipeToTech("cargo-wagon", "meat:steam-locomotion-technology")
Tech.removeRecipeFromTech("cargo-wagon", "railway")
Tech.removeRecipeFromTech("rail", "railway")
Tech.addTechDependency("ir-iron-milestone", "meat:steam-locomotion-technology")
--Tech.addTechDependency("meat:steam-locomotion-technology", "railway")
data.raw.technology["railway"].prerequisites = {"meat:steam-locomotion-technology", "engine", "ir-steel-milestone"}
data.raw.recipe["locomotive"].ingredients = {{"computer-mk1", 1}, {"engine-unit", 1}, {"steel-rod", 4}, {"steel-plate-heavy", 8}, {"steel-gear-wheel", 8}}

-- TODO check ingredients

Tech.addTechDependency("ir-bronze-telescope", "ir-radar")

-- Geothermal and electric derrick
data.raw.technology["ir-steel-derrick"].prerequisites = {"fluid-handling"}
data.raw.technology["ir-geothermal-exchange"].prerequisites = {"ir-steel-derrick"}
data.raw.recipe["steel-derrick"].ingredients = {{"pipe", 8}, {"iron-plate-heavy", 4}, {"iron-beam", 8}, {"iron-piston", 4}} -- Changed steel->iron, and reduced amounts.
data.raw.recipe["iron-geothermal-exchanger"].ingredients = {{"iron-frame-small", 1}, {"pump", 1}, {"steam-pipe", 6}, {"pipe", 4}} -- Changed to include pump

data.raw.technology["optics"].prerequisites = {"ir-steam-power"} -- Depend only on electricity, not surveying.

-- Remove all the series of techs, bc they don't fit well into the system of evolution being dependent on tech level.
local techSeriesToDisable = {
	["physical-projectile-damage"] = {1, 2, 3, 4, 5, 6, 7},
	["stronger-explosives"] = {1, 2, 3, 4, 5, 6, 7},
	["artillery-shell-range"] = {1},
	["artillery-shell-speed"] = {1},
	["follower-robot-count"] = {1, 2, 3, 4, 5, 6, 7},
	["ir-photon-turret-damage"] = {1, 2, 3, 4},
	["refined-flammables"] = {1, 2, 3, 4, 5, 6, 7},
	["mining-productivity"] = {1, 2, 3, 4},
	["energy-weapons-damage"] = {1, 2, 3, 4, 5, 6, 7},
	["worker-robots-speed"] = {1, 2, 3, 4, 5, 6},
	["weapon-shooting-speed"] = {1, 2, 3, 4, 5, 6},
	["laser-shooting-speed"] = {1, 2, 3, 4, 5, 7},
	["braking-force"] = {1, 2, 3},
	["research-speed"] = {1, 2, 3, 4, 5, 6},
}
for techName, techNums in pairs(techSeriesToDisable) do
	if data.raw.technology[techName] ~= nil then
		Tech.disable(techName)
	end
	for _, techNum in pairs(techNums) do
		Tech.disable(techName.."-"..techNum)
	end
end
-- TODO maybe put some of these bonuses back, but into regular techs, not these weird incremental bonus techs.

-- Previously ir-research-2 (Improved laboratories 2) depended on research-speed-6, but we removed that tech.
data.raw.technology["ir-research-2"].prerequisites = {"ir-force-fields", "ir-research-1"}

-- Ironclad: remove duplicate dependency on explosives (since military-2 already depends on it).
data.raw.technology["ironclad"].prerequisites = {"military-2", "automobilism"}

-- Add boats=>pumpjacks dependency, bc it makes sense with this progression, and it ensures Ironclad is indirectly dependent on boats.
--Tech.addTechDependency("water_transport", "ir-pumpjacks")
-- Actually, rather don't.
Tech.addTechDependency("water_transport", "ironclad")

Tech.addTechDependency("ir-barrelling", "ir-high-pressure-canisters")
Tech.addTechDependency("ir-geothermal-exchange", "ir-mining-2")
Tech.addTechDependency("effect-transmission", "ir-transmat")

Tech.addTechDependency("belt-immunity-equipment", "power-armor")
Tech.addTechDependency("night-vision-equipment", "power-armor")

Tech.removeRecipeFromTech("mortar-cluster-bomb", "ironclad")
Tech.addRecipeToTech("mortar-cluster-bomb", "military-4")
Tech.addTechDependency("ironclad", "military-4")

data.raw.technology["ir-inserters-1"].localised_description = {"technology-description.ir-inserters-1"}

if false then
	Tech.addTechDependency("ir-scatterbot", "military")
	Tech.addTechDependency("ir-heavy-roller", "ir-heavy-picket")
	Tech.addTechDependency("ir-heavy-picket", "spidertron")
	Tech.addTechDependency("land-mine", "military-3")
	Tech.addTechDependency("ir-steambot", "personal-roboport-equipment")
	Tech.addTechDependency("plastics-2", "logistics-3")
	Tech.addTechDependency("logistics-3", "automation-4")
end
-- TODO remove this

-- TODO fix the ordering of the techs. Currently some fairly late techs are shown quite early. Maybe just set order field for all of them to the same value, so the game automatically orders them.