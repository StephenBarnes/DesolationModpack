--[[ This file tweaks the loaders and bundlers added by IR3 loaders and stacking mod.

The loader stuff here is the result of significant iteration. Things I've tried/considered:
	Having no loaders.
		Abandoned this because inserters aren't fast enough to use bundlers and packers fast enough, plus having 8 inserters feeding into a packer looks stupid.
	Having only IR3 loaders, unmodified.
		Abandoned this because then there's rarely any reason to use fast inserters and stack inserters.
	Having only IR3 loaders, but with greater electric consumption.
		Abandoned this because it's boring, and feels stupid to have a 1x1 simple machine that consumes a megawatt or whatever.
	Having both IR3 loaders (steam and electric) and AAI loaders (consuming lubricant), with the IR3 loaders only allowed with specific machines like bundlers and packers.
		This was done by implementing these restrictions in my other mod Harder Basic Logistics, and including that mod as a dependency.
		Abandoned this idea because it's too complex having 2 sets of loaders and then having to explain in every description that a machine allows "unlubricated loaders", etc.
	Having both IR3 loaders and AAI loaders, but disabling all IR3 loaders except the steam one, and having the AAI loaders require lubricant.
		Abandoned this because it has two weirdly different systems for fluid consumption, with IR3 using it as fuel and AAI having control scripts with unknown performance implications, as well as different graphics and icons, and using vanilla pipe graphics that don't match IR3's pipes, etc.
Ultimately, the solution I ended up with is:
	Use only IR3 loaders.
	Make the IR3 loaders (except steam) require lubricant as fuel, so they require extra logistics complexity vs inserters.
		(Since Desolation has the factory spread across warm patches, shipping around lubricant is a challenge. Without the warm-patches system, you could just have one big base with a lubricant fluid network.)
	Loaders (except steam) come after lubricant, in the tech progression. So you have to use inserters and steam loaders at least until after oil.
		I'm creating "bulk logistics" techs for loaders and bundlers.
	For steam loader, we can't require lubricant, so rather increase its power consumption somewhat.
]]

-- Checked that all loaders and bundlers can in fact handle entire yellow/red/blue belts. Including steam.

local Tech = require("code.util.tech")
local Recipe = require("code.util.recipe")

------------------------------------------------------------------------
-- COMPUTE BELT SPEEDS

local beltTierNames = {
	"transport-belt",
	"fast-transport-belt",
	"express-transport-belt",
}
local beltTierSpeeds = {} -- Speed per second
for i, beltName in pairs(beltTierNames) do
	-- The .speed field is 480 times higher than the items per second, see docs.
	beltTierSpeeds[i] = data.raw["transport-belt"][beltName].speed * 480
end

------------------------------------------------------------------------
-- ADJUST TECHS/PROGRESSION
-- I think a separate tech for every loader and inserter is excessive, so rather unify some of them.

-- Put steam loader and beltbox in one tech.
Tech.hideTech("ir3-beltbox-steam")
Tech.addRecipeToTech("ir3-beltbox-steam", "ir3-loader-steam")
-- Leaving the icon as-is.
data.raw.technology["ir3-loader-steam"].localised_description = {"technology-description.ir3-loader-steam"}

-- Unify yellow electric loader and bundler techs, and put it after lubricant.
local yellowBulkLogisticsTech = {
	type = "technology",
	name = "bulk-logistics-1",
	effects = {
		{
			type = "unlock-recipe",
			recipe = "ir3-loader",
		},
		{
			type = "unlock-recipe",
			recipe = "ir3-beltbox",
		},
	},
	prerequisites = {"lubricant", "ir3-loader-steam"},
	unit = {
		count = 500,
		ingredients = {
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"chemical-science-pack", 1},
		},
		time = 60,
	},
	icons = data.raw.technology["ir3-loader"].icons,
	icon = data.raw.technology["ir3-loader"].icon,
	icon_size = data.raw.technology["ir3-loader"].icon_size,
	icon_mipmaps = data.raw.technology["ir3-loader"].icon_mipmaps,
}

-- Unify red loader and bundler techs, and put it after the yellow tech and red belts.
local redBulkLogisticsTech = {
	type = "technology",
	name = "bulk-logistics-2",
	effects = {
		{
			type = "unlock-recipe",
			recipe = "ir3-fast-loader",
		},
		{
			type = "unlock-recipe",
			recipe = "ir3-fast-beltbox",
		},
	},
	prerequisites = {"logistics-2", "bulk-logistics-1"},
	unit = {
		count = 600,
		ingredients = {
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"chemical-science-pack", 1},
		},
		time = 60,
	},
	icons = data.raw.technology["ir3-fast-loader"].icons,
	icon = data.raw.technology["ir3-fast-loader"].icon,
	icon_size = data.raw.technology["ir3-fast-loader"].icon_size,
	icon_mipmaps = data.raw.technology["ir3-fast-loader"].icon_mipmaps,
}

