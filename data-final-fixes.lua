-- TODO maybe change pairs() to ipairs() in some places

require("data.tweaks.vehicles")


-- Tweak stack sizes for ores etc.
if settings.startup["Desolation-modify-stack-sizes"] then
	local tweakStackSizeItems = require("stack-sizes")
	for item, _ in pairs(tweakStackSizeItems) do
		local val = settings.startup["Desolation-stack-size-" .. item].value
		data.raw.item[item].stack_size = val
		data.raw.item[item].default_request_amount = val
	end
end

-- TODO add settings for everything below

-- Scattergun turrets now require a large copper frame. Original cost is 19 copper + 16 tin ingots; this makes the cost about 3 times greater
data.raw.recipe["scattergun-turret"].ingredients = {
	{"copper-motor", 2}, -- unchanged
	{"copper-plate", 4}, -- 12->4
	-- tin-plate 12->0
	{"tin-gear-wheel", 4}, -- unchanged
	{"copper-frame-large", 1}, -- added 0->1
}

-- Autogun turrets require a large iron frame, and have electronics 1 as prerequisite for the tech (to unlock large iron frame).
table.insert(data.raw.technology["gun-turret"].prerequisites, "ir-electronics-1")
data.raw.recipe["gun-turret"].ingredients = {
	{"iron-motor", 2}, -- unchanged
	{"iron-plate-heavy", 4}, -- reinforced iron plate, 10->4
	-- iron-beam 8->0
	{"iron-gear-wheel", 16}, -- unchanged
	{"iron-frame-large", 1}, -- added 0->1
}

-- Add tech requirements to get rid of "dead ends" in the tech tree, and ensure mod compat (eg cargo ships whose recipe requires steel should have steel as prereq).
function addTechDependency(firstTech, secondTech)
	table.insert(data.raw.technology[secondTech].prerequisites, firstTech)
end
function tryAddTechDependency(firstTech, secondTech)
	if data.raw.technology[secondTech] ~= nil and data.raw.technology[firstTech] ~= nil then
		addTechDependency(firstTech, secondTech)
	end
end
addTechDependency("ir-scatterbot", "military")
addTechDependency("ir-heavy-roller", "ir-heavy-picket")
addTechDependency("ir-heavy-picket", "spidertron")
addTechDependency("land-mine", "military-3")
addTechDependency("ir-bronze-telescope", "gun-turret")
addTechDependency("ir3-beltbox-steam", "ir3-beltbox")
addTechDependency("ir3-beltbox-steam", "logistics-2")
addTechDependency("ir-steambot", "personal-roboport-equipment")
addTechDependency("heavy-armor", "modular-armor")
addTechDependency("ir-petro-generator", "ir-petroleum-processing")
addTechDependency("ir-normal-inserter-capacity-bonus-2", "logistics-3")
addTechDependency("plastics-2", "logistics-3")
addTechDependency("logistics-3", "automation-4")
addTechDependency("effect-transmission", "ir-transmat")
addTechDependency("ir-geothermal-exchange", "ir-mining-2")
addTechDependency("gun-turret", "military-2")
addTechDependency("ir-bronze-forestry", "ir-iron-forestry")
addTechDependency("ir-iron-forestry", "ir-chrome-forestry")
addTechDependency("ir-barrelling", "ir-high-pressure-canisters")
tryAddTechDependency("ir-barrelling", "oversea-energy-distribution")
tryAddTechDependency("ir-steel-milestone", "automated-water-transport")
-- TODO more of these?

-- Make scatterbots a bit better, by making them slower, so that you can throw them at enemy bases and run away, and they won't follow so fast. Could make them non-following, but that makes them not subject to the follower cap, which makes them too powerful.
--data.raw["combat-robot"]["scatterbot"].follows_player -- not changing this.
data.raw["combat-robot"]["scatterbot"].speed = 0.0008 -- 0.0025 -> 0.0008.

-- Considered: Make all small and large frames cost twice as much, to make infrastructure more expensive. Decided against because current costs already seem pretty expensive.

-- Reduce copper boiler effectiveness, so you need more of them and you're more eager to upgrade to iron boilers.
data.raw.boiler["copper-boiler"].energy_consumption = "300000W" -- changed 15000 -> 5000, or 900kW -> 300kW

-- Reduce copper pump effectiveness, so you're more eager to upgrade to iron ones.
data.raw["offshore-pump"]["copper-pump"].pumping_speed = 3.0 -- 8.0 -> 3.0, so water is 480/sec -> 180/sec, can provide water to 16 -> 6 copper boilers (excluding change to copper boilers above).

