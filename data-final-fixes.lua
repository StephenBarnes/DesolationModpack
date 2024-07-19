-- TODO maybe change pairs() to ipairs() in some places
-- TODO add settings for everything below

require("code.data.terrain.elevation")
require("code.data.terrain.temperature-aux-moisture")
require("code.data.terrain.autoplace-controls")
require("code.data.terrain.remove-existing-mapgen-presets")
require("code.data.terrain.create-mapgen-preset")
require("code.data.terrain.remove-rubber-trees")
require("code.data.terrain.resource-placing")
require("code.data.terrain.tile-autoplace")

require("code.data.additions.start-island-scan")

require("code.data.tweaks.stack-sizes")
require("code.data.tweaks.tech")
require("code.data.tweaks.tile-recipes")
require("code.data.tweaks.fluid-containers")
require("code.data.tweaks.electric-poles")
require("code.data.tweaks.fish")
require("code.data.tweaks.alien-biomes")
require("code.data.tweaks.trees")
require("code.data.tweaks.wood")
require("code.data.additions.powered-pumps")

require("code.data.tweaks.IR3.scatterbots")
require("code.data.tweaks.IR3.starting-junkheaps")
require("code.data.tweaks.IR3.misc")
require("code.data.tweaks.IR3.geothermal")

require("code.data.additions.transfer-plate-unlocks-tech")

require("code.data.tweaks.adjust-scrap") -- Must be in data-final-fixes.lua, so it runs after the production scrap mod.

-- TODO move some of these to the data-updates stage instead, so that they can generate scrap etc.

-- Temporary: printing out tile prototype info
for _, tile in pairs(data.raw.tile) do
	if tile.autoplace ~= nil then
		log("Tile with autoplace: " .. (tile.name or ""))
	else
		log("Tile with nil autoplace: " .. (tile.name or ""))
	end
end
--for _, tile in pairs(data.raw.tile) do
--	if tile.autoplace ~= nil then
--		log("Tile autoplace:" .. (serpent.block(tile.autoplace)))
--	end
--end

for _, control in pairs(data.raw["autoplace-control"]) do
	log("Autoplace control: " .. (control.name or ""))
end