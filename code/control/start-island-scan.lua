-- This script is to conduct a full scan of the starting island, once Optics is researched.

local globalParams = require("code.global-params")

local function onResearchFinished(event)
	if event.research.name == "ir-bronze-telescope" then
		local force = event.research.force
		if force == nil then
			log("Optics was researched, but the force is nil. This shouldn't happen.")
			return
		end
		force.print("The starting island will be scanned over the next few minutes.") -- TODO localise
		if global.startIslandScan == nil then
			global.startIslandScan = {}
		end
		global.startIslandScan[force.index] = {
			hasBegun = true,
			hasFinished = false,
			firstTick = game.tick,
			frontierChunks = {{0, 0}},
			alreadyAddedChunks = {{0, 0}}, -- Chunks that we've already added to the frontier, so shouldn't add them again.
		}
	end
end

local function getChunkArea(chunkPos)
	-- Given sth like {3, 5}, returns the bounding box {{3*32, 5*32}, {3*32 + 31, 5*32 + 31}}.
	local x1 = chunkPos[1] * 32
	local y1 = chunkPos[2] * 32
	local x2 = x1 + 31
	local y2 = y1 + 31
	return {{x1, y1}, {x2, y2}}
end

local function isChunkLand(chunkArea)
	local groundTileCount = game.surfaces[1].count_tiles_filtered{area = chunkArea, collision_mask = "ground-tile"}
	return groundTileCount > 30
end

local function chunkToStr(chunkPos)
	return chunkPos[1] .. "," .. chunkPos[2]
end

local function ticksToStr(ticks)
	local seconds = math.floor(ticks / 60)
	local minutes = math.floor(seconds / 60)
	return minutes .. "m " .. math.floor(seconds - minutes * 60) .. "s"
end

local function updateScanOnce(force, scanInfo)
	if #scanInfo.frontierChunks == 0 then
		scanInfo.hasFinished = true
		force.print("Starting island scan finished in " .. ticksToStr(game.tick - scanInfo.firstTick) .. ".") -- TODO localise
		return
	end
	--force.chart(game.surfaces[1], {{0, 0}, {0, 0}})
	-- Scan one chunk in the frontier.
	local chunkToScan = table.remove(scanInfo.frontierChunks, 1)
	local chunkArea = getChunkArea(chunkToScan)
	force.chart(game.surfaces[1], chunkArea)
	if globalParams.printStartIslandScanEveryChunk then
		force.print("Scanning " .. chunkToStr(chunkToScan))
	end

	-- Update the frontier, if this scanned chunk had a non-water tile at its center.
	if isChunkLand(chunkArea) then
		for _, adjacentChunk in pairs({
			{chunkToScan[1] + 1, chunkToScan[2]},
			{chunkToScan[1] - 1, chunkToScan[2]},
			{chunkToScan[1], chunkToScan[2] + 1},
			{chunkToScan[1], chunkToScan[2] - 1},
		}) do
			local chunkStr = chunkToStr(adjacentChunk)
			if not scanInfo.alreadyAddedChunks[chunkStr] then
				table.insert(scanInfo.frontierChunks, adjacentChunk)
				scanInfo.alreadyAddedChunks[chunkStr] = true
			end
		end
	end
end

local function onNthTick(event)
	if global.startIslandScan == nil then
		return
	end
	for forceIndex, scanInfo in pairs(global.startIslandScan) do
		if not scanInfo.hasFinished then
			local force = game.forces[forceIndex]
			for _ = 1, globalParams.scanStartIslandChunksPerUpdate do
				updateScanOnce(force, scanInfo)
			end
		end
	end
end


local function register()
	script.on_event(defines.events.on_research_finished, onResearchFinished)
	script.on_nth_tick(globalParams.scanStartIslandEveryNTicks, onNthTick)
end


return {
	register = register,
}