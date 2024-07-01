-- Add tech requirements to get rid of "dead ends" in the tech tree, and ensure mod compat (eg cargo ships whose recipe requires steel should have steel as prereq).
function addTechDependency(firstTech, secondTech)
	table.insert(data.raw.technology[secondTech].prerequisites, firstTech)
end
function tryAddTechDependency(firstTech, secondTech)
	if data.raw.technology[secondTech] ~= nil and data.raw.technology[firstTech] ~= nil then
		addTechDependency(firstTech, secondTech)
	end
end
if false then
	addTechDependency("ir-scatterbot", "military")
	addTechDependency("ir-heavy-roller", "ir-heavy-picket")
	addTechDependency("ir-heavy-picket", "spidertron")
	addTechDependency("land-mine", "military-3")
	addTechDependency("ir-bronze-telescope", "gun-turret")
	addTechDependency("ir3-beltbox-steam", "ir3-beltbox")
	addTechDependency("ir3-beltbox-steam", "logistics-2")
	addTechDependency("ir-steambot", "personal-roboport-equipment")
	addTechDependency("heavy-armor", "modular-armor")
	addTechDependency("ir-petro-generator", "ir-petroleum-processing")
	addTechDependency("ir-normal-inserter-capacity-bonus-2", "logistics-3")
	addTechDependency("plastics-2", "logistics-3")
	addTechDependency("logistics-3", "automation-4")
	addTechDependency("effect-transmission", "ir-transmat")
	addTechDependency("ir-geothermal-exchange", "ir-mining-2")
	addTechDependency("gun-turret", "military-2")
	addTechDependency("ir-bronze-forestry", "ir-iron-forestry")
	addTechDependency("ir-iron-forestry", "ir-chrome-forestry")
	addTechDependency("ir-barrelling", "ir-high-pressure-canisters")
	tryAddTechDependency("ir-barrelling", "oversea-energy-distribution")
	tryAddTechDependency("ir-steel-milestone", "automated-water-transport")
end
-- TODO more of these?
-- TODO review all of these, make sure they're sensible.

-- TODO Change the amounts needed for IR3's inspirations. Currently it's 12, which is tiny.