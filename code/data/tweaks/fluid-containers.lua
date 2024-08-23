--[[This file adjusts fluid containers.

Note that because of the containerization system, vehicle inventory sizes have been reduced by a factor of about 10.
Canisters can be packed into containers, so we don't need to adjust their amounts or stack sizes to compensate for this.
Barrels can't be packed into containers. Barrels are the fluid equivalent of containers. So they should store about 10x as much fluid each.
I'm removing fluid wagons and fluid tankers from the modpack completely, so barrels are the only way to transport fluids, which fits with how containerization is the only practical way to transport items.

This also means barrels need to have 10x the fuel value, so they're a much better way to fuel things like ships, vs canisters. I think that's fine.
Note that this means petroleum canisters are much less worthwhile as fuel. But iron canisters are still somewhat useful because at first 

Considering various fuel types:
	Steam:
		Fuel value is 3 MJ per 100 steam.
		Steam cell (made from 1.5 copper ingots) holds 100 steam, which is 3 MJ.
			Stack size 20, so 2000 steam per stack, so 60 MJ per stack.
			Can be packed into containers for 600 MJ per stack.
		Steam canister (made from 2.5 iron ingots) holds 200 steam, which is 6 MJ.
			Stack size 20, so 4000 steam per stack, so 120 MJ per stack.
			Can be packed into containers for 1200 MJ per stack.
	Petroleum:
		Fuel value is 4MJ per 10 petroleum.
		Petroleum canister holds 30 petroleum = 12 MJ.
			Stack size 20, so 600 petroleum per stack, so 240 MJ per stack.
			We can pack these into containers, each container holding 10 canisters, and 10 packed containers in a stack, for 2400 MJ per packed stack.
				Though, these need to be unpacked before you can actually use them.
		Barrel holds 600 petroleum = 240 MJ.
			Stack size 10, so 6000 petroleum per stack, so 2400 MJ per stack.
]]

local Recipe = require("code.util.recipe")
local Tech = require("code.util.tech")

local barrelFluidMultFactor = 10

-- Multiply fluid needed to fill, and fluid produced by emptying.
for _, recipe in pairs(data.raw.recipe) do
	if recipe.subgroup == "fill-barrel" then
		for _, ingredient in pairs(recipe.ingredients) do
			if ingredient.type == "fluid" then
				ingredient.amount = ingredient.amount * barrelFluidMultFactor
			end
		end
		recipe.energy_required = recipe.energy_required * barrelFluidMultFactor
	elseif recipe.subgroup == "empty-barrel" then
		for _, product in pairs(recipe.results) do
			if product.type == "fluid" then
				product.amount = product.amount * barrelFluidMultFactor
			end
		end
		recipe.energy_required = recipe.energy_required * barrelFluidMultFactor
	end
end

-- Multiply barrel fuel values.
-- Unfortunately item.fuel_value is a string, so we can't just multiply it by a number.
for barrelName, newFuelValue in pairs({
	["petroleum-gas-barrel"] = "240MJ",
	["ethanol-barrel"] = "240MJ",
}) do
	data.raw.item[barrelName].fuel_value = newFuelValue
end

-- Adjust barrel recipe.
-- Original IR3 recipe for barrel is 4 steel plate + 1 steel rivet.
-- Since we're making them hold 10x as much, makes sense to increase the cost.
-- Making them cost 4 heavy steel plate + 4 steel rivets.
Recipe.setIngredients("empty-barrel", {
	{"steel-plate-heavy", 4},
	{"steel-rivet", 4},
})

-- Add barrel disassembly recipe.
-- Since it costs 4 heavy plates + 4 rivets, perfect disassembly would produce 8 plates and 8 rivets. But change to 7-8 plates (losing 0-1 ingot) and 6-8 rivets (losing 0-1 ingot), and produce 0-2 scrap.
data:extend({{
	type = "recipe",
	name = "barrel-disassembly",
	enabled = false,
	localised_name = { "recipe-name.barrel-disassembly" },
	ingredients = {
		{"empty-barrel", 1},
	},
	results = {
		{type = "item", name = "steel-plate", amount_min = 7, amount_max = 8},
		{type = "item", name = "steel-rivet", amount_min = 6, amount_max = 8},
		{type = "item", name = "steel-scrap", amount_min = 0, amount_max = 2},
	},
	main_product = "steel-plate",
	subgroup = data.raw.recipe["empty-barrel"].subgroup,
	order = "d-2",
	allow_as_intermediate = false,
	allow_intermediates = false,
	allow_decomposition = false,
	icons = {
		-- Empty icon as background layer, because the sub-icons are sized relative to back layer.
		{
			icon = "__Desolation__/graphics/empty_icon.png",
			icon_size = 64,
			icon_mipmaps = 4,
			scale = 0.5
		},
		{ icon = data.raw.item["empty-barrel"].icon, icon_size = 64, icon_mipmaps = 4, scale = 0.4,  shift = { 0, -4 } },
		{ icon = data.raw.item["steel-plate"].icon,   icon_size = 64, icon_mipmaps = 4, scale = 0.35, shift = { -7, 7 } },
		{ icon = data.raw.item["steel-rivet"].icon,   icon_size = 64, icon_mipmaps = 4, scale = 0.35, shift = { 7, 7 } },
	},
}})

Tech.addRecipeToTech("barrel-disassembly", "ir-barrelling", 2)

-- Move high-pressure canister recipe to before the two barrel recipes.
data.raw.recipe["empty-barrel"].order = "d"