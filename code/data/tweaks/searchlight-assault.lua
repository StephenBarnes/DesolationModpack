-- Remove the scenario, bc it won't work anyway with the other changes I'm making.
-- Looks like I can't remove it completely; rather just change its name/description.
-- Actually, can't do that either. Instead we need a script in control stage to handle on_game_created_from_scenario.

-- Remove the menu simulation
data.raw["utility-constants"].default.main_menu_simulations.sl_sweep = nil

-- Change icon
data.raw.item["searchlight-assault"].icon = "__Desolation__/graphics/searchlight-icon-modified.png"

-- Recipe
data.raw.recipe["searchlight-assault"].ingredients = {
	{"deadlock-large-lamp", 1},
	{"telemetry-unit", 1},
	{"iron-stick", 3},
	{"iron-plate", 4},
	{"iron-rivet", 2},
}