-- This file implements code shared between start-island-scan.lua and seismic-scanning.lua.

local globalParams = require("code.global-params")

local X = {} -- Exported values.

local function getChunkArea(chunkPos)
	-- Given sth like {3, 5}, returns the bounding box {{3*32, 5*32}, {3*32 + 31, 5*32 + 31}}.
	local x1 = chunkPos[1] * 32
	local y1 = chunkPos[2] * 32
	local x2 = x1 + 31
	local y2 = y1 + 31
	return {{x1, y1}, {x2, y2}}
end

local function isChunkPermitted(chunkArea, minLandTiles, maxLandTiles)
	local landTileCount = game.surfaces[1].count_tiles_filtered{area = chunkArea, collision_mask = "ground-tile"}
	if minLandTiles ~= nil and landTileCount < minLandTiles then return false end
	if maxLandTiles ~= nil and landTileCount > maxLandTiles then return false end
	return true
end

function X.chunkToStr(chunkPos)
	return chunkPos[1] .. "," .. chunkPos[2]
end

function X.ticksToStr(ticks)
	local seconds = math.floor(ticks / 60)
	local minutes = math.floor(seconds / 60)
	return minutes .. "m " .. math.floor(seconds - minutes * 60) .. "s"
end

function X.updateScanOnce(force, scanInfo, maxDist, minLandTiles, maxLandTiles)
	-- Takes a force and a scanInfo with fields: frontierChunks, alreadyAddedChunks, firstTick, lastTick, hasFinished, startChunk.
	-- Also takes maxDist, which is maximum taxicab distance of chunks from origin to consider scanning. Cannot be nil.
	-- Returns nothing.
	-- Modifies scanInfo.frontierChunks, scanInfo.alreadyAddedChunks, scanInfo.hasFinished, lastTick.
	-- Caller is responsible for reporting progress to the player.
	-- This is used both by the start island scan, and by the seismic scanners.
	if not force.valid then return end
	if scanInfo.hasFinished then return end
	if #scanInfo.frontierChunks == 0 then
		scanInfo.hasFinished = true
		scanInfo.lastTick = game.tick
		scanInfo.alreadyAddedChunks = nil -- Just to free the memory.
		return
	end
	-- Scan one chunk in the frontier.
	local chunkToScan = table.remove(scanInfo.frontierChunks, 1)
	if chunkToScan[3] > maxDist then
		-- Refuse to scan chunks that are too far away. This generally happens for ocean scanner pods, but can also happen for seismic scanners or the starting island scan, if the player has chosen terrain settings that connect all islands, or remove the sea, etc.
		return
	end

	local chunkArea = getChunkArea(chunkToScan)
	force.chart(game.surfaces[1], chunkArea)
	if globalParams.printEveryIslandScanChunk then
		force.print("Scanning " .. X.chunkToStr(chunkToScan))
	end

	-- Update the frontier, if this scanned chunk had a non-water tile at its center.
	local function maybeAddChunk(chunkToAdd)
		local chunkStr = X.chunkToStr(chunkToAdd)
		if not scanInfo.alreadyAddedChunks[chunkStr] then
			table.insert(scanInfo.frontierChunks, chunkToAdd)
			scanInfo.alreadyAddedChunks[chunkStr] = true
		end
	end
	if isChunkPermitted(chunkArea, minLandTiles, maxLandTiles) then
		for _, adjacentChunk in pairs({
			{chunkToScan[1] - 1, chunkToScan[2], chunkToScan[3]+1},
			{chunkToScan[1], chunkToScan[2] - 1, chunkToScan[3]+1},
			{chunkToScan[1], chunkToScan[2] + 1, chunkToScan[3]+1},
			{chunkToScan[1] + 1, chunkToScan[2], chunkToScan[3]+1},
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
				{chunkToScan[1] - 1, chunkToScan[2] - 1, chunkToScan[3]+1.41},
				{chunkToScan[1] + 1, chunkToScan[2] - 1, chunkToScan[3]+1.41},
				{chunkToScan[1] - 1, chunkToScan[2] + 1, chunkToScan[3]+1.41},
				{chunkToScan[1] + 1, chunkToScan[2] + 1, chunkToScan[3]+1.41},
			}) do
				maybeAddChunk(adjacentChunk)
			end
		end
	end
end

return X