-- Unify blue loader and bundler techs, and put it after the red bulk logistics tech and blue belts.
local blueBulkLogisticsTech = {
	type = "technology",
	name = "bulk-logistics-3",
	effects = {
		{
			type = "unlock-recipe",
			recipe = "ir3-express-loader",
		},
		{
			type = "unlock-recipe",
			recipe = "ir3-express-beltbox",
		},
	},
	prerequisites = {"logistics-3", "bulk-logistics-2"},
	unit = {
		count = 1100,
		ingredients = {
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"chemical-science-pack", 1},
		},
		time = 60,
	},
	icons = data.raw.technology["ir3-express-loader"].icons,
	icon = data.raw.technology["ir3-express-loader"].icon,
	icon_size = data.raw.technology["ir3-express-loader"].icon_size,
	icon_mipmaps = data.raw.technology["ir3-express-loader"].icon_mipmaps,
}

data:extend({yellowBulkLogisticsTech, redBulkLogisticsTech, blueBulkLogisticsTech})

for _, techName in pairs({
	"ir3-loader",
	"ir3-beltbox",
	"ir3-fast-loader",
	"ir3-fast-beltbox",
	"ir3-express-loader",
	"ir3-express-beltbox",
}) do
	Tech.hideTech(techName)
end

------------------------------------------------------------------------
-- RECIPE TWEAKS
-- I don't want loaders or bundlers to require circuits.
-- Beltboxes should be cheap because they're interesting and limited to ingots etc. Loaders should be cheap because they require lubricant.
-- Keep circuits for inserters, which seem like they need more actual intelligence.

Recipe.setIngredients("ir3-beltbox", {
	-- Originally 1 green circuit + 1 small iron frame + 1 electric motor + 2 iron gears.
	{"iron-frame-small", 1},
	{"iron-motor", 1},
	{"iron-gear-wheel", 4},
})
-- ir3-loader is 1 green circuit + 1 small iron frame + 1 transport belt + 2 iron piston.
Recipe.removeIngredient("ir3-loader", "electronic-circuit")
-- Rest of the recipes look fine, just remove circuits.
Recipe.removeIngredient("ir3-fast-beltbox", "electronic-circuit")
Recipe.removeIngredient("ir3-fast-loader", "electronic-circuit")
Recipe.removeIngredient("ir3-express-beltbox", "advanced-circuit")
Recipe.removeIngredient("ir3-express-loader", "advanced-circuit")

------------------------------------------------------------------------
-- TWEAKING IR3 LOADERS (EXCEPT STEAM)
-- I'm changing the loaders to require lubricant, instead of electricity, so there's still good reasons to use fast and stack inserters.
-- To do this, I'm giving lubricant a fuel value. (Could instead take the complex AAI Loaders approach of control scripts and invisible entities, etc., but that's unnecessarily complex.)

local lubricantKJ = 150 -- kJ per unit of fluid
data.raw.fluid.lubricant.fuel_value = lubricantKJ .. "KJ"
-- Note this allows the petrochem generator to accept lubricant. Can't see any way to prevent petrochem generator from burning a specific fluid.
-- I think that's actually fine, since lubricant is flammable (according to some quick research).
-- For comparison, petroleum and ethanol are 400kJ per fluid unit.
-- Per fluid unit, lubricant costs about 2 crude oil, while petroleum costs 1.5 crude oil. So petroleum is now both cheaper and has higher fuel value. So this value doesn't unbalance the game.

--[[ How much lubricant should the loaders consume?
In the AAI Loaders mod, loaders consume 0.1 or 0.15 or 0.2 lubricant per minute. That's 0.00333 to 0.001667 per second, or 0.000111 to 0.0000370370 per item.
Doing some calculations, 1 refinery and 1 chemical plant can produce 750 lubricant per minute, enough to power 7500 yellow loaders.
Looking at it another way, a train wagon has 10 slots, each holding 10 barrels of 600 lubricant. So a train wagon can hold 60,000 lubricant, enough to power 100 loaders for (60,000lube / 100) / (0.1lube/minute) = 6000 minutes = 100 hours.
I think this lubricant consumption is too low. But also, they shouldn't be that great of a lubricant drain; their cost is extra logistics complexity to ship around lubricant, not extra resource strain from consuming large amounts of lubricant.
So, let's make them consume 10x as much lubricant as in AAI Loaders.
]]

