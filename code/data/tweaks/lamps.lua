local Recipe = require("code.util.recipe")
local Tech = require("code.util.tech")

--[[
We want to change recipes of the lamps.
I want to make them more complex and expensive, bc BREAM makes lamps very important for defense.
Also, the lamp tech picture clearly has screws, so it should require rivets.

Base IR3 makes all electric lights have as ingredients: thermionic tube + glass + iron plate + copper cable.
Small lamp is 1/1/1/1, large lamp 4/4/6/4, floor lamp 2/4/4/2.
Aetheric lamp is 1 steam pipe + 2 glass + 3 copper rod; the steam pipe is 1 copper plate + 1 copper rivet.
Copper lamp is 6x copper plate.

Light radius is 17 for the small lamp, 29 for large and floor lamps, 29 for copper lamp, 12 for aetheric lamp.
(These are taken from BREAM. The floor lamp is duller, but same radius as large lamp.)
So light area is 289 for small lamp, 841 for large and floor and copper lamps, 144 for aetheric lamp.
So, ratios are 2 : 6 : 1.
So it might make sense to put the recipe costs in the same ratio, maybe with a discount for the larger ones, or with extra recipe complexity for some of them.

Power consumption:
* Copper lamp: 9.6kW burnable.
* Aetheric lamp: 2.5kW steam.
* Small lamp: 5kW electricity.
* Large lamp: 20kW electricity.
* Floor lamp: 10kW electricity.

I think, let's make the recipes roughly linear in light area.
Except lower for aetheric bc they need steam and I like the way they look.
And make it higher for floor lamps, bc they're more convenient.

For floor lamps, I think I'll make it require the heavy copper cable, which requires rubber, so it's more complex.
]]
Recipe.setIngredients("deadlock-copper-lamp", {
	{"copper-plate", 6},
	{"copper-cable", 1},
	{"copper-rivet", 6},
})
Recipe.setIngredients("copper-aetheric-lamp-straight", {
	{"steam-pipe", 1},
	{"glass", 1},
	{"copper-rod", 2},
})
Recipe.setIngredients("small-lamp", {
	{"copper-gate", 1}, -- Thermionic tube
	{"glass", 1},
	{"iron-plate", 2},
	{"iron-rivet", 4},
	{"copper-cable", 2},
})
Recipe.setIngredients("deadlock-large-lamp", {
	{"copper-gate", 4},
	{"glass", 4},
	{"iron-plate", 8},
	{"iron-rivet", 8},
	{"copper-cable", 2},
})
Recipe.setIngredients("deadlock-floor-lamp", {
	{"copper-gate", 8},
	{"glass", 4},
	{"iron-plate", 4},
	{"iron-rivet", 8},
	{"copper-cable-heavy", 2},
})

-- Move copper wire tech to earlier, bc I want to put it in the copper-lamp recipe.
Tech.addRecipeToTech("copper-cable", "ir-copper-working-1", 5)
Tech.removeRecipeFromTech("copper-cable", "ir-steam-power")

-- Move optics (electric light) tech, should depend on electricity, not on electronics 1.
Tech.setPrereqs("optics", {"ir-steam-power"})