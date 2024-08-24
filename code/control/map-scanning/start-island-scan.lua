-- This script is to conduct a full scan of the starting island, once Optics is researched.

local globalParams = require("code.global-params")
local Common = require("code.control.map-scanning.common-island-scanning")

local function onResearchFinished(event)
	if not globalParams.enableStartIslandScan then return end
	if event.research.name == "ir-bronze-telescope" then
		local force = event.research.force
		if force == nil then
			log("ERROR: Surveying was researched, but the force is nil. This shouldn't happen.")
			return
		end
		force.print({"Desolation-message.scan-start-island-begin", {"technology-name.ir-bronze-telescope"}})
		if global.startIslandScan == nil then
			global.startIslandScan = {}
		end
		global.startIslandScan[force.index] = {
			hasFinished = false,
			firstTick = game.tick,
			frontierChunks = {{0, 0, 0}}, -- Extra 0 for the distance.
			alreadyAddedChunks = {{0, 0}}, -- Chunks that we've already added to the frontier, so shouldn't add them again.
			startChunk = {0, 0},
		}
	end
end

local function onNthTick(event)
	if global.startIslandScan == nil then
		return
	end
	for forceIndex, scanInfo in pairs(global.startIslandScan) do
		local force = game.forces[forceIndex]
		if force and force.valid and scanInfo and not scanInfo.hasFinished then
			for _ = 1, globalParams.scanStartIslandChunksPerUpdate do
				Common.updateScanOnce(force, scanInfo, globalParams.scanStartIslandMaxDist, 30, nil)
				if scanInfo.hasFinished then
					force.print({"Desolation-message.scan-start-island-end", Common.ticksToStr(scanInfo.lastTick - scanInfo.firstTick)})
					return
				end
			end
		end
	end
end

return {
	onResearchFinished = onResearchFinished,
	onNthTick = onNthTick,
}