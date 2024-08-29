local Recipe = require("code.util.recipe")

-- Unmark the airships as military target. Bc otherwise BREAM is going to spawn bugs in all the frigid terrain, and they'll attack your airships. Anyway makes sense the bugs wouldn't be able to reach the airships.
data.raw["spider-vehicle"]["hydrogen-airship"].is_military_target = false
data.raw["spider-vehicle"]["helium-airship"].is_military_target = false
data.raw["spider-vehicle"]["hydrogen-airship"].spider_engine.military_target = nil
data.raw["spider-vehicle"]["helium-airship"].spider_engine.military_target = nil

-- The advanced vehicle remote (spidertron-remote) is was originally advanced computer + steel rod.
-- Could include telemetry unit?
Recipe.setIngredients("spidertron-remote", {
	{"steel-plate", 1},
	{"advanced-circuit", 1},
	{"steel-rod", 1},
})

-- For airship recipes, I could include telemetry unit, and maybe reduce raw material cost a bit because I like the airships and want them to be viable despite also making them slow and low-cargo-capacity.
-- Also don't want more than ~5 ingredients.
-- Re progression:
--   Currently the hydrogen airship is a few techs after washing 1, while helium airship is after blue circuits.
--   We want there to be a bit of a time gap between them. Blue circuits are very late-game.
Recipe.setIngredients("hydrogen-airship", {
	--{"telemetry-unit", 1}, -- new
	{"computer-mk2", 1}, -- unchanged
	{"engine-unit", 4}, -- unchanged
	{"steel-plate", 80}, -- unchanged
	{"steel-beam", 40}, -- unchanged
	{type="fluid", name="hydrogen-gas", amount=2000}, -- unchanged
})
Recipe.setIngredients("helium-airship", {
	--{"telemetry-unit", 1}, -- new
	{"computer-mk3", 1}, -- unchanged
	{"chromium-engine-unit", 8}, -- unchanged
	{"chromium-plate", 120}, -- unchanged
	{"chromium-beam", 40}, -- unchanged
	{type="fluid", name="helium-gas", amount=2000}, -- unchanged
})
-- Could adjust airship station recipe. - TODO