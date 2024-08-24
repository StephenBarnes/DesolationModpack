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