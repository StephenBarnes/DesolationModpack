-- Tech changes, for several reasons:
-- * We want to avoid "dead ends" in the tech tree, because evolution depends on techs.
-- * Ensure mod compat, eg cargo ships whose recipe requires steel should have steel as prereq.
-- * Consolidate techs somewhat, since techs are so expensive. Eg I don't want to have a separate tech for each tier of IR3 stacking beltbox, or containerization machine, or AAI loader.

local Tech = require("code.util.tech")

-- Needed because I want the stacking beltboxes to be ordered correctly.
-- Also, IR3 changes things so that logistics-2 is no longer a prereq for things like cars, like it is in vanilla.
Tech.addTechDependency("automation-2", "logistics-2")

-- I'm using IR3's tech ir-inserters-3 (stack inserters) as "Robotics 3". That's a dead end, so let's switch some prereqs from ir-electronics-3 to ir-inserters-3.
Tech.replacePrereq("rocket-silo", "ir-electronics-3", "ir-inserters-3")
Tech.replacePrereq("ir-mining-2", "ir-electronics-3", "ir-inserters-3")

-- To avoid telescopes being a dead end, I'm renaming the tech to "viewfinding" and adding as prereq to military (which is a prereq of autogun turrets).
Tech.addTechDependency("ir-bronze-telescope", "military")

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

-- Radar is a dead end. We could remove it, eg:
-- Tech.addTechDependency("ir-radar", "ir-robotower")
-- But, I don't think this is actually necessary - surely nobody's going to continue using telescopes into late-game, and if they do, alright, they can get a reduction in evolution.

-- There's several other dead ends that I think are actually fine, because forgoing them could be fun and deserves a reward in lowered evolution. Namely:
-- Autogun turret
-- Fluid wagon
-- Petrochemical generator
-- Helium airship, and airship station
-- Heavy picket
-- Land-mine
-- Geothermal exchange (once I buff geothermal energy)
-- Barrelling
-- Medical pack


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
