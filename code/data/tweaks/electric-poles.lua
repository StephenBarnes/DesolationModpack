--[[
This file tweaks the electric poles that are present in the game.
Especially because IR3 adds new poles that look nice, but the small ones are strictly worse than the small wood one from vanilla, except aesthetically.
Originally I was going to put Power Overload in this modpack, but then decided to use the system of restricting building to warm patches, which makes Power Overload unnecessary, since you can't have large power networks anyway.

In vanilla, the available poles are:
Small pole:
	1x1 size, 7.5t reach, 5x5 supply
	Cost for 1/sec:
		Materials: 0.5 wood, 0.5 copper ore
		Infra: 1.1 miner, 1.6 furnace, 1 assembler, plus manual wood
Medium pole:
	1x1 size, 9t reach, 7x7 supply
	Cost for 1/sec:
		Materials: 12 iron ore, 2 copper ore, 1.7 coal
		Infra: 31.4 miners, 77 furnaces, 3 assemblers
Large pole:
	2x2 size, 30t reach, 4x4 supply
	Cost for 1/sec:
		Materials: 29 iron ore, 5 copper ore, 4.2 coal
		Infra: 76.5 miners, 189 furnaces, 5 assemblers
Substation:
	2x2 size, 18t reach, 18x18 supply
	Cost for 1/sec:
		Materials: 100 crude oil, 15 coal, 30 copper ore, 60 iron ore
		Infra: 210 miners, 448 furnaces, 96 assemblers, 5 refineries, 10 chemical plants

IR3 adds 2 new small poles (bronze and iron), new sprites for the medium steel pole, and a new large wooden pole.
Electricity only gets researched after iron and bronze. So, let's just disable the ordinary wooden pole.
The steel pylon doesn't look much bigger than the iron and bronze poles.

In base IR3, the 3 small pylons and big wood pylon are unlocked with electricity, then distribution 1 tech (after steel) unlocks steel pylon and big steel pylon, and then distribution 2 tech (after red circuits) unlocks the substation.
Unlocks per tech seem fine.
But substations are a bit boring, want to rather have the power poles used for longer.
So, going to move distribution 2 tech to after advanced batteries, and make substations require lead etc.

Let's make the small pylons (bronze and iron) equivalent functionally, but with different ingredient profiles. (So, allowing demand-side resource balancing.)
I'm going to make them have longer connection range and area than the vanilla wooden pole, so you don't need to spam as many.

Makes good sense to have distribution 1 be after steel, and around the same time as naval engineering. It unlocks the medium steel pylon and the big steel pylon.
Let's rename the medium steel pylon to small, and make it have the same characteristics as the other small poles, but maybe slightly cheaper in resources.
Big steel pylons are for long-distance connections, minimal supply area, like in vanilla.
The big wooden pole is for long-distance connections before the big steel pylon is available.

Actually, an idea. Large steel pylon can be built on frigid terrain. And is immune to bug attacks.
In that case, move it to later in the game, maybe same time as substations.
So, remove the 2 existing electric energy distribution techs, add one new tech with both big pylons and substations, probably after advanced batteries.

To summarize, the options in Desolation are now:
Small bronze/iron/steel poles:
	All of them are 1x1 size, 9t reach, 9x9 supply.
	Cost for 1/sec:
		Bronze:
			Materials: 2.5 bronze ingot, 0.6 wood, 1 copper cable. (The 2.5 bronze can be broken down to 1.6 copper, 0.8 tin, and fuel.)
			Infra: 4.8 assemblers, 5.8 mini-assemblers, 8 alloying furnaces.
		Iron:
			Materials: 3.5 iron ingot, 1 copper cable.
			Infra: 4.8 assemblers, 4.8 mini-assemblers.
		Steel:
			Materials: 1 steel ingot, 1 copper cable. (Steel ingot can be broken down as 1 iron ingot + 0.08 coke.)
			Infra: 1.6 assembler, 1.6 mini-assembler, 1.6 electric alloying furnace. Maybe 0.1 gas furnace for the coke.
	So, costs for all of them are roughly the same, except that steel one is cheaper in materials, so you switch to it once you have the tech.
Large wooden pole:
	Made this cheaper to make it actually a better option than the others above, for medium-long distances of warm terrain.
	Cost for 1/sec:
		Materials: 2 wood, 2 copper cable, 1 iron ingot.
		Infra: 1.6 assembler, 1.6 mini-assembler.
	So, it costs slightly more than all the others, but not much, considering the long connection range.
Pylon:
	Its main purpose is to cross cold terrain, which no other pole can do, so cost isn't really comparable to the others.
	That said, I'm making it fairly cheap, since you'll need a lot to connect warm patches.
	Currently it's 1 null field plate + 4 steel beam + 8 chrome rod + 2 heavy copper cable.
		For 1/sec, that works out to around 30 ingots, with infra around 20 machines plus 35 mini-assemblers.
Substation:
	This is unlocked late-game alongside the pylon. However, it doesn't have a unique use-case like the pylon.
	Well, it allows somewhat more optimal beacon configurations, but that's not very big.
	So, I'm making it only require steel, not chrome.
	I'm making it 32x32, so it's ~1000 tiles, compared to the 7x7 poles that are ~50 tiles. So it should cost about 20x as much, ie about 40 ingots maybe. But more, for convenience, or less, so it's preferable.
	Thing is, small frame (steel or chrome) isn't consistent with other stuff that needs small frames. And large frames are too expensive to make substations worth it.
	So as a compromise, rather use plates and rods, and make the rods chromed, so substations are much more complex from-scratch, but fairly cheap once you have bulk electroplating set up anyway.
	Maybe a good recipe: junction box + 4 copper cable + 4 steel plates + 2 chromed rods.
		This works out to around 35-40 ingots, and for 1/sec it's around 25 machines plus 45 mini-assemblers.
]]

