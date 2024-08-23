--[[
Concrete slabs and refined concrete slabs are only used for paving. (Concrete is used for buildings too, but that's concrete blocks, not paving.)
Should we tweak concrete etc to be cheaper, so they're more worthwhile?

With base IR3 (plus powered pumps), to make 1/sec of tiles:
	Brick:
		Materials: 1.333 stone (this is the tile entity, not stone item; it's 1 stone item).
		Infra: 0.5 electric miner, 0.4 small assembler.
			Total 0.7 machines, counting small assemblers as half.
		Uses 300kW, 16/m pollution.
		120% walk speed. 110% vehicle friction.
	Concrete:
		Made from liquid concrete (from mixing water, sand, gravel), and iron rods.
		Materials: 1 stone, 0.6 iron.
		Infra: 0.4 assembler, 0.4 mixer, 2.5 crusher, 0.7 miner, 0.02 offshore pump, 0.4 small assembler, 0.8 electric furnace.
			Total 5 machines.
		Uses 992kW, 24.8/m pollution.
		140% walk speed. 80% vehicle friction.
	Refined concrete:
		Made from liquid concrete (from mixing water, sand, gravel), and steel rods, and sulphur.
			Sulphur TODO
		Materials: 3 sour gas, 2 stone, 0.6 iron, 0.08 coal.
		Infra: 9.6 machines.
		Uses 1.92 MW, 44.4/m pollution.
		150% walk speed. 80% vehicle friction.
	Tarmac:
		Made from gravel and bitumen.
			Bitumen comes from crude oil processing, and can be used for tarmac, or for graphite (via graphitic coke), or turned into oil (via diluted bitumen => bitumen upgrading).
		Materials: 0.6 stone, 36 crude oil.
		Infra: 2.7 machines.
		Uses 826kW, 16.6/m pollution.
		140% walk speed. 60% vehicle friction.

I think that we should make concrete cheaper than brick, but requiring a more complex setup to manufacture. Similar for tarmac.
(I already did this for brick vs concrete walls. Concrete walls are both cheaper and stronger, but more complex to produce.)

So for the recipes:
	Concrete should be cheaper. Maybe halve the amount of iron, and produce 15 instead of 10.
		Well, making it produce 15 as output causes issues with scrapping recipes (allowing free resources by scrapping and remaking concrete).
			Seems to be because IR3 is assuming the output is 10, and basing calculations on that.
			So, rather only adjust ingredients, not result count.
	Refined concrete should be cheaper too, because the tech is already a significant expense, and the added complexity (needing sulphur) is another significant expense.
	Tarmac is fine. Brick path is fine.

Also change speeds for walking:
	Change concrete to 135%, so it's better than brick but noticeably worse than refined concrete.
	Change refined concrete to 160%, so it's even better for frequently-used paths.
	Reduce tarmac to 120%, so it's more uniquely suited to vehicles.
	Also change the hazard concrete tiles to match.
Change vehicle friction modifiers so tarmac is more noticeably better, and refined concrete is also good.

Also renamed "slab" to "paving slab" in locale file, to make it clear it's just for paving, unlike concrete blocks.
Also add explanations to tech descriptions and item descriptions.
]]

local Recipe = require("code.util.recipe")

-- Change tile walk speeds and vehicle friction values.
local walkSpeeds = {
	["stone-path"] = 1.2,
	["concrete"] = 1.35,
	["hazard-concrete-left"] = 1.35,
	["hazard-concrete-right"] = 1.35,
	["tarmac"] = 1.2,
	["refined-concrete"] = 1.6,
	["refined-hazard-concrete-left"] = 1.6,
	["refined-hazard-concrete-right"] = 1.6,
}
local vehicleFriction = {
	["stone-path"] = 1.1,
	["concrete"] = 0.8,
	["hazard-concrete-left"] = 0.8,
	["hazard-concrete-right"] = 0.8,
	["tarmac"] = 0.4,
	["refined-concrete"] = 0.7,
	["refined-hazard-concrete-left"] = 0.7,
	["refined-hazard-concrete-right"] = 0.7,
}
for tileName, walkSpeed in pairs(walkSpeeds) do
	log("Changing walk speed of "..tileName.." to "..walkSpeed)
	data.raw.tile[tileName].walking_speed_modifier = walkSpeed
end
for tileName, friction in pairs(vehicleFriction) do
	data.raw.tile[tileName].vehicle_friction_modifier = friction
end

-- Change recipes
Recipe.setIngredients("concrete", {
	{"iron-stick", 4}, -- Reduced 10 -> 4
	{type="fluid", name="concrete-fluid", amount=80}, -- Reducing 100 -> 80
})
Recipe.setIngredients("refined-concrete", {
	{"sulfur", 1}, -- Originally 3, reducing
	{"steel-rod", 4}, -- Originally 10, reducing
	{type="fluid", name="concrete-fluid", amount=80}, -- Originally 200, reducing
})

--[[
With these modified recipes:
	(For reference, stone brick is 1.33 stone, 0.73 machines, 300 kW, 16/m pollution.)
	Concrete:
		Materials: 0.7 stone, 0.27 iron.
		Infra: ~3 machines.
		Uses 623 kW, 14/m pollution.
	Refined concrete:
		Materials: 1 sour gas, 0.7 stone, 0.27 iron, 0.03 coal.
		Infra: 4.3 machines.
		Uses 836 kW, 17/m pollution.
]]

--[[
Increased result amounts for concrete and refined concrete, 10=>15. Checking scrapping recipes:
	For concrete:
		1 concrete paving slab => 0.2 iron scrap + 0.75 concrete scrap => 0.2 iron ingots + 7.5 liquid concrete. (Assuming water is free.)
		Making 1 concrete paving slab requires 100/15 = 6.67 liquid concrete, plus 5/15 = 1/3 iron rods = 1/6 = 0.167 iron ingots.
	I think, to make IR3 create the scrapping recipes properly, we should leave the result amount as-is, and only change ingredients.
After doing that, checking again:
	For concrete:
		1 concrete paving slab => 0.15 iron scrap + 0.6 concrete scrap => 0.15 iron ingots + 6 liquid concrete. (Assuming water is free.)
		Making 1 concrete paving slab requires 0.2 iron ingots and 8 liquid concrete.
	So, everything checks out now, scrapping is 75% efficient as expected.
]]