-- Change ammo mag sizes so shotgun ammo doesn't last so long.
data.raw.ammo["shotgun-shell"].magazine_size = 5 -- 10->5; this is the normal copper cartridge.
data.raw.ammo["bronze-cartridge"].magazine_size = 5 -- 10->5
data.raw.ammo["iron-cartridge"].magazine_size = 5 -- 10->5
data.raw.ammo["piercing-shotgun-shell"].magazine_size = 5 -- 10->5; this is the steel cartridge.

-- Make rubber tree beds require ordinary wood, not rubber wood, in case there's no rubber trees with your map settings.
data.raw.recipe["tree-planter-ir-rubber-tree"].ingredients = {{"wood", 12}, {"stone-brick", 8}}

-- Increase cost of cliff explosives, landfill, waterfill.
-- TODO settings
function multiplyRecipeCosts(name, factor)
	local recipe = data.raw.recipe[name]
	for i = 1, #recipe.ingredients do
		if recipe.ingredients[i][2] ~= nil then
			recipe.ingredients[i][2] = recipe.ingredients[i][2] * factor
		else
			recipe.ingredients[i].amount = recipe.ingredients[i].amount * factor
		end
	end
end
multiplyRecipeCosts("landfill", 5)
multiplyRecipeCosts("cliff-explosives", 5)
-- TODO check - base mod has landfill from 15x gravel and 15x silica.

-- Modify stack size and contents of barrels and canisters?
-- Copper canisters hold 100 steam and have stack size 50, so 5000/stack, or 400k/cargowagon.
-- Iron canisters hold 30 fluid and have stack size 50, so 1500/stack, or 120k/cargowagon. Researched soon after iron+electricity. Made from iron. Holds only petroleum and steam.
-- Barrels contain 60 fluid and have stack size 10, so 600/stack, or 48k/cargowagon. Researched right after steel. Made from steel. Holds petroleum and most liquids.
-- High-pressure canisters hold 80 fluid and have stack size 10, so 800/stack, or 64k/cargowagon. Research comes later than barrels. Made from steel and nanoglass. Holds gases. No need to change this since nothing else transports all those gases, except fluid wagons.
-- Fluid wagon holds 25k fluid. Cargo wagon holds 80 stacks.
-- So with the default settings:
-- * Transporting steam is best in copper canisters, but you could also use fluid wagons for simplicity, or barrels (since sending empty steam canisters back is a logistical problem), or even iron canisters (if you've got them moving around anyway for petroleum).
-- * Transporting petroleum is best in iron canisters, but you could also use fluid wagons for simplicity, or barrels (since sending empty iron canisters back is a logistical problem).
-- * Transporting most liquids is best in barrels (for double throughput) or fluid wagons (for simplicity).
-- * Transporting gases is best in high-pressure canisters (for 2.5x throughput) or fluid wagons (for simplicity).
-- In summary, I don't think anything here needs changing.


-- Perhaps we should make geothermal energy available much earlier?
-- TODO

-- Should we buff geothermal energy? Because I like the design challenges of trying to build outposts close to geothermal vents.
-- Note polluted steam vents seem to produce between 120/sec polluted steam and zero. When they deplete, they get re-set to 100% -- see replenish_fissure function in control.lua.
-- For one steam vent producing on average 60/sec polluted steam, that supplies ~1 geothermal exchanger, which supplies ~2 electric engines, producing ~2MW, so ~4 electric mining drills. Assuming we filter or vent all of the polluted water.
-- Note polluted steam vents sometimes come in clumps of like 3, which would be 6MW, so 12 electric mining drills.
-- All of this is just not enough power to be relevant.
-- TODO buff them.



-- TODOS:
-- Change extra electric pole types - why do they exist??
-- Maybe change geothermal to be more viable?
-- Disable handcrafting - see https://mods.factorio.com/mod/No_Handcrafting
-- Tweaks mod should halve resource frequency, if possible. Or, maybe search for map settings mod.
-- fix resistances etc https://github.com/Deadlock989/IndustrialRevolution/issues/413
-- make scatter bots require charged steam cells, and get rid of one of the plates requirements.
-- maybe make bronze furnaces better relative to stone furnaces, eg by making stone furnaces slower.
-- undo IR3's increase in cargo wagon inventory space.
-- get rid of fish healing, or at least vastly reduce it.
-- Reduce the output of the electric drill, so that steam is still higher when you're constrained by the size of the resource patch. So it still makes sense to use steam-powered drills sometimes, even into the late game.
-- Change the amounts needed for IR3's inspirations. Currently it's 12, which is tiny.