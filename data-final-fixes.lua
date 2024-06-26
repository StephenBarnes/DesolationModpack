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
require("stages.data.tweaks.scatterbots")
require("stages.data.tweaks.misc-IR3")
require("stages.data.tweaks.fluid-containers")
require("stages.data.tweaks.electric-poles")



-- TODOS:
-- Disable handcrafting - see https://mods.factorio.com/mod/No_Handcrafting
-- fix resistances etc https://github.com/Deadlock989/IndustrialRevolution/issues/413
-- maybe make bronze furnaces better relative to stone furnaces, eg by making stone furnaces slower.
-- get rid of fish healing, or at least vastly reduce it.
-- Reduce the output of the electric drill, so that steam is still higher when you're constrained by the size of the resource patch. So it still makes sense to use steam-powered drills sometimes, even into the late game.
-- Change the map preset to also set pollution absorption modifier to the minimum (10%).
-- Maybe: make a mod to completely remove terrain pollution absorption. Currently Alien Biomes specifies the absorption of all tiles, so check how it does that, maybe modify those prototypes.
-- TODO add FunkedOre dependency
-- TODO consider using FunkedOre to halve resource frequency?
-- TODO add PowerOverload dependency
-- TODO add multiplier to handcrafting speed
-- TODO change mapgen settings to multiply tech costs by like 30? Or do it in code, because I want to modify inspirations too, but not eg the inspiration that requires 12 wood.
-- TODO prevent iron from spawning close to spawn. Because I just played a game where there was some iron very nearby.
-- TODO maybe modify FunkedOre so that you can specify separate rules for close-to-spawn and far-from-spawn. So we can delete all iron near spawn.