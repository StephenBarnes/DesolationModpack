-- This file adds new science packs and their recipes, and also changes many parts of the tech tree, eg tech dependencies and their unlocks.

-- Several reasons:
-- * Move various techs around to different places, to fit with the new progression introduced by the modpack, eg geothermal energy should come early.
-- * Compat between the various mods. Eg we want to insert steam locomotives and cargo ships in the right places.
-- * Add more complexity in early game, by introducing multiple science packs early on.
-- * Consolidate/simplify techs that seem too inconsequential. Eg I don't want to have a separate tech for each tier of IR3 stacking beltbox, or containerization machine. And I don't want to have 10 techs that give +2 to robot follower count or whatever.
-- * Previously, now obsolete: We want to avoid "dead ends" in the tech tree, because evolution depends on techs.
--     This is now obsolete, because I decided to instead add evolution to specific milestone techs, not uniformly to all techs.

-- TODO rather move each of these to its own, separate file for related changes. Rather collect the modpack's changes by theme/domain/subject (transport, ammo, etc.), not aspect/system (techs, recipes, items, etc.), since that's what I'm doing everywhere else.

local Tech = require("code.util.tech")
local Recipe = require("code.util.recipe")

-- Needed because I want the stacking beltboxes to be ordered correctly.
-- Also, IR3 changes things so that logistics-2 is no longer a prereq for things like cars, like it is in vanilla.
-- Actually not needed, bc it already depends on automation-2 indirectly.
--Tech.addTechDependency("automation-2", "logistics-2")

-- I'm using IR3's tech ir-inserters-3 (stack inserters) as "Robotics 3". That's a dead end, so let's switch some prereqs from ir-electronics-3 to ir-inserters-3.
Tech.replacePrereq("rocket-silo", "ir-electronics-3", "ir-inserters-3")
Tech.replacePrereq("ir-mining-2", "ir-electronics-3", "ir-inserters-3")

-- Night-vision shouldn't depend on electric lighting, and should be pretty easy to get early on.
Tech.setPrereqs("night-vision-equipment", {"modular-armor"})

-- To avoid heavy roller and heavy armor from being dead ends, I'm going to merge them into the bronze furnace tech.
-- Also move the heavy bronze plate recipe, since that makes sense thematically, though it's breaking with all the other material milestone techs.
--Tech.addTechDependency("ir-monowheel", "ir-bronze-furnace")
--Tech.addRecipeToTech("bronze-plate-heavy", "ir-bronze-furnace", 1)
--Tech.removeRecipeFromTech("bronze-plate-heavy", "ir-bronze-milestone")
--Tech.addRecipeToTech("heavy-roller", "ir-bronze-furnace")
--Tech.hideTech("ir-heavy-roller")
--Tech.addRecipeToTech("heavy-armor", "ir-bronze-furnace")
--Tech.hideTech("heavy-armor")

Tech.addTechDependency("heavy-armor", "modular-armor")

-- Change clockwork scatterbot to depend on the new heavy bronze plate tech.
--Tech.replacePrereq("ir-scatterbot", "ir-bronze-milestone", "ir-bronze-furnace")

-- Make scatterbots and lampbots not dead ends.
Tech.addTechDependency("ir-scatterbot", "ir-lampbot")
Tech.addTechDependency("ir-lampbot", "defender")

-- Add forestry => advanced forestry, to avoid a dead end. Except at the chrome forestry - not sure how to prevent that while still being plausible.
Tech.addTechDependency("ir-bronze-forestry", "ir-iron-forestry")
Tech.addTechDependency("ir-iron-forestry", "ir-chrome-forestry")

-- Add logistics-3 as prereq for some higher-tier stuff.
Tech.addTechDependency("logistics-3", "logistic-system")

-- Move petrochemical generator to crude oil processing, bc it's a dead end.
-- Also add dependency combustion engine => crude oil processing, bc combustion engine is needed to make the petrochemical generator.
--Tech.hideTech("ir-petro-generator")
--Tech.addTechDependency("engine", "ir-crude-oil-processing")
--Tech.addRecipeToTech("petro-generator", "ir-crude-oil-processing", 1)

