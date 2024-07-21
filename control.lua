local globalParams = require("code.global-params")

local notifyIncorrectMapgenPreset = require("code.control.notify-incorrect-mapgen-preset")
local transferPlateUnlocksTech = require("code.control.transfer-plate-unlocks-tech")
local startIslandScan = require("code.control.island-scanning.start-island-scan")
local ir3StartCalls = require("code.control.ir3-start-calls")
local poweredPumps = require("code.control.powered-pumps")
local noBackerNames = require("code.control.no-backer-names")
local searchlightAssault = require("code.control.searchlight-assault")
local seismicScanning = require("code.control.island-scanning.seismic-scanning")

script.on_init(function()
	ir3StartCalls.onInit()
	transferPlateUnlocksTech.onInit()
end)

script.on_load(function()
	ir3StartCalls.onLoad()
	transferPlateUnlocksTech.onLoad()
end)

script.on_event(defines.events.on_built_entity, function(event)
	noBackerNames.onBuiltEntity(event)
	poweredPumps.onBuiltEntity(event)
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
	noBackerNames.onRobotBuiltEntity(event)
	poweredPumps.onRobotBuiltEntity(event)
end)

script.on_event(defines.events.on_sector_scanned, function(event)
	seismicScanning.onSectorScanned(event)
end)

script.on_event(defines.events.on_game_created_from_scenario, function(event)
	searchlightAssault.onGameCreatedFromScenario(event)
end)

script.on_event(defines.events.on_player_created, function(event)
	notifyIncorrectMapgenPreset.onPlayerCreated(event)
end)

script.on_event(defines.events.on_research_finished, function(event)
	startIslandScan.onResearchFinished(event)
end)

script.on_nth_tick(globalParams.scanStartIslandEveryNTicks, function(event)
	startIslandScan.onNthTick(event)
end)