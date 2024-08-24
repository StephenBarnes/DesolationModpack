-- Make geothermal energy available much earlier, bc it's interesting to try to build outposts close to geothermal vents, etc.
-- And other changes to techs and recipes so the progression works.

local Tech = require("code.util.tech")
local Recipe = require("code.util.recipe")

-- Move steel derrick tech to earlier, and put geothermal right after it
Tech.setPrereqs("ir-steel-derrick", {"fluid-handling"})
Tech.setPrereqs("ir-geothermal-exchange", {"ir-steel-derrick"})
data.raw.technology["ir-steel-derrick"].unit = data.raw.technology["fluid-handling"].unit
data.raw.technology["ir-geothermal-exchange"].unit = data.raw.technology["fluid-handling"].unit

-- Change derrick and geothermal exchanger recipes to use iron
Recipe.setIngredients("steel-derrick", { -- Change steel -> iron, and reduce amounts.
	{"pipe", 8},
	{"iron-plate", 4},
	{"iron-beam", 8},
	{"iron-piston", 4},
})
Recipe.setIngredients("iron-geothermal-exchanger", { -- Change to include pump
	{"iron-frame-small", 1},
	{"pump", 1},
	{"steam-pipe", 6},
	{"pipe", 4},
})

--[[
Geothermal takes in polluted steam and clean water, and produces polluted water and clean steam.
So, we need the polluted water cleaner to run it, since there's nothing else we can do with the polluted water.
In base IR3, polluted water cleaner comes with ore washing, and requires steel frame etc.
So, we move polluted water cleaner to the geothermal tech, and make that a prereq for ore washing.
]]
Tech.addRecipeToTech("steel-cleaner", -- This is the polluted water cleaner.
	"ir-geothermal-exchange")
Tech.removeRecipeFromTech("steel-cleaner", "ir-washing-1")
Tech.addRecipeToTech("dirty-water-cleaning",
	"ir-geothermal-exchange")
Tech.removeRecipeFromTech("dirty-water-cleaning", "ir-washing-1")
Tech.addTechDependency("ir-geothermal-exchange", "ir-washing-1")

Recipe.setIngredients("steel-cleaner", {
	-- Original recipe: 2 green circuits + small steel frame + advanced (blue) motor
	{"electronic-circuit", 2},
	{"iron-motor", 2},
	{"iron-frame-small", 1},
})

--[[
A polluted steam vent produces 0-120/sec polluted steam. When it depletes, it gets re-set to 100% -- see replenish_fissure function in control.lua.
Looking at recipes, given 60 polluted steam, we can use it with 0.8 geothermal exchangers + 0.8 polluted water cleaners + 0.2 ambient heat exchangers (to make up the difference in water) to produce 60 steam, but minus 5 that has to go back into the ambient cooler.
So basically we can turn 60 polluted steam into 55 clean steam, as per the geothermal exchange recipe.
A steam engine produces 900kW from 30 steam/sec, so the 55 clean steam is equivalent to 1650kW.
The machinery to do all this consumes 80kW, plus another 20kW for an inserter on the polluted water cleaner, plus 50kW for the derrick, so 150kW.
So for every 60 polluted steam, we get a new of 1650kW - 150kW = 1500kW, nice round number.
So each polluted steam fissure supplies 1.5MW on average, or 3MW at maximum.

My resource placement is currently placing ~12 polluted steam fissures in a batch, which produces somewhere around 36MW max or 18MW average.
This is enough to power 36 electric mining drills (each 500kW), so it's significant enough to matter.
Main benefit of geothermal is to simplify power generation logistics.
]]

--[[
Worth considering also the pure steam vents. Each one produces ~30/sec steam, which is ~1MW.
These fissures come in clumps of 2-4 (with current resource placement), so ~4MW, which is enough to be significant.
]]

--[[
Note that cleaning 60 polluted water actually produces only 50 water, so the geothermal exchanger needs extra clean water input.
Every geothermal exchanger needs 10 water every 0.8s.
10 water per 1s can be produced by 0.5 electric ice melters, consuming 250kW.
It also requires 1 ice every 0.8s = 1.25 ice per second, which is produced by 2 electric miners. Though it's a byproduct, so you'll likely have extra.
Well, I guess we should also move the ambient heat exchanger to the geothermal tech, and then make cryogenics depend on that.
]]
-- Tech prereq (from geothermal to cryogenics) is already there, through ore washing.
-- Move recipes (for ambient heat exchanger and clean steam cooling) to fluid-handling tech.
Tech.addRecipeToTech("copper-heatsink", "fluid-handling")
Tech.addRecipeToTech("steel-vaporiser", "fluid-handling")
Tech.addRecipeToTech("water", "fluid-handling")
Tech.removeRecipeFromTech("copper-heatsink", "ir-cryogenics")
Tech.removeRecipeFromTech("steel-vaporiser", "ir-cryogenics")
Tech.removeRecipeFromTech("water", "ir-cryogenics")

-- Move the dirty water cooling recipe to the geothermal tech, and remove from ir-cryogenics tech.
Tech.addRecipeToTech("dirty-water", "ir-geothermal-exchange")
Tech.removeRecipeFromTech("dirty-water", "ir-cryogenics")

-- Change recipe for steel-vaporiser (ambient heat exchanger) so it's attainable at geothermal.
Recipe.setIngredients("steel-vaporiser", {
	-- Original recipe: 1 small steel frame + 1 heatsink + 2 pipe + 2 steel rivets
	{"iron-frame-small", 1},
	{"copper-heatsink", 1},
	{"pipe", 2},
	{"iron-rivet", 2},
})

-- Also, let's increase the amount of water produced by dirty water cleaning, from 50 to 55, so the extra water needed is much less.
for _, product in pairs(data.raw.recipe["dirty-water-cleaning"].results) do
	if product.name == "water" then
		product.amount = 55
		break
	end
end

-- Edit the electricity consumptions here to be more round numbers.
--data.raw["assembling-machine"]["steel-cleaner"].energy_usage = "60KW" -- This is unchanged.
data.raw["assembling-machine"]["steel-cleaner"].energy_source.drain = "0W" -- Changing 2.5kW -> zero
--data.raw["assembling-machine"]["iron-geothermal-exchanger"].energy_usage = "60KW" -- This is unchanged.
data.raw["assembling-machine"]["iron-geothermal-exchanger"].energy_source.drain = "0W" -- Changing 2.5kW -> zero
data.raw["mining-drill"]["steel-derrick"].energy_usage = "50KW" -- Changing 62.5kW -> 50kW.