local Recipe = require("code.util.recipe")
local Tech = require("code.util.tech")

-- Reduce copper boiler effectiveness, so you need more of them and you're more eager to upgrade to iron boilers.
data.raw.boiler["copper-boiler"].energy_consumption = "300000W" -- changed 15000 -> 5000, or 900kW -> 300kW

-- Reduce copper pump effectiveness, so you're more eager to upgrade to iron ones.
data.raw["offshore-pump"]["copper-pump"].pumping_speed = 3.0 -- 8.0 -> 3.0, so water is 480/sec -> 180/sec, can provide water to 16 -> 6 copper boilers (excluding change to copper boilers above).

-- Make rubber tree beds require ordinary wood, not rubber wood, because the Desolation map preset makes rubber trees rare.
data.raw.recipe["tree-planter-ir-rubber-tree"].ingredients = {{"wood", 12}, {"stone-brick", 8}}

data.raw.recipe["stone-brick"].energy_required = 0.5 -- Reduced 1 -> 0.5.

-- TODO make the laser recipe for red circuits cheaper in materials, or make it produce like 4 red circuits instead of 2. Bc currently it adds a lot of complexity (laser assemblers, nitrogen) for only like a 2x increase in speed, I think. TODO analyze this.

-- Renaming the steam fissure to "clean steam fissure".
data.raw.resource["steam-fissure"].localised_name = {"entity-name.steam-fissure"}

-- Make coal a bit more visible on the dark terrain
--data.raw.resource["coal"].map_color = {r=0.3, g=0.3, b=0.3}

-- https://github.com/Deadlock989/IndustrialRevolution/issues/451
-- The portable steam engine shouldn't have a combustion engine, since it just discharges steam cells, doesn't use burnable fuel.
Tech.removePrereq("modular-armor", "engine")
Recipe.setIngredients("iron-burner-generator-equipment", -- This ID is used for portable steam engine.
	{
		{"iron-frame-small", 1},
		{"iron-stick", 4},
		{"iron-gear-wheel", 8},
		{"copper-cable", 2},
	})


-- TODO add descriptions for the IR3 valve types, eg what is an overflow valve vs top-up valve vs one-way valve.

--[[ Just checking electric water heater/boiler from IR3:
Crafting speed 1.25, recipe 1s, so time is 0.8s.
It consumes 1.25MW to turn 30 water into 30 steam, 165C.
So it consumes (1.25MJ/s) * (0.8s) = 1 MJ, to produce 30 steam.
A steam cell holds 100 steam and is 3MJ, so 33.3 steam is 1MJ. So electric boiler is slightly inefficient.
Steam engine consumes 30 steam to produce 900kW, so again the electric boiler is slightly inefficient.
]]


------------------------------------------------------------------------
-- Making gold require water for mining. Because this modpack makes water transport/logistics an actual concern, by restricting building tiles and by making pumps require power.

data.raw.resource["gold-ore"].minable.required_fluid = "water"
data.raw.resource["gold-ore"].minable.fluid_amount = 10 -- For some reason this property needs to be 10x the actual in-game number. So 10 here means 1 water per gold ore.

------------------------------------------------------------------------
-- ADJUST SPEEDS AND ENERGY CONSUMPTIONS of some machines. Because currently many machines have speeds like 1.25 etc. which is annoying for calculations.
-- Seems to be based on machine tier: copper is usually 0.625, then iron is 1.25, steel 2.5, etc.

data.raw["assembling-machine"]["steel-boiler"].crafting_speed = 1 -- 1.25 -> 1
data.raw["assembling-machine"]["steel-boiler"].energy_usage = "1MW" -- 1.25MW -> 1MW

data.raw["assembling-machine"]["deadlock-copper-lamp"].energy_usage = "10kW" -- 9.6kW -> 10kW

--data.raw.roboport.robotower.energy_usage = (2000 - 20) .. "kW" -- total 2.02MW -> 2MW
--data.raw.roboport.roboport.energy_usage = (8000 - 50) .. "kW" -- total 8.05MW -> 8MW
-- This doesn't work bc it's computed from the bot-charging energy, so either that's an ugly number or max usage is an ugly number or drain is zero.
-- So, just leaving these numbers untidy.

data.raw["mining-drill"]["pumpjack"].energy_usage = "100kW" -- 125kW -> 100kW

