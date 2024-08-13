-- Make a new wall type using the game's original wall sprites, and call it "concrete wall". Make it require concrete and iron rods, and make it stronger than the brick wall.
-- Then rename the vanilla wall item to "Brick wall", and make it use IR3's alternative wall sprites.

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
concWallRecipe.result_count = 2
concWallRecipe.ingredients = {{"concrete-block", 6}, {"iron-stick", 2}} -- TODO Fine-tune this by looking at factory planner.
concWallRecipe.order = "a2"
data.raw.recipe["stone-wall"].order = "a1"

data:extend({concWallEnt, concWallItem, concWallRecipe})

--Tech.addRecipeToTech("concrete-wall", "ir-concrete-1") -- Rather adding to fortified-defense-3 tech.

-- IR3 steel plate wall is made of 4 reinforced steel plates, plus stone-wall (brick wall).
-- Want to modify it to use the concrete wall instead.

-- Let's compare the cost of ingredients between the 3 wall types, considering 60/min production, calculating with Factory Planner.
-- For stone brick wall: 1.6 steam assemblers, 8 mini-assemblers for bricks, 5.3 steam miners on stone.
--   Overall resource intake: 400 stone deposit, plus some steam. 80 pollution per minute.
-- For concrete wall: 1.6 electric stone miners and 0.5 electric iron miners, to 1 crusher for iron, 1.6 furnace for iron, 0.8 mini assembler for iron rod; then 4.8 electric crushers for gravel, 3.2 more crushers for sand, 1.6 mixers for concrete, 3.2 assemblers for concrete blocks, 0.8 assemblers for concrete wall.
--   I think overall that's pretty reasonable. It's a lot more complex, but by this point you have much more resources.
--   Overall resource intake: 240 stone deposit, 80 iron deposit, 3MW electricity, bit of fuel for furnace. 70 pollution per minute.
--   Note that total resource intake actually went down compared to brick walls. And that's for a wall with twice the health.
--   Nice tradeoff for the added complexity, I think.
-- For steel plate wall: all the stuff required to make concrete wall, plus an additional 2.6 iron miners and 0.3 coal miners, to 6 crushers, 17 furnaces, 5 mini-assemblers, 3 assemblers for reinforced steel plates, and 3 for the reinforced steel plate wall.
--   Overall resource intake: concrete stuff, plus 400 iron, 50 coal. 190 pollution per minute. 5.4 MW electricity.
--   So overall, it's a lot of machines and electricity, but overall resource intake isn't very high. I'm making them significantly stronger than concrete walls.
--   I think it's a good tradeoff. They should be expensive, so you only use them where necessary.

data.raw.recipe["steel-plate-wall"].ingredients = {
	{"steel-plate-heavy", 2},
	{"concrete-wall", 1},
}

-- Use the sprites etc. of the IR3 "ancient-wall" for the regular wall, which I'll rename to "brick wall".
for k, v in pairs(data.raw.wall["ancient-wall"]) do
	if k ~= "name" and k ~= "minable" then
		data.raw.wall["stone-wall"][k] = v
	end
end
data.raw.recipe["stone-wall"].icon = "__IndustrialRevolution3Assets1__/graphics/icons/64/stone-wall.png"
data.raw.recipe["stone-wall"].icon_size = 64
data.raw.recipe["stone-wall"].icon_mipmaps = 4
data.raw.item["stone-wall"].icon = "__IndustrialRevolution3Assets1__/graphics/icons/64/stone-wall.png"
data.raw.item["stone-wall"].icon_size = 64
data.raw.item["stone-wall"].icon_mipmaps = 4

-- For health and resistances, before changing them:
-- Ancient wall is 350 max health, resistances 0/75 acid, 10/75 explosion, 0/100 fire, 40/50 impact, 3/50 physical.
-- Brick wall (which is vanilla's stone-wall) is the same as ancient wall.
-- Concrete wall is the same, bc I copied it.
-- Reinforced steel wall 1250 max health; resistances 0/50, 10/75, 0/100, 40/65, 3/50. So it's a bit better against impact, a bit worse against acid.
-- So, what changes to make? Going to reduce health of ancient/brick wall, increase health of concrete wall. And adjust resistances a bit.
-- Did some in-game testing as well, driving into walls with vehicles. TODO check these numbers with actual bug attacks.
data.raw.wall["ancient-wall"].max_health = 300
data.raw.wall["stone-wall"].max_health = 300
data.raw.wall["concrete-wall"].max_health = 600
data.raw.wall["steel-plate-wall"].max_health = 1250

local ancientAndBrickWallResistances = {
	{ type = "acid", decrease = 0, percent = 75 },
	{ type = "explosion", decrease = 5, percent = 50 },
	{ type = "fire", decrease = 0, percent = 100 },
	{ type = "impact", decrease = 10, percent = 25 },
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
	{ type = "explosion", decrease = 10, percent = 85 },
	{ type = "fire", decrease = 0, percent = 100 },
	{ type = "impact", decrease = 0, percent = 100 }, -- Complete impact resistance. Kinda nice to have something with this, eg for the sides of a road.
	{ type = "physical", decrease = 5, percent = 70 },
}

-- Ancient wall mining should give more stone
-- Hm, note that it says +1 stone even though it produces multiple stone. The floating text just isn't accurate. Seems like a bug in base Factorio.
data.raw.wall["ancient-wall"].minable = {
	mining_time = data.raw.wall["stone-wall"].minable.mining_time,
	results = {{type = "item", name = "stone", amount = 4}},
}

-- Checked that scrapping recipes were created for the new wall types - yes, they work.

-- Change map colors so it's visible against the mostly-snowy terrain.
-- Originally all of them were 0.8, 0.85, 0.8.
data.raw.wall["ancient-wall"].map_color = {r=0.55, g=0.55, b=0.55}
data.raw.wall["stone-wall"].map_color = {r=0.55, g=0.55, b=0.55}
data.raw.wall["concrete-wall"].map_color = {r=0.35, g=0.35, b=0.35}
data.raw.wall["steel-plate-wall"].map_color = {r=0.2, g=0.2, b=0.2}