local Recipe = require("code.util.recipe")
local Tech = require("code.util.tech")

-- Make starting furnaces cost less wood, bc it's hard to come by.
-- And make them produce only the furnaces, not the wood chip scrap, if ProductionScrapForIR3 is installed
Recipe.setIngredients("stone-furnace", {{"stone-brick", 24}})
Recipe.setResults("stone-furnace", {{"stone-furnace", 1}})
Recipe.setIngredients("stone-charcoal-kiln", {{"stone-brick", 20}})
Recipe.setResults("stone-charcoal-kiln", {{"stone-charcoal-kiln", 1}})
-- Stone alloy furnace was originally 1 stone furnace + 8 tin plates. Leaving it like that.

-- Make the stone furnace a bit slower, so a bronze furnace isn't basically just 2 stone furnaces (in terms of pollution, energy consumption, and crafting speed).
-- (Bronze furnace also smelts more materials, like iron. And smaller size. But that's not enough to motivate me to replace stone furnaces on copper/tin lines with bronze furnaces.)
-- Originally stone furnace has speed/pollution/energy as 1.25/3/125kW, and bronze furnace has 2.5/6/250kW.
-- Same for stone vs bronze alloy furnaces.
data.raw.furnace["stone-furnace"].crafting_speed = 1
data.raw["assembling-machine"]["stone-alloy-furnace"].crafting_speed = 1


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