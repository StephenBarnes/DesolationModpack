local Tech = require("code.util.tech")
local Recipe = require("code.util.recipe")

-- Make a new wall type using the game's original wall sprites, and call it sth like "concrete wall". Make it require concrete and iron rods, and make it stronger than the brick wall.
-- TODO
local concWallEnt = table.deepcopy(data.raw.wall["stone-wall"])
concWallEnt.name = "concrete-wall"
concWallEnt.localised_name = {"item-name.concrete-wall"}
concWallEnt.minable.result = "concrete-wall"

local concWallItem = table.deepcopy(data.raw.item["stone-wall"])
concWallItem.name = "concrete-wall"
concWallItem.localised_name = {"item-name.concrete-wall"}
concWallItem.place_result = "concrete-wall"

local concWallRecipe = table.deepcopy(data.raw.recipe["stone-wall"])
concWallRecipe.name = "concrete-wall"
concWallRecipe.localised_name = {"item-name.concrete-wall"}
concWallRecipe.result = "concrete-wall"
concWallRecipe.ingredients = {{"concrete-block", 5}, {"iron-stick", 2}} -- TODO Fine-tune this by looking at factory planner.
concWallRecipe.order = "a2"
data.raw.recipe["stone-wall"].order = "a1"

-- TODO compare cost of ingredients

data:extend({concWallEnt, concWallItem, concWallRecipe})

Tech.addRecipeToTech("concrete-wall", "ir-concrete-1")

-- Use the sprites etc. of the IR3 "ancient-wall" for the regular wall, which I'll rename to "brick wall".
for k, v in pairs(data.raw.wall["ancient-wall"]) do
	if k ~= "name" and k ~= "minable" then
		data.raw.wall["stone-wall"][k] = v
	end
end
-- I don't think IR3 actually uses these icons, but it does include them.
data.raw.recipe["stone-wall"].icon = "__IndustrialRevolution3Assets1__/graphics/icons/64/stone-wall.png"
data.raw.recipe["stone-wall"].icon_size = 64
data.raw.recipe["stone-wall"].icon_mipmaps = 4
data.raw.item["stone-wall"].icon = "__IndustrialRevolution3Assets1__/graphics/icons/64/stone-wall.png"
data.raw.item["stone-wall"].icon_size = 64
data.raw.item["stone-wall"].icon_mipmaps = 4

-- IR3 steel plate wall is made of 4 reinforced steel plates, plus stone-wall (brick wall).
-- Modify it to use the concrete wall instead.
Recipe.substituteIngredient("steel-plate-wall", "stone-wall", "concrete-wall")

-- For health and resistances, before changing them:
-- Ancient wall is 350 max health, resistances 0/75 acid, 10/75 explosion, 0/100 fire, 40/50 impact, 3/50 physical.
-- Brick wall (which is vanilla's stone-wall) is the same as ancient wall.
-- Concrete wall is the same, bc I copied it. TODO make new ones.
-- Reinforced steel wall 1250 max health; resistances 0/50, 10/75, 0/100, 40/65, 3/50. So it's a bit better against impact, a bit worse against acid.
-- So, what changes to make? Going to reduce health of ancient/brick wall, increase health of concrete wall. And adjust resistances a bit.
data.raw.wall["ancient-wall"].max_health = 300
data.raw.wall["stone-wall"].max_health = 300
data.raw.wall["concrete-wall"].max_health = 450
data.raw.wall["steel-plate-wall"].max_health = 1250

local ancientAndBrickWallResistances = {
	{ type = "acid", decrease = 0, percent = 75 },
	{ type = "explosion", decrease = 5, percent = 50 },
	{ type = "fire", decrease = 0, percent = 100 },
	{ type = "impact", decrease = 20, percent = 25 },
	{ type = "physical", decrease = 2, percent = 50 },
}
data.raw.wall["ancient-wall"].resistances = ancientAndBrickWallResistances
data.raw.wall["stone-wall"].resistances = ancientAndBrickWallResistances
data.raw.wall["concrete-wall"].resistances = {
	{ type = "acid", decrease = 0, percent = 75 },
	{ type = "explosion", decrease = 10, percent = 75 },
	{ type = "fire", decrease = 0, percent = 100 },
	{ type = "impact", decrease = 40, percent = 50 },
	{ type = "physical", decrease = 3, percent = 50 },
}
data.raw.wall["steel-plate-wall"].resistances = {
	{ type = "acid", decrease = 0, percent = 50 },
	{ type = "explosion", decrease = 15, percent = 75 },
	{ type = "fire", decrease = 0, percent = 100 },
	{ type = "impact", decrease = 40, percent = 80 },
	{ type = "physical", decrease = 5, percent = 50 },
}

-- Ancient wall mining should give more stone
-- Hm, note that it says +1 stone even though it produces multiple stone. The floating text just isn't accurate. Seems like a bug in base Factorio.
data.raw.wall["ancient-wall"].minable = {
	mining_time = data.raw.wall["stone-wall"].minable.mining_time,
	results = {{type = "item", name = "stone", amount = 4}},
}

-- TODO check that scrapping recipes worked.

-- TODO change map colors.