data.raw["assembling-machine"]["bronze-forestry"].crafting_speed = 0.5 -- 0.625 -> 0.5
data.raw["assembling-machine"]["bronze-forestry-simulation"].crafting_speed = 0.5 -- 0.625 -> 0.5; 
data.raw["assembling-machine"]["iron-forestry"].crafting_speed = 1 -- 1.25 -> 1
data.raw["assembling-machine"]["chrome-forestry"].crafting_speed = 1 -- 1.25 -> 1. Note this uses crafting speed 1, but recipes have half the time of the recipes used by bronze/iron forestries.
-- Added notes on to forestries' descriptions.

data.raw.furnace["copper-grinder"].crafting_speed = 1 -- Changed speed 1.25 => 1.
data.raw.furnace["copper-grinder"].energy_usage = "100kW" -- Changed 125kW => 100kW.
data.raw.furnace["iron-grinder"].crafting_speed = 1 -- Changed speed 1.25 => 1.
data.raw.furnace["iron-grinder"].energy_usage = "95kW" -- Changed 120kW => 95kW, plus 5kW drain.
data.raw.furnace["steel-grinder"].crafting_speed = 2 -- Changed speed 2.5 => 2.
data.raw.furnace["steel-grinder"].energy_usage = "190kW" -- Changed 240kW => 190kW, plus 10kW drain.

data.raw["assembling-machine"]["iron-mixer"].crafting_speed = 1 -- Changed speed 1.25 => 1.
data.raw["assembling-machine"]["iron-mixer"].energy_usage = "95kW" -- Changed 120kW => 95kW, plus 5kW drain.
data.raw["assembling-machine"]["steel-mixer"].crafting_speed = 2 -- Changed speed 2.5 => 2.
data.raw["assembling-machine"]["steel-mixer"].energy_usage = "190kW" -- Changed 240kW => 190kW, plus 10kW drain.

data.raw.furnace["steel-washer"].crafting_speed = 1 -- Changed speed 1.25 => 1.
data.raw.furnace["steel-washer"].energy_usage = "190kW" -- Changed 240kW => 190kW, plus 10kW drain.

data.raw["assembling-machine"]["chrome-press"].crafting_speed = 1 -- Changed speed 1.25 => 1.
data.raw["assembling-machine"]["chrome-press"].energy_usage = "1170KW" -- Originally 1.5MW max and 30kW drain. Changing max to 1.2MW to compensate for reduced crafting speed.

-- Steam assembler is assembling-machine-1.
data.raw["assembling-machine"]["assembling-machine-1"].crafting_speed = 0.5 -- Changed speed 0.625 => 0.5.
data.raw["assembling-machine"]["assembling-machine-1"].energy_usage = "100kW" -- Changed 125kW => 100kW.
data.raw["assembling-machine"]["assembling-machine-2"].crafting_speed = 1 -- Changed speed 1.25 => 1.
data.raw["assembling-machine"]["assembling-machine-2"].energy_usage = "95kW" -- Changed 120kW => 95kW, plus 5kW drain.
data.raw["assembling-machine"]["assembling-machine-3"].crafting_speed = 2 -- Changed speed 2.5 => 2.
data.raw["assembling-machine"]["assembling-machine-3"].energy_usage = "190kW" -- Changed 240kW => 190kW, plus 10kW drain.
data.raw["assembling-machine"]["laser-assembler"].crafting_speed = 2 -- Changed speed 2.5 => 2.
data.raw["assembling-machine"]["laser-assembler"].energy_usage = "380kW" -- Changed (500-20)kW => (400-20)kW, plus 20kW drain.

data.raw["assembling-machine"]["small-assembler-1"].crafting_speed = 0.5 -- Changed speed 0.625 => 0.5.
data.raw["assembling-machine"]["small-assembler-1"].energy_usage = "50kW" -- Changed 62.5kW => 50kW.
data.raw["assembling-machine"]["small-assembler-2"].crafting_speed = 1 -- Changed speed 1.25 => 1.
data.raw["assembling-machine"]["small-assembler-2"].energy_usage = "47.5kW" -- Changed 60kW => 47.5kW, plus 2.5kW drain.
data.raw["assembling-machine"]["small-assembler-3"].crafting_speed = 2 -- Changed speed 2.5 => 2.
data.raw["assembling-machine"]["small-assembler-3"].energy_usage = "95kW" -- Changed 120kW => 95kW, plus 5kW drain.

data.raw.furnace["iron-scrapper"].crafting_speed = 1 -- Changed speed 1.25 => 1.
data.raw.furnace["iron-scrapper"].energy_usage = "95kW" -- Changed 120kW => 95kW, plus 5kW drain.