local Tech = require("code.util.tech")
local Recipe = require("code.util.recipe")
local G = require("code.util.general")

local function inDataFinalFixes()
	-- Remove small wooden pole completely.
	Tech.removeRecipeFromTech("small-electric-pole", "ir-steam-power")

	-- The "medium-electric-pole" ID is used for the small steel pole, unlocked with steel.
	Tech.addRecipeToTech("medium-electric-pole", "ir-steel-milestone")

	-- Change wooden pole size to 1x1; should be in dff or else IR3 tries to set it back??
	G.trimBox(data.raw["electric-pole"]["big-wooden-pole"].collision_box, 0.5)
	G.trimBox(data.raw["electric-pole"]["big-wooden-pole"].selection_box, 0.5)
	data.raw["electric-pole"]["big-wooden-pole"].next_upgrade = nil

	-- Mark electric poles as military targets, except big electric pole.
	for poleName, poleEnt in pairs(data.raw["electric-pole"]) do
		poleEnt.is_military_target = (poleName ~= "big-electric-pole")
	end
end

local function inDataUpdates()
	-- Rewrite tech prereqs to account for tech changes.
	Tech.setPrereqs("ir-electronics-3", {"ir-graphene", "ir-electrum-milestone", "low-density-structure", "ir-advanced-batteries"})
	Tech.setPrereqs("ir-advanced-batteries", {"ir-lead-smelting", "battery", "ir-electroplating"})
	Tech.setPrereqs("ir-solar-energy-1", {"advanced-electric-distribution"}) -- TODO remove solar panels.

	-- Hide the 2 existing electric energy distribution techs.
	-- We could just hide one of them and then modify the other, but, then it'll have a number 1 or 2 on it.
	Tech.hideTech("electric-energy-distribution-1")
	Tech.hideTech("electric-energy-distribution-2")
end

local function inData()
	data.raw["electric-pole"]["small-bronze-pole"].maximum_wire_distance = 8
	data.raw["electric-pole"]["small-bronze-pole"].supply_area_distance = 3.5

	data.raw["electric-pole"]["small-iron-pole"].maximum_wire_distance = 8
	data.raw["electric-pole"]["small-iron-pole"].supply_area_distance = 3.5

	data.raw["electric-pole"]["medium-electric-pole"].maximum_wire_distance = 8
	data.raw["electric-pole"]["medium-electric-pole"].supply_area_distance = 3.5

	data.raw["electric-pole"]["big-wooden-pole"].maximum_wire_distance = 20
	data.raw["electric-pole"]["big-wooden-pole"].supply_area_distance = 1.5

	data.raw["electric-pole"]["substation"].maximum_wire_distance = 32
	data.raw["electric-pole"]["substation"].supply_area_distance = 16

	-- Recipes for small bronze pole, small iron pole - leaving as-is.
	Recipe.setIngredients("big-electric-pole", {
		{"copper-cable-heavy", 2},
		{"steel-beam", 4},
		{"chromium-rod", 8},
		{"electrum-plate-special", 1},
	})
	Recipe.setIngredients("substation", {
		{"copper-cable", 4},
		{"junction-box", 1},
		{"steel-plate", 4},
		{"chromium-rod", 2},
	})
	Recipe.setIngredients("medium-electric-pole", { -- Small steel pole.
		{"copper-cable", 1},
		{"steel-rod", 2},
	})
	Recipe.setIngredients("big-wooden-pole", {
		{"copper-cable", 2},
		{"wood", 2},
		{"iron-stick", 2},
	})

	-- Create the new tech.
	data:extend({
		{
			type = "technology",
			name = "advanced-electric-distribution",
			icons = {
				{
					icon = "__Desolation__/graphics/empty_icon.png",
					icon_size = 64,
					icon_mipmaps = 4,
					scale = 1.0,
				},
				{
					icon = "__base__/graphics/technology/electric-energy-distribution-1.png",
					icon_size = 256,
					icon_mipmaps = 4,
					scale = 0.2,
					shift = {-3, -7},
				},
				{
					icon = "__base__/graphics/technology/electric-energy-distribution-2.png",
					icon_size = 256,
					icon_mipmaps = 4,
					scale = 0.2,
					shift = {3, 8},
				},
			},
			prerequisites = {"ir-electrum-milestone"},
			effects = {
				{
					type = "unlock-recipe",
					recipe = "big-electric-pole",
				},
				{
					type = "unlock-recipe",
					recipe = "substation",
				},
			},
			unit = {
				count = 30000 / 20,
				ingredients = {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
					{"chemical-science-pack", 1},
					{"production-science-pack", 1},
				},
				time = 60,
			},
		},
	})
end

return {
	inData = inData,
	inDataUpdates = inDataUpdates,
	inDataFinalFixes = inDataFinalFixes,
}