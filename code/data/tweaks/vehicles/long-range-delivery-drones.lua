local Tech = require("code.util.tech")
local Recipe = require("code.util.recipe")

Tech.setPrereqs("long-range-delivery-drone", {"ir-crude-oil-processing", "telemetry"})
Recipe.setIngredients("long-range-delivery-drone", {
	{"electronic-circuit", 1},
	{"petroleum-gas-iron-canister", 1},
	{"engine-unit", 1},
	{"steel-plate", 10},
})
Recipe.setIngredients("long-range-delivery-drone-depot", {
	{"computer-mk1", 1},
	{"steel-chest", 2},
	{"steel-plate", 40},
})
Recipe.setIngredients("long-range-delivery-drone-request-depot", {
	{"steel-chest", 2},
	{"steel-plate", 20},
})

data.raw.item["long-range-delivery-drone"].localised_name={"item-name.long-range-delivery-drone"}
data.raw.item["long-range-delivery-drone"].localised_description={"item-description.long-range-delivery-drone"}
data.raw["logistic-container"]["long-range-delivery-drone-depot"].localised_name={"entity-name.long-range-delivery-drone-depot"}
data.raw["logistic-container"]["long-range-delivery-drone-depot"].localised_description={"entity-description.long-range-delivery-drone-depot"}
data.raw["logistic-container"]["long-range-delivery-drone-request-depot"].localised_name={"entity-name.long-range-delivery-drone-request-depot"}
data.raw["logistic-container"]["long-range-delivery-drone-request-depot"].localised_description={"entity-description.long-range-delivery-drone-request-depot"}
data.raw.technology["long-range-delivery-drone"].localised_name = {"technology-name.long-range-delivery-drone"}
data.raw.technology["long-range-delivery-drone"].localised_description = {"technology-description.long-range-delivery-drone"}

data.raw["logistic-container"]["long-range-delivery-drone-depot"].inventory_size = 40
data.raw["logistic-container"]["long-range-delivery-drone-request-depot"].inventory_size = 40