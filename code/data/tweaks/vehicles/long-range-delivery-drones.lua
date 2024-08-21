local Tech = require("code.util.tech")
local Recipe = require("code.util.recipe")

-- The buildings added by Long-Range Delivery Drones mod are capable of functioning as advanced logistics chests.
-- But, with IR3, we only unlock advanced logistics chests at the end of the game.
-- So, to prevent abusing these buildings, I'll make them expensive and place the tech after red circuits.

Tech.setPrereqs("long-range-delivery-drone", {"ir-electronics-2", "telemetry"})
data.raw.technology["long-range-delivery-drone"].unit = table.deepcopy(data.raw.technology["ir-electronics-2"].unit)

Recipe.setIngredients("long-range-delivery-drone", {
	{"advanced-circuit", 1},
	{"petroleum-gas-iron-canister", 1},
	{"engine-unit", 1},
	{"steel-plate", 20},
})
Recipe.setIngredients("long-range-delivery-drone-depot", {
	{"computer-mk2", 2},
	{"steel-chest", 2},
	{"steel-frame-large", 1},
})
Recipe.setIngredients("long-range-delivery-drone-request-depot", {
	{"advanced-circuit", 1},
	{"steel-chest", 1},
	{"steel-frame-large", 1},
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