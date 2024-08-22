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
Polluted steam vents produce between 120/sec polluted steam and zero. When they deplete, they get re-set to 100% -- see replenish_fissure function in control.lua.
Looking at the geothermal exchange recipe, and the speed of geothermal exchanges (1.25), they produce 75 steam/sec.
One vent supplies ~1 geothermal exchanger, which supplies ~2.5 steam engines, to produce 2.25 MW.
My resource placement is currently placing ~9 polluted steam fissures in a batch, which can produce ~22MW.
This is enough to power 44 electric mining drills (each 500kW), so it's significant.
Alternatively, we could use the 75/sec steam from each exchanger to fill ~0.75/sec steam cell, which is 2.2MJ, so again ~22MW of stored steam.
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