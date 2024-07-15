-- TODO maybe change pairs() to ipairs() in some places
-- TODO add settings for everything below

require("code.data.terrain.elevation")
require("code.data.terrain.autoplace-controls")
require("code.data.terrain.remove-existing-mapgen-presets")
require("code.data.terrain.create-mapgen-preset")
require("code.data.terrain.rubber-trees-edit")
require("code.data.terrain.cold-starting-region")
require("code.data.terrain.resource-placing")

require("code.data.tweaks.stack-sizes")
require("code.data.tweaks.tech")
require("code.data.tweaks.tile-recipes")
require("code.data.tweaks.fluid-containers")
require("code.data.tweaks.electric-poles")
require("code.data.tweaks.fish")
require("code.data.tweaks.alien-biomes")
require("code.data.tweaks.trees")
require("code.data.tweaks.wood")

require("code.data.tweaks.IR3.scatterbots")
require("code.data.tweaks.IR3.starting-junkheaps")
require("code.data.tweaks.IR3.misc")
require("code.data.tweaks.IR3.geothermal")

require("code.data.tweaks.adjust-scrap") -- Must be in data-final-fixes.lua, so it runs after the production scrap mod.

-- TODO move some of these to the data-updates stage instead, so that they can generate scrap etc.