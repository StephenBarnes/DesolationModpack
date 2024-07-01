-- Tech changes, for several reasons:
-- * We want to avoid "dead ends" in the tech tree, because evolution depends on techs.
-- * Ensure mod compat, eg cargo ships whose recipe requires steel should have steel as prereq.
-- * Consolidate techs somewhat, since techs are so expensive. Eg I don't want to have a separate tech for each tier of IR3 stacking beltbox, or containerization machine, or AAI loader.

local Tech = require("code.util.tech")

-- Needed because I want the stacking beltboxes to be ordered correctly.
-- Also, IR3 changes things so that logistics-2 is no longer a prereq for things like cars, like it is in vanilla.
Tech.addTechDependency("automation-2", "logistics-2")

if false then
	Tech.addTechDependency("ir-scatterbot", "military")
	Tech.addTechDependency("ir-heavy-roller", "ir-heavy-picket")
	Tech.addTechDependency("ir-heavy-picket", "spidertron")
	Tech.addTechDependency("land-mine", "military-3")
	Tech.addTechDependency("ir-bronze-telescope", "gun-turret")
	Tech.addTechDependency("ir3-beltbox-steam", "ir3-beltbox")
	Tech.addTechDependency("ir3-beltbox-steam", "logistics-2")
	Tech.addTechDependency("ir-steambot", "personal-roboport-equipment")
	Tech.addTechDependency("heavy-armor", "modular-armor")
	Tech.addTechDependency("ir-petro-generator", "ir-petroleum-processing")
	Tech.addTechDependency("ir-normal-inserter-capacity-bonus-2", "logistics-3")
	Tech.addTechDependency("plastics-2", "logistics-3")
	Tech.addTechDependency("logistics-3", "automation-4")
	Tech.addTechDependency("effect-transmission", "ir-transmat")
	Tech.addTechDependency("ir-geothermal-exchange", "ir-mining-2")
	Tech.addTechDependency("gun-turret", "military-2")
	Tech.addTechDependency("ir-bronze-forestry", "ir-iron-forestry")
	Tech.addTechDependency("ir-iron-forestry", "ir-chrome-forestry")
	Tech.addTechDependency("ir-barrelling", "ir-high-pressure-canisters")
	Tech.tryAddTechDependency("ir-barrelling", "oversea-energy-distribution")
	Tech.tryAddTechDependency("ir-steel-milestone", "automated-water-transport")
end
-- TODO more of these?
-- TODO review all of these, make sure they're sensible.