data.raw.furnace["steel-electroplater"].crafting_speed = 1 -- Changed speed 1.25 => 1.
data.raw.furnace["steel-electroplater"].energy_usage = "190kW" -- Changed 240kW => 190kW, plus 10kW drain.

data.raw.lab["copper-lab"].energy_usage = "100kW" -- Changed 125kW => 100kW.

data.raw["assembling-machine"]["module-loader"].energy_usage = "95kW" -- Changed 120kW => 95kW, plus 5kW drain.

data.raw["rocket-silo"]["rocket-silo"].energy_source.drain = "10kW" -- Changed 8.33kW => 10kW.

data.raw["assembling-machine"]["oil-refinery"].energy_usage = "385kW" -- Changed 360kW => 385kW, plus 15kW drain.

data.raw.furnace["barrelling-machine"].energy_usage = "50kW" -- Changed 62.5kW => 50kW.
data.raw.furnace["unbarrelling-machine"].energy_usage = "50kW" -- Changed 62.5kW => 50kW.

data.raw.furnace["iron-gas-vent"].crafting_speed = 1 -- Changed speed 1.25 => 1.
data.raw.furnace["iron-gas-vent"].energy_usage = "20kW" -- Changed 25kW => 20kW.
-- Since these recipes are hidden, adding description to it.

data.raw["assembling-machine"]["air-compressor"].crafting_speed = 1 -- Changed speed 1.25 => 1.
data.raw["assembling-machine"]["air-compressor"].energy_usage = "50kW" -- Changed 62.5kW => 50kW.
data.raw["assembling-machine"]["air-compressor"].energy_source.emissions_per_minute = -20 -- Changed -30 to -20; TODO playtest.

data.raw["assembling-machine"]["air-purifier"].crafting_speed = 1 -- Changed speed 1.25 => 1.
data.raw["assembling-machine"]["air-purifier"].energy_usage = "80kW" -- Changed 62.5kW => 80kW.
data.raw["assembling-machine"]["air-purifier"].energy_source.emissions_per_minute = -20 -- Changed -30 to -20; TODO playtest.

-- We want the air purifier to still be equivalent to an air compressor plus 4 vents (since that's what the image and recipe are).
-- In base IR3, the air compressor produces 240 compressed air in 4s / 1.25 (because machine speed is 1.25), so 240 per 3.2s, so 75/s. Each vent gets rid of 20 * 1.25 = 25 per second. So 3 air compressors is actually enough to vent all the compressed air.
-- So it seems to not actually work out in base IR3. Though base IR3 also has greater power cost for the gas vents, etc.
-- Anyway, I still want air purifier to be equivalent to air compressor + 4 vents. Currently air vents get rid of 20 per second, so 4 of them get rid of 80/s. So, just change the air compression recipe to take 3s.
data.raw.recipe["air-compression"].energy_required = 3 -- Changed 4 to 3.
data.raw.recipe["air-purification"].energy_required = 3 -- Changed 4 to 3.
-- Also changing energy usage of the air purifier so it's air compressor + 1 vent only, so you get an energy discount.

data.raw["assembling-machine"]["steel-cryo-tower"].crafting_speed = 1 -- Changed speed 1.25 => 1.

data.raw.furnace["steel-vaporiser"].crafting_speed = 1 -- Changed speed 1.25 => 1.

-- TODO the heat exchanger is doing 103/s fluid, should probably be 100/s.

data.raw["assembling-machine"]["centrifuge"].energy_usage = "385kW" -- Changed 350kW => 385kW, plus 15kW drain.

-- TODO the searchlights use 332kW, should be 300kW or something.
-- TODO laser turrets are 2.42MW, should be sth else
-- TODO electric arc turrets are 1.02MW max, should be 1MW

-- TODO check clockwork construction bot speed - why does it seem to be the same as the electric bots?
-- TODO clockwork construction bot description mentions speed researches, which I've removed, fix it.

------------------------------------------------------------------------
-- Reduce pollution reduction from forestries?
-- Unsure if we want this, TODO playtest and balance.

data.raw["assembling-machine"]["bronze-forestry"].energy_source.emissions_per_minute = -24 -- -36 -> -24
data.raw["assembling-machine"]["iron-forestry"].energy_source.emissions_per_minute = -24 -- -36 -> -24
data.raw["assembling-machine"]["chrome-forestry"].energy_source.emissions_per_minute = -24 -- -36 -> -24