local lubedLoaderStats = {
	{name="loader", beltTier=1, lubricantPerMinute=1},
	{name="fast-loader", beltTier=2, lubricantPerMinute=1.5},
	{name="express-loader", beltTier=3, lubricantPerMinute=2.0},
}

-- Function to set a loader to consume lubricant.
local function setLoaderToConsumeLubricant(loaderName, lubricantPerItem)
	local originalEnergySource = data.raw["loader-1x1"][loaderName].energy_source
	if originalEnergySource == nil then
		log("ERROR: Couldn't find original energy source for loader "..loaderName)
		return
	end
	local loader = data.raw["loader-1x1"][loaderName]
	loader.energy_source = table.deepcopy(data.raw["loader-1x1"]["ir3-loader-steam"].energy_source)
	loader.energy_source.smoke = originalEnergySource.smoke
	loader.energy_source.emissions_per_minute = originalEnergySource.emissions_per_minute
	loader.energy_source.fluid_box.filter = "lubricant"
	---@diagnostic disable-next-line: undefined-global
	loader.energy_source.fluid_box.pipe_covers = DIR.pipe_covers.iron -- DIR defined in IR3.
	loader.energy_source.destroy_non_fuel_fluid = false -- So don't destroy other fluids moved into the loader.
	loader.energy_per_item = (lubricantPerItem * lubricantKJ) .. "KJ"

	-- IR3 steam loader has base area 0.5, so it can hold 100 steam. Lubricant-consuming loaders consume much less fluid than steam loaders, so reduce amount stored to 10.
	loader.energy_source.fluid_box.base_area = 0.05

	-- For steam loader, speed depends on steam temperature. For lubricant, we want it to instead calculate based on the fluid's fuel value, not temperature.
	loader.energy_source.burns_fluid = true

	-- Add lubricant icon to loader's icon.
	local loaderItem = data.raw.item[loaderName]
	if loaderItem.icons == nil or #loaderItem.icons ~= 1 then
		log("ERROR: Unexpected format for original icon for "..(loaderName or "nil")..": "..serpent.block(loaderItem))
	else
		local originalIcon = loaderItem.icons[1]
		loaderItem.icons = {
			{
				icon = originalIcon.icon,
				icon_size = originalIcon.icon_size,
				icon_mipmaps = originalIcon.icon_mipmaps,
				scale = 0.5,
			},
			{
				icon = data.raw.fluid.lubricant.icon,
				icon_size = data.raw.fluid.lubricant.icon_size,
				icon_mipmaps = data.raw.fluid.lubricant.icon_mipmaps,
				scale = 0.25,
				shift = {-7, 10},
			},
		}
	end
end

for _, loader in pairs(lubedLoaderStats) do
	-- Calculate lubricant per item.
	local itemsPerMinute = beltTierSpeeds[loader.beltTier] * 60
	local lubricantPerItem = loader.lubricantPerMinute / itemsPerMinute

	-- Call function to make the loader consume lubricant.
	setLoaderToConsumeLubricant("ir3-"..loader.name, lubricantPerItem)

	-- Set description of the loader, with these numbers.
	-- Using shared description strings with parameters for these.
	local itemsPerLubricant = 1 / lubricantPerItem
	-- Format itemsPerLubricant to have commas between thousands.
	local itemsPerLubricantString
    if itemsPerLubricant >= 1000 then
        itemsPerLubricantString = string.format("%d,%03d", itemsPerLubricant / 1000, itemsPerLubricant % 1000)
    else
        itemsPerLubricantString = string.format("%.0f", itemsPerLubricant)
    end
	data.raw["loader-1x1"]["ir3-"..loader.name].localised_description = {
		"shared-description.ir3-loader-ALL",
		{"belt-tier-name.tier-"..loader.beltTier},
		loader.lubricantPerMinute,
		itemsPerLubricantString,
	}
	-- Checked in-game that moving 900 items does in fact consume 1 lubricant with yellow loaders.
end

------------------------------------------------------------------------
-- STEAM LOADER

-- Steam loader uses a special description.
data.raw["loader-1x1"]["ir3-loader-steam"].localised_description = {
	"shared-description.ir3-loader-steam",
	{"belt-tier-name.tier-1"},
}

-- Steam loader has unique energy consumption.
-- For comparison, a steam inserter is 35kW and moves ~1 item per second (360 degrees per second).
-- Setting steam loader to consume 100kW. So a steam loader consumes 3x as much energy, to move 15x as many items per second.
data.raw["loader-1x1"]["ir3-loader-steam"].energy_per_item = "6.6666667kJ" -- 6.667kJ per item * 15 items per second = 100kW.

