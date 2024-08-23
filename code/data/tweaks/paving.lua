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
	Refined concrete is fine. Tarmac is fine. Brick path is fine.
With this modified recipe, concrete is now:
	Materials: 0.6 stone, 0.22 iron.
	Infra: 2.5 machines.
	Uses 518 kW, 11.4/m pollution.

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
	["refined-concrete"] = 0.6,
	["refined-hazard-concrete-left"] = 0.6,
	["refined-hazard-concrete-right"] = 0.6,
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
	{"iron-stick", 5}, -- Reduced 10 -> 5
	{type="fluid", name="concrete-fluid", amount=100}, -- Keeping this the same.
})
Recipe.setResults("concrete", {
	{"concrete", 15}, -- Increasing 10 -> 15
})