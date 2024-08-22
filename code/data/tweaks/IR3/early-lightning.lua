-- This file moves the late-game lightning turret to instead be available soon after electricity.
-- Also same with the electric discharge equipment.
-- To do this, we must move the techs and alter the recipes.

-- Tested discharge defense equipment with no battery, just a portable steam engine, and it works great. Though maybe a little overpowered for that stage of the game. But it's probably fine since player can't build turrets on snow.
-- Costs 2MJ per use; one copper steam cell is 3MJ.
-- Tested the personal arc turret. It's very weak, but maybe good against crowds of enemies.

local Tech = require("code.util.tech")
local Recipe = require("code.util.recipe")

-- Move techs
Tech.setPrereqs("ir-arc-turret", {"ir-steam-power", "gun-turret"}) -- Originally it depended on laser-turret. Changing to only depend on electricity tech and gun-turret.
Tech.setPrereqs("destroyer", {"military-4"}) -- Originally it depended on military 4 and on ir-arc-turret.
Tech.setPrereqs("ir-arc-turret-equipment", {"ir-arc-turret", "modular-armor"}) -- Originally depended on arc turret and power armor (after red circuits).
Tech.setPrereqs("discharge-defense-equipment", {"ir-arc-turret-equipment"}) -- Originally depended on arc turret and power armor (after red circuits). I'm placing it after the arc-turret equipment, bc it's more powerful.

-- Adjust tech costs
data.raw.technology["ir-arc-turret"].unit.ingredients = {
	{"automation-science-pack", 1},
	{"logistic-science-pack", 1},
}
data.raw.technology["ir-arc-turret"].unit.count = 200
data.raw.technology["ir-arc-turret-equipment"].unit.ingredients = {
	{"automation-science-pack", 1},
	{"logistic-science-pack", 1},
}
data.raw.technology["ir-arc-turret-equipment"].unit.count = 225
data.raw.technology["discharge-defense-equipment"].unit.ingredients = {
	{"automation-science-pack", 1},
	{"logistic-science-pack", 1},
}
data.raw.technology["discharge-defense-equipment"].unit.count = 250

-- Move recipe order in crafting menu
data.raw.recipe["arc-turret"].order = "b[turret]-b-a"

-- Adjust recipe ingredients
Recipe.setIngredients("arc-turret", {
	-- Originally 1 steel turret frame, 4 iron core EM coil, 1 high-capacity battery, 1 heavy copper cable.
	{"iron-frame-small", 1},
	{"iron-plate-heavy", 8},
	{"copper-cable-heavy", 1},
	{"copper-coil", 4},
})
Recipe.setIngredients("discharge-defense-equipment", {
	-- Originally computer-mk2 (red), steel-frame-small, 3x copper-coil, advanced-battery, 8x steel-rod
	{"iron-frame-small", 1},
	{"copper-coil", 4},
	{"iron-stick", 4},
	{"copper-cable-heavy", 1},
})
Recipe.setIngredients("arc-turret-equipment", {
	-- Originally computer-mk2 (red), 2x steel-frame-small, gyroscope, 4x copper-coil.
	{"iron-frame-small", 1},
	{"copper-coil", 4},
	{"copper-cable-heavy", 1},
})