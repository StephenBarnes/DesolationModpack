-- This script is to conduct a full scan of the starting island, once Optics is researched.

local globalParams = require("code.global-params")

local function onResearchFinished(event)
	if event.research.name == "ir-bronze-telescope" then
		local force = event.research.force
		if force == nil then
			log("Optics was researched, but the force is nil. This shouldn't happen.")
			return
		end
		force.print({"Desolation-message.scan-start-island-begin", {"technology-name.ir-bronze-telescope"}})
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
	if not force.valid then return end
	if #scanInfo.frontierChunks == 0 then
		scanInfo.hasFinished = true
		force.print({"Desolation-message.scan-start-island-end", ticksToStr(game.tick - scanInfo.firstTick)})
		scanInfo.alreadyAddedChunks = nil -- Just to free the memory.
		return
	end
	-- Scan one chunk in the frontier.
	local chunkToScan = table.remove(scanInfo.frontierChunks, 1)
	if (math.abs(chunkToScan[1]) + math.abs(chunkToScan[2])) > globalParams.scanStartIslandMaxTaxicabDistance then
		-- Refuse to scan chunks that are too far away. This can happen if the player has chosen terrain settings that connect all islands, or remove the sea, etc.
		log("ERROR: Refusing to scan chunk " .. chunkToStr(chunkToScan) .. " because it's very far away. Probably due to terrain settings that connect all islands, or remove the sea, etc.")
		return
	end

	local chunkArea = getChunkArea(chunkToScan)
	force.chart(game.surfaces[1], chunkArea)
	if globalParams.printStartIslandScanEveryChunk then
		force.print("Scanning " .. chunkToStr(chunkToScan))
	end

	-- Update the frontier, if this scanned chunk had a non-water tile at its center.
	local function maybeAddChunk(chunkToAdd)
		local chunkStr = chunkToStr(chunkToAdd)
		if not scanInfo.alreadyAddedChunks[chunkStr] then
			table.insert(scanInfo.frontierChunks, chunkToAdd)
			scanInfo.alreadyAddedChunks[chunkStr] = true
		end
	end
	if isChunkLand(chunkArea) then
		for _, adjacentChunk in pairs({
			{chunkToScan[1] - 1, chunkToScan[2]},
			{chunkToScan[1], chunkToScan[2] - 1},
			{chunkToScan[1], chunkToScan[2] + 1},
			{chunkToScan[1] + 1, chunkToScan[2]},
		}) do
			maybeAddChunk(adjacentChunk)
		end
		-- Adding only those 4 adjacent chunks causes the scanned region to expand in a "growing diamond" shape, which looks annoyingly artificial to me.
		-- I'd prefer to have the scanned shape look like a circle.
		-- But to scan in a circle, we'd need to sort chunks by distance from the center, which is tricky and might be slow, especially since Lua is a dumb language.
		-- As a substitute for sorting by distance, we instead sometimes also add diagonally adjacent chunks.
		-- Surprisingly, this works very well. Scanned area looks mostly like a circle, at the terrain scale and resolution we're working with.
		--if math.random() < 0.5 then
		-- Actually, instead of a random number, use the parity, so it's more regular and won't get lopsided.
		--if (chunkToScan[1] % 2) == 0 and (chunkToScan[2] % 2) == 1 then -- This produced an interesting rotated octagon pattern.
		-- Well, that looks artificial again, so let's just do it randomly.
		if math.random() < 0.4 then
			for _, adjacentChunk in pairs({
				{chunkToScan[1] - 1, chunkToScan[2] - 1},
				{chunkToScan[1] + 1, chunkToScan[2] - 1},
				{chunkToScan[1] - 1, chunkToScan[2] + 1},
				{chunkToScan[1] + 1, chunkToScan[2] + 1},
			}) do
				maybeAddChunk(adjacentChunk)
			end
		end
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
				updateScanOnce(force, scanInfo)
			end
		end
	end
end

return {
	onResearchFinished = onResearchFinished,
	onNthTick = onNthTick,
}