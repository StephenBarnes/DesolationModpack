-- TODO maybe change pairs() to ipairs() in some places
-- TODO add settings for everything below

require("stages.data.tweaks.vehicles")
require("stages.data.tweaks.terrain-preset")
require("stages.data.tweaks.stack-sizes")
require("stages.data.tweaks.tech")
require("stages.data.tweaks.turret-recipes")
require("stages.data.tweaks.ammo")
require("stages.data.tweaks.geothermal")
require("stages.data.tweaks.tile-recipes")




-- Make scatterbots a bit better, by making them slower, so that you can throw them at enemy bases and run away, and they won't follow so fast. Could make them non-following, but that makes them not subject to the follower cap, which makes them too powerful.
--data.raw["combat-robot"]["scatterbot"].follows_player -- not changing this.
data.raw["combat-robot"]["scatterbot"].speed = 0.0008 -- 0.0025 -> 0.0008.

-- Considered: Make all small and large frames cost twice as much, to make infrastructure more expensive. Decided against because current costs already seem pretty expensive.

-- Reduce copper boiler effectiveness, so you need more of them and you're more eager to upgrade to iron boilers.
data.raw.boiler["copper-boiler"].energy_consumption = "300000W" -- changed 15000 -> 5000, or 900kW -> 300kW

-- Reduce copper pump effectiveness, so you're more eager to upgrade to iron ones.
data.raw["offshore-pump"]["copper-pump"].pumping_speed = 3.0 -- 8.0 -> 3.0, so water is 480/sec -> 180/sec, can provide water to 16 -> 6 copper boilers (excluding change to copper boilers above).


-- Make rubber tree beds require ordinary wood, not rubber wood, in case there's no rubber trees with your map settings.
data.raw.recipe["tree-planter-ir-rubber-tree"].ingredients = {{"wood", 12}, {"stone-brick", 8}}

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



-- TODOS:
-- Change extra electric pole types - why do they exist??
-- Disable handcrafting - see https://mods.factorio.com/mod/No_Handcrafting
-- Tweaks mod should halve resource frequency, if possible. Or, maybe search for map settings mod.
-- fix resistances etc https://github.com/Deadlock989/IndustrialRevolution/issues/413
-- make scatter bots require charged steam cells, and get rid of one of the plates requirements.
-- maybe make bronze furnaces better relative to stone furnaces, eg by making stone furnaces slower.
-- undo IR3's increase in cargo wagon inventory space.
-- get rid of fish healing, or at least vastly reduce it.
-- Reduce the output of the electric drill, so that steam is still higher when you're constrained by the size of the resource patch. So it still makes sense to use steam-powered drills sometimes, even into the late game.
-- Change the amounts needed for IR3's inspirations. Currently it's 12, which is tiny.
-- Change the map preset to also set pollution absorption modifier to the minimum (10%).
-- Maybe: make a mod to completely remove terrain pollution absorption. Currently Alien Biomes specifies the absorption of all tiles, so check how it does that, maybe modify those prototypes.
-- TODO add FunkedOre dependency