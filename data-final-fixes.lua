-- TODO maybe change pairs() to ipairs() in some places
-- TODO add settings for everything below

local globalParams = require("code.global-params")

require("code.data.terrain.elevation")
require("code.data.terrain.temperature-aux-moisture")
require("code.data.terrain.autoplace-controls")
require("code.data.terrain.remove-existing-mapgen-presets")
require("code.data.terrain.create-mapgen-preset")
require("code.data.terrain.remove-rubber-trees")
require("code.data.terrain.resource-placing")
require("code.data.terrain.tile-autoplace")

require("code.data.additions.start-island-scan")

require("code.data.tweaks.fish")
require("code.data.tweaks.alien-biomes")
require("code.data.tweaks.trees")
require("code.data.tweaks.wood")
require("code.data.additions.powered-pumps")

require("code.data.tweaks.IR3.scatterbots")
require("code.data.tweaks.IR3.starting-junkheaps")
require("code.data.tweaks.IR3.misc")
require("code.data.tweaks.IR3.metal-casting")
require("code.data.tweaks.IR3.furnaces")
require("code.data.tweaks.IR3.geothermal")
require("code.data.tweaks.IR3.miners")

require("code.data.additions.transfer-plate-unlocks-tech")

require("code.data.tweaks.adjust-scrap") -- Must be in data-final-fixes.lua, so it runs after the production scrap mod.

require("code.data.tweaks.circuit-network")

require("code.data.additions.no-building-on-snow")
require("code.data.additions.landfill-only-on-shallow-water")

require("code.data.tweaks.vehicles.trains")
require("code.data.tweaks.vehicles.ships")
require("code.data.tweaks.vehicles.airships")
require("code.data.tweaks.vehicles.unminable-vehicles")
require("code.data.tweaks.vehicles.inventory-sizes")
require("code.data.tweaks.vehicles.movement-params")
require("code.data.tweaks.vehicles.health-and-resistance")
require("code.data.tweaks.vehicles.fuel-slots")

require("code.data.additions.tech")

require("code.data.tweaks.searchlight-assault")

require("code.data.tweaks.IR3.order-tweaks")

require("code.data.tweaks.intermodal-containers.packability-data-final-fixes")

require("code.data.tweaks.recipe-times")

require("code.data.tweaks.vehicles.long-range-delivery-drones")
require("code.data.tweaks.beacon-rebalance")

require("code.data.tweaks.electric-poles").inDataFinalFixes()

require("code.data.tweaks.stack-sizes").inDataFinalFixes()

-- TODO move some of these to the data-updates stage instead, so that they can generate scrap etc.

-- Temporary: printing out tile prototype info
--for _, tile in pairs(data.raw.tile) do
--	if tile.autoplace ~= nil then
--		log("Tile with autoplace: " .. (tile.name or ""))
--	else
--		log("Tile with nil autoplace: " .. (tile.name or ""))
--	end
--end
--for _, tile in pairs(data.raw.tile) do
--	if tile.autoplace ~= nil then
--		log("Tile autoplace:" .. (serpent.block(tile.autoplace)))
--	end
--end

--for _, control in pairs(data.raw["autoplace-control"]) do
--	log("Autoplace control: " .. (control.name or ""))
--end

-- Should be the very last thing run in the data stage:
local autoDebug = require("code.data.additions.auto-debug")
if globalParams.runAutoDebug then
	autoDebug.runFullDebug()
end