------------------------------------------------------------------------
-- ADD STEAM MINI-ICONS TO STEAM LOADER AND BUNDLER

-- Change the icon for IR3 steam loader. (Originally to distinguish from AAI loaders which were also in, but I've since removed them; keeping this though.)
for _, itemName in pairs({"ir3-loader-steam", "ir3-beltbox-steam"}) do
	data.raw.item[itemName].icons = {
		data.raw.item[itemName].icons[1],
		{
			icon = "__IndustrialRevolution3Assets1__/graphics/icons/64/steam.png",
			icon_size = 64,
			icon_mipmaps = 4,
			scale = 0.25,
			shift = {-7, 10},
		},
	}
end

------------------------------------------------------------------------
-- BUNDLERS - ENERGY AND DESCRIPTIONS

-- Re bundler energy consumption:
-- An inserter is ~20kW, so ~20kJ per item. Currently bundlers are 60-120-180kW, so 4kJ per item.
-- I want to add some economies of scale for higher-tier bundlers, same as I'm doing for lubricant consumption of loaders.
-- So, going to change them to 6-4-3kJ per item, so power consumptions of 90-120-135kJ.
-- This is 24 - 16 - 12 kJ per bundle.
-- These usages scale with how much time the bundler spends active vs passive (since with less than a full belt of input it only runs some fraction of the time).

local bundlerStats = {
	{name="beltbox-steam", beltTier=1, kJPerBundle=24},
	{name="beltbox", beltTier=1, kJPerBundle=24},
	{name="fast-beltbox", beltTier=2, kJPerBundle=16},
	{name="express-beltbox", beltTier=3, kJPerBundle=12},
}

for _, bundler in pairs(bundlerStats) do
	-- Set energy consumption.
	data.raw.furnace["ir3-"..bundler.name].energy_usage = (beltTierSpeeds[bundler.beltTier] * bundler.kJPerBundle / 4) .. "kW"

	-- Set description.
	data.raw.furnace["ir3-"..bundler.name].localised_description = { -- The entities are registered as furnaces.
		"shared-description.ir3-beltbox-ALL",
		{"belt-tier-name.tier-"..bundler.beltTier},
		bundler.kJPerBundle,
	}
end

------------------------------------------------------------------------
-- INSERTERS
-- Adjusting inserter speeds and power consumptions.

--[[
In vanilla:
	burner inserters rotate at 216d/s, consume 94.2kW, move 0.6items/s.
	inserters rotate 302d/s, 0.4-13.6kW, 0.8i/s.
	fast inserters 864d/s, 0.5-46.7kW, 2.3i/s.
	stack inserters 864d/s, 1-133kW, 4.5i/s. (This is hand size 1 with a +1 in the stack inserter tech.)
	(All of these increase with the inserter capacity bonus techs.)
In base IR3:
	burner inserters 360d/s, 35kW, 1i/s.
	steam inserters 360d/s, 35kW, 1i/s.
	inserters 360d/s, 0.4-17.9kW, 1i/s.
	fast inserters 720d/s, 0.5-59.5kW, 1.9i/s.
	stack inserters 720d/s, 1-141kW, ~2*6=12i/s. (Tech comes with a +5 to capacity.)
	(IR3 has techs to increase hand stack size for all of these.)

Re the IR3 values:
	I like that IR3 simplifies the rotation rate and therefore item throughput per inserter (making it 1 or 2 rotations per second instead of vanilla's 0.8 etc.).
	I don't like that the IR3 energy consumption values aren't round numbers. Both per-second and per-item are irregular numbers.
	I don't like that the energy per item is highest for the fast inserter. In the chain from inserter to fast inserter to stack inserter, energy per item goes up and then down.
		I want to adjust energy consumption so there's economies of scale: faster-moving inserters use more energy per second, but less energy per item.

I think filter inserters should have the same energy consumption as plain inserters, since you can already get their functionality without ongoing energy costs by just using a splitter, plus they already have an extra cost in materials (circuits).

I'm adjusting the drain (inactive energy consumption) to be 5% of active energy consumption, and 10% for stack inserters.

Note: In Desolation, I'm removing the inserter capacity increase techs, because I've added loaders, and because I don't like those incremental techs.
]]

local inserterStats = {
	-- Table of inserter names, with fields:
	--   handSize (if not 1) (this isn't set here, but in the tech; here it's just for the description)
	--   energyKW
	--   drainKW (if nil, it's assumed to be 0)
	--   descriptionKey (or nil to use shared) - locale key for description string
	{name="burner-inserter", energyKW=25, descriptionKey="burner"}, -- Reduced 35kW -> 25kW
	{name="steam-inserter", energyKW=25, descriptionKey="steam"}, -- Reduced 35kW -> 25kW
	{name="long-handed-steam-inserter", energyKW=35}, -- Changed 52.5kW -> 35kW
	{name="inserter", energyKW=20, drainKW=1}, -- Changed 17.9kW -> 20kW; increasing drain 0.4 -> 1kW, so 5% of operating.
	{name="slow-filter-inserter", energyKW=20, drainKW=1}, -- Changed 17.9kW -> 20kW; increasing drain 0.4 -> 1kW, so 5% of operating.
	{name="long-handed-inserter", energyKW=35, drainKW=1.75}, -- Changed 17.9kW -> 35kW; increasing drain 0.4 -> 1.75kW, so 5% of operating.
	{name="fast-inserter", energyKW=30, drainKW=1.5}, -- Changed 49.5kW -> 30kW, increased drain 0.5 -> 1.5kW, so 5% of operating.
	{name="filter-inserter", energyKW=30, drainKW=1.5}, -- This is the "fast filter inserter". Changed 56.5kW -> 30kW, increasing drain 0.5 -> 1.5kW, so 5% of operating.
	{name="stack-inserter", handSize=6, energyKW=120, drainKW=12}, -- Changed 141kW -> 120kW, increasing drain 1 -> 12kW, so 10% of operating.
	{name="stack-filter-inserter", handSize=6, energyKW=120, drainKW=12}, -- Changed 141kW -> 120kW, increasing drain 1 -> 12kW, so 10% of operating.
}

--[[ Original IR3 inserter stats for comparison:
local inserterStats = {
	{name="burner-inserter", energyKW=35, descriptionKey="burner"},
	{name="steam-inserter", energyKW=35, descriptionKey="steam"},
	{name="long-handed-steam-inserter", energyKW=52.5},
	{name="inserter", energyKW=17.9, drainKW=0.4},
	{name="slow-filter-inserter", energyKW=17.9, drainKW=0.4},
	{name="long-handed-inserter", energyKW=17.9, drainKW=0.4},
	{name="fast-inserter", energyKW=49.5, drainKW=0.5},
	{name="filter-inserter", energyKW=56.5, drainKW=0.5},
	{name="stack-inserter", handSize=6, energyKW=141, drainKW=1},
	{name="stack-filter-inserter", handSize=6, energyKW=141, drainKW=1},
}
]]

for _, inserterParams in pairs(inserterStats) do
	local inserterEnt = data.raw.inserter[inserterParams.name]

	-- Set new drain value
	if inserterParams.drainKW ~= nil then
		inserterEnt.energy_source.drain = inserterParams.drainKW .. "KW"
	end

	-- Compute items per second and energy per item
	local rotationsPerSecond = inserterEnt.rotation_speed * 60
	local itemsPerSecond = rotationsPerSecond * (inserterParams.handSize or 1)
	local kJPerItem = inserterParams.energyKW / itemsPerSecond

	-- Set new energy value.
	-- I don't know why these magic number formulae work. I found them through guesswork plus trial and error.
	-- There is no real documentation for energy_per_movement/rotation fields.
	local magicNumber1 = inserterParams.energyKW - (inserterParams.drainKW or 0)
	local magicNumber2 = 2 * magicNumber1 / (rotationsPerSecond * 7)
	inserterEnt.energy_per_movement = magicNumber2 .. "KJ"
	inserterEnt.energy_per_rotation = magicNumber2 .. "KJ"

	local descriptionKey = inserterParams.descriptionKey or "SHARED"
	inserterEnt.localised_description = {
		"shared-description.inserter-"..descriptionKey,
		itemsPerSecond,
		kJPerItem,
		(inserterParams.handSize or 1),
	}

	-- Give the stack inserters an inherent stack size bonus, without needing the effect on the research.
	if inserterParams.handSize ~= nil then
		inserterEnt.stack_size_bonus = inserterParams.handSize - 1
	end
end

-- Remove the stack size bonus from the stack inserter tech, since I'm making it inherent instead.
local newEffects = {}
for _, effect in pairs(data.raw.technology["ir-inserters-3"].effects) do
	if effect.type ~= "stack-inserter-capacity-bonus" then
		table.insert(newEffects, effect)
	end
end
data.raw.technology["ir-inserters-3"].effects = newEffects

-- TODO adjust recipes for inserters.
-- TODO eg I think filter inserters should be cheap.