-- Move light armor, and brick wall, to the new "basic defense" tech.
Tech.addRecipeToTech("light-armor", "ir-blunderbuss")
Tech.removeRecipeFromTech("light-armor", "ir-tin-working-2")
Tech.addRecipeToTech("stone-wall", "ir-blunderbuss")
Tech.removeRecipeFromTech("stone-wall", "stone-wall") -- Technology "stone-wall" is IR3's "stone-working" tech.

-- Remove unwanted cargo ships techs: oversea energy distribution, train bridges, tanker ship
Tech.disable("oversea-energy-distribution")
Tech.disable("automated_bridges")
Tech.disable("tank_ship")
Tech.disable("cargo_ships")
Tech.disable("water_transport_signals")
Tech.disable("deep_sea_oil_extraction") -- shouldn't be necessary; only shows up if settings are wrong.
-- Move cargo ships, buoys, ports all to the same tech.
Tech.addRecipeToTech("cargo_ship", "automated_water_transport", 1)
Tech.addRecipeToTech("buoy", "automated_water_transport")
Tech.addRecipeToTech("chain_buoy", "automated_water_transport")
data.raw.technology["water_transport"].prerequisites = {"ir-steel-milestone", "engine"}
data.raw.technology["automated_water_transport"].prerequisites = {"water_transport", "telemetry"}

-- Rename landfill tech to earthworks, and add waterfill explosive.
-- Want to place it before automated shipping, but not after explosives. So also change recipe to not require explosives.
data.raw.technology["landfill"].prerequisites = {"automated_water_transport"}
Tech.removeRecipeFromTech("waterfill-explosive", "explosives")
Tech.addRecipeToTech("waterfill-explosive", "landfill")
data.raw.recipe["waterfill-explosive"].ingredients = {{"copper-gate", 1}, {"wooden-chest", 1}, {"solid-fuel", 4}}

Tech.disable("fluid-wagon")
Tech.removeRecipeFromTech("meat:sheet-metal-cargo-wagon", "meat:steam-locomotion-technology")
Tech.addRecipeToTech("cargo-wagon", "meat:steam-locomotion-technology", 2)
Tech.removeRecipeFromTech("cargo-wagon", "railway")
Tech.removeRecipeFromTech("rail", "railway")
--Tech.addTechDependency("ir-iron-milestone", "meat:steam-locomotion-technology")
Tech.setPrereqs("meat:steam-locomotion-technology", {"engine"}) -- Makes sense that trains require (external) combustion engines.
Tech.setPrereqs("railway", {"meat:steam-locomotion-technology", "ir-steel-milestone"})
-- TODO check ingredients

Tech.setPrereqs("automated-rail-transportation", {"meat:steam-locomotion-technology"})

-- Move the gate recipe to automated rail tech, and adjust recipes so it's available pre-electricity.
data.raw.recipe.gate.ingredients = {{"iron-piston", 1}, {"iron-gear-wheel", 2}, {"iron-plate-heavy", 2}}
Tech.disable("gate")
Tech.addRecipeToTech("gate", "automated-rail-transportation")

-- Car only takes barrels/canisters of fuel, so it needs to be after oil processing.
Tech.setPrereqs("automobilism", {"ir-crude-oil-processing", "engine", "military"})

Tech.setPrereqs("ir-radar", {"telemetry"})

-- Since the main intended use of the airships is automated transport, I'm going to remove the airship station tech and just put the airship station recipe in the hydrogen airship tech.
Tech.disable("ir-airship-station")
Tech.addRecipeToTech("airship-station", "ir-hydrogen-airship")

data.raw.technology["optics"].prerequisites = {"ir-steam-power"} -- Depend only on electricity, not surveying.

