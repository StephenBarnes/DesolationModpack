local Recipe = require("code.util.recipe")
local Tech = require("code.util.tech")

-- Make starting furnaces cost less wood, bc it's hard to come by.
-- And make them produce only the furnaces, not the wood chip scrap, if ProductionScrapForIR3 is installed
Recipe.setIngredients("stone-furnace", {{"stone-brick", 24}})
Recipe.setResults("stone-furnace", {{"stone-furnace", 1}})
Recipe.setIngredients("stone-charcoal-kiln", {{"stone-brick", 20}})
Recipe.setResults("stone-charcoal-kiln", {{"stone-charcoal-kiln", 1}})
-- Stone alloy furnace was originally 1 stone furnace + 8 tin plates. Leaving it like that.

------------------------------------------------------------------------
-- ADJUSTING CRAFTING SPEEDS AND POWER CONSUMPTIONS
-- I want to make the numbers more round, e.g. no 1.25 crafting speed, rather just 1.
-- Also, I want to make stone furnaces worse relative to bronze, so 1 bronze furnace isn't so exactly equivalent to 2 stone furnaces. (Well, they already take up less space than 2 stone furnaces, and can smelt iron, but that's not enough to motivate replacing stone furnace lines for copper/tin with bronze furnaces.)

-- Originally stone furnace has speed/pollution/energy as 1.25/3/125kW, and bronze furnace has 2.5/6/250kW.
-- Changing them to 1/4/125kW and 2/6/200kW. So now bronze furnaces smelt twice as much, but lower fuel consumption and pollution per product.

data.raw.furnace["stone-furnace"].crafting_speed = 1 -- Changed speed 1.25 => 1.
data.raw["assembling-machine"]["stone-alloy-furnace"].crafting_speed = 1 -- Changed speed 1.25 => 1.
data.raw.furnace["stone-furnace"].emissions_per_second = 4 -- Changed pollution 3 => 4.
data.raw["assembling-machine"]["stone-alloy-furnace"].emissions_per_second = 4 -- Changed pollution 3 => 4.

data.raw.furnace["bronze-furnace"].crafting_speed = 2 -- Changed speed 2.5 => 2.
data.raw["assembling-machine"]["bronze-alloy-furnace"].crafting_speed = 2 -- Changed speed 2.5 => 2.
data.raw.furnace["bronze-furnace"].energy_usage = "200kW" -- Changed 250kW => 200kW.
data.raw["assembling-machine"]["bronze-alloy-furnace"].energy_usage = "200kW" -- Changed 250kW => 200kW.

data.raw.furnace["electric-furnace"].crafting_speed = 2 -- Changed speed 2.5 => 2.
data.raw["assembling-machine"]["electric-alloy-furnace"].crafting_speed = 2 -- Changed speed 2.5 => 2.
data.raw.furnace["electric-furnace"].energy_usage = "190kW" -- Changed 240kW => 190kW (bc 10kW drain).
data.raw["assembling-machine"]["electric-alloy-furnace"].energy_usage = "190kW" -- Changed 240kW => 190kW (bc 10kW drain).

-- Gas furnace uses ID steel-furnace.
data.raw.furnace["steel-furnace"].crafting_speed = 2 -- Changed speed 2.5 => 2.

data.raw.furnace["blast-furnace"].crafting_speed = 4 -- Changed speed 5 => 4.
data.raw.furnace["blast-furnace"].energy_usage = "200kW" -- Changed 250kW => 200kW to match electric furnace and mirror change in speed.

data.raw["assembling-machine"]["arc-furnace"].crafting_speed = 4 -- Changed speed 5 => 4.
data.raw["assembling-machine"]["arc-furnace"].energy_usage = "475kW" -- Changed 600kW to 475kW, plus drain of 25kW.
-- I think this is balanced, but TODO after playtesting consider changing it. Note arc furnace uses different recipes from everything else.

------------------------------------------------------------------------
-- CHARCOAL KILN special changes.
-- Original IR3 recipe takes 100 "energy", but charcoal kiln has speed 1.25, so takes 80 seconds. Converts 50 wood chips to 25 charcoal.
-- Changing it to take 60 seconds, and charcoal kiln has speed 1, so it takes 60 seconds. Converts 60 wood chips to 30 charcoal.

data.raw.furnace["stone-charcoal-kiln"].crafting_speed = 1 -- Changed speed 1.25 => 1.
data.raw.recipe["charcoal-from-scrap"].energy_required = 60 -- Changed 100 to 60.
data.raw.recipe["charcoal-from-scrap"].result = nil
Recipe.setIngredients("charcoal-from-scrap", {{"wood-chips", 60}})
Recipe.setResults("charcoal-from-scrap", {{"charcoal", 30}})

------------------------------------------------------------------------
--- CHANGING ARC FURNACE POSITION IN PROGRESSION
-- Originally, arc furnace 1 tech is after blue circuits. But I like the molten metal casting, and I feel there's too many useful things locked behind blue circuits currently. So rather move it to earlier in the game, after blast furnace and cryogenics.

-- Move techs
Tech.setPrereqs("ir-arc-furnace", {"ir-blast-furnace", "ir-cryogenics"})
Tech.setPrereqs("ir-arc-furnace-2", {"ir-arc-furnace"})

-- Set tech ingredients
data.raw.technology["ir-arc-furnace"].unit = table.deepcopy(data.raw.technology["ir-blast-furnace"].unit)
data.raw.technology["ir-arc-furnace"].unit.count = 1000
data.raw.technology["ir-arc-furnace-2"].unit = table.deepcopy(data.raw.technology["ir-blast-furnace"].unit)
data.raw.technology["ir-arc-furnace-2"].unit.count = 1200

-- Recipe change since chromed frame (from blue circuits) is now no longer unlocked when we reach arc furnace 1 tech.
-- Originally, recipe was 1 large chromed frame + 1 junction box + 3 graphite electrode + 80 silicon carbide brick + 80 reinforced chromed plate.
Recipe.substituteIngredient("arc-furnace", "chromium-frame-large", "steel-frame-large")