-- Remove all the series of techs.
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
	["worker-robots-storage"] = {1, 2, 3},
	["weapon-shooting-speed"] = {1, 2, 3, 4, 5, 6},
	["laser-shooting-speed"] = {1, 2, 3, 4, 5, 6, 7},
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
-- TODO maybe add these benefit techs back, but only 1 or 2 techs each, eg only one tech for braking force, and only one tech for worker robot cargo size, etc.
-- TODO maybe put some of these bonuses back, but into regular techs, not these weird incremental bonus techs.

-- Previously ir-research-2 (Improved laboratories 2) depended on research-speed-6, but we removed that tech.
data.raw.technology["ir-research-2"].prerequisites = {"ir-force-fields", "ir-research-1"}

-- Ironclad: remove duplicate dependency on explosives (since military-2 already depends on it).
data.raw.technology["ironclad"].prerequisites = {"military-2", "automobilism"}

-- Add boats=>pumpjacks dependency, bc it makes sense with this progression, and it ensures Ironclad is indirectly dependent on boats.
Tech.setPrereqs("ir-pumpjacks", {"water_transport", "fluid-handling"})

--Tech.addTechDependency("ir-barrelling", "ir-high-pressure-canisters")
--Tech.addTechDependency("ir-geothermal-exchange", "ir-mining-2")

--Tech.addTechDependency("belt-immunity-equipment", "power-armor")
--Tech.addTechDependency("night-vision-equipment", "power-armor")

Tech.removeRecipeFromTech("mortar-cluster-bomb", "ironclad")
Tech.addRecipeToTech("mortar-cluster-bomb", "military-4")
Tech.addTechDependency("ironclad", "military-4")

data.raw.technology["ir-inserters-1"].localised_description = {"technology-description.ir-inserters-1"}

-- Remove dependency from basic defense to steam mechanisms, since it's redundant anyway.
data.raw.technology["ir-basic-research"].prerequisites = {"ir-tin-working-2", "ir-copper-working-2"}

-- Change searchlight assault tech to use the icon of the searchlight inside walls
-- Well, the tech for concrete walls could be unlocked only after the searchlight tech, but I think it's still better to use this icon, so it's not visibly lower-res than the other techs.
data.raw.technology["searchlight-assault"].icons = {
	{
		icon = "__base__/graphics/technology/stone-wall.png",
		icon_size = 256,
		icon_mipmaps = 4,
	},
	{
		icon = "__Desolation__/graphics/searchlight-icon-modified.png",
		icon_size = 64,
		icon_mipmaps = 4,
		scale = 2.0,
		shift = {0, -60},
	}
}
data.raw.technology["searchlight-assault"].prerequisites = {"optics", "circuit-network"}

-- Create concrete wall tech.
data:extend({
	{
		type = "technology",
		name = "concrete-wall",
		icon = "__base__/graphics/technology/stone-wall.png",
		icon_size = 256,
		icon_mipmaps = 4,
		prerequisites = {"ir-concrete-1"},
		unit = {
			count = 250,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
			},
			time = 60,
		},
		effects = {
			{
				type = "unlock-recipe",
				recipe = "concrete-wall",
			},
		}
	},
})
Tech.addTechDependency("concrete-wall", "ir-steel-wall")


-- TODO change ingredients for arc turret
-- TODO change searchlight ingredients
-- TODO write new locale descriptions.
-- TODO remove electric arc turret tech, and handle its postreqs.

Tech.addTechDependency("fluid-handling", "ir-barrelling")

-- Remove wood-to-charcoal recipe, and rather only have wood-chips-to-charcoal. Because I don't want to encourage people to accidentally use wood as fuel before they realize how scarce it is on the starting island.
-- Keep the charcoal kiln recipe there, bc people can get wood chips as scrap from crafting wood items.
-- Also move charcoal-from-chips recipe to the stone furnace.
Tech.removeRecipeFromTech("charcoal-from-ore", "ir-charcoal")
Tech.removeRecipeFromTech("charcoal-from-scrap", "ir-grinding-1")
Tech.addRecipeToTech("charcoal-from-scrap", "ir-charcoal")

Tech.addTechDependency("ir-blunderbuss", "ir-scattergun-turret")

-- Copper foil and thermionic tube (copper-gate) should be with electricity, not electronics, bc it's needed for things like lights.
Tech.removeRecipeFromTech("copper-foil", "ir-electronics-1")
Tech.removeRecipeFromTech("copper-gate", "ir-electronics-1")
Tech.addRecipeToTech("copper-foil", "ir-steam-power")
Tech.addRecipeToTech("copper-gate", "ir-steam-power")

--Tech.addTechDependency("ir-scattergun-turret", "gun-turret")
Tech.setPrereqs("gun-turret", {"ir-scattergun-turret", "military"})

Tech.addTechDependency("telemetry", "ir-hydrogen-airship")
--Tech.addTechDependency("telemetry", "rocket-silo")

Tech.setPrereqs("ir-heavy-picket", {"ir-force-fields", "ir-heavy-roller"}) -- Removing dependency on hydrogen cell, since it can also use batteries.

-- We could put combustion engine after oil processing. Note this puts the steel locomotive and car and modular armor only after oil.
-- However, historically combustion engines have been used with solid fuels like coal and wood. The picture for the tech looks like a liquid-powered engine like from a car.
-- So, not going to put the combustion engine after oil processing.

-- Add enemy evolution effects to milestone techs.
-- TODO these are temporary untested assignments, fix.
local milestoneTechs = {
	"ir-charcoal",    -- Stone furnace
	"ir-basic-research", -- Steam mechanisms
	"ir-grinding-1",
	"ir-iron-smelting",
	"ir-steam-power", -- Electricity
	"ir-steel-smelting",
	"ir-gold-smelting",
	"ir-crude-oil-processing",
	"ir-electronics-2",
	"ir-washing-1",
	"ir-brass-alloying",
	"ir-electroplating",
	"ir-electronics-3",
	"uranium-processing",
	"rocket-silo",
	"ir-transmat",
	"ir-quantum-mining",
	"battery",
	"automation-4",
	"magnum-opus",
}
for _, techName in pairs(milestoneTechs) do
	Tech.addEvolutionEffect(techName, 5)
end

-- Scattergun turret shouldn't be affected by multiplier, should be attainable before your BREAM peace time runs out.
data.raw.technology["ir-scattergun-turret"].unit.count = 50
data.raw.technology["ir-scattergun-turret"].ignore_tech_cost_multiplier = true

-- Rubber-wood is now only obtainable once you have forestry tech, so move the recipe for rubber to forestry tech.
Tech.removeRecipeFromTech("rubber", "ir-grinding-1")
Tech.addRecipeToTech("rubber", "ir-bronze-forestry")
-- Iron-milestone has 1 recipe requiring rubber (repair pack), so could depend on forestry. Or remove that one ingredient, and put the dependency on electricity instead.
Tech.addTechDependency("ir-bronze-forestry", "ir-iron-milestone")

-- No cliffs, so no need for cliff explosives.
Tech.removeRecipeFromTech("cliff-explosives", "explosives")

-- Base IR3 has gold smelting depend on mining 1. I want to add naval engineering prereq, bc you can only get gold from other islands, and I don't want to distract the player with techs that are useless at their current level.
Tech.setPrereqs("ir-gold-smelting", {"water_transport", "ir-mining-1"})

if false then
	Tech.addTechDependency("ir-heavy-picket", "spidertron")
	Tech.addTechDependency("land-mine", "military-3")
	Tech.addTechDependency("ir-steambot", "personal-roboport-equipment")
	Tech.addTechDependency("plastics-2", "logistics-3")
	Tech.addTechDependency("logistics-3", "automation-4")
end
-- TODO remove this

-- TODO fix the ordering of the techs. Currently some fairly late techs are shown quite early. Maybe just set order field for all of them to the same value, so the game automatically orders them.

-- TODO use this to make IR3 tech overlays, for techs that unlock science pack recipes: 	DIR.add_tech_icon_overlay(tech_name, DIR.get_icon_path("analysis-pack-unlock"))