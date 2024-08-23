-- This file implements seismic scanners.
-- Note that the start island scan is implemented separately, in start-island-scan.lua.
-- However, they share significant code, in common-island-scanning.lua.

-- We store a table of all chunks from which seismic scanners have ever scanned, in global.seismicScanners.
-- These are indexed by the force index, then by the string of their chunk. So multiple seismic scanners on one chunk effectively scan together.
-- Each entry in global.seismicScanners[force.index] contains: frontierChunks, alreadyAddedChunks, firstTick, lastTick, hasFinished, startChunk.

local globalParams = require("code.global-params")
local Common = require("code.control.map-scanning.common-island-scanning")

local function onSectorScanned(event)
	local ent = event.radar
	if ent == nil or not ent.valid or event.chunk_position == nil then
		log("ERROR: Seismic scanner was scanned, but the entity is nil or not valid. This shouldn't happen.")
		return
	end

	if ent.name ~= "seismic-scanner" then return end

	-- Figure out what chunk we're scanning from.
	-- Note the seismic radar has max_distance_of_sector_revealed set to 1, but this event will still get called with multiple chunks, eg if the scanner is overlapping chunk boundaries. So instead we have to check the entity's position.
	local chunkList = {math.floor(ent.position.x / 32), math.floor(ent.position.y / 32)}
	local chunkStr = Common.chunkToStr(chunkList)

	-- Get force, check nil
	local force = ent.force
	if force == nil or not force.valid then
		log("ERROR: Seismic scanner was scanned, but the force is nil. This shouldn't happen.")
		return
	end

	-- Check whether we have a running scan for this radar's chunk. If not, create one.
	if global.seismicScanners == nil then global.seismicScanners = {} end
	if global.seismicScanners[force.index] == nil then global.seismicScanners[force.index] = {} end
	if global.seismicScanners[force.index][chunkStr] == nil then
		--force.print(math.random(100, 999) .. "New seismic scanner, chunk str "..(chunkStr or "nil"))
		global.seismicScanners[force.index][chunkStr] = {
			hasFinished = false,
			firstTick = game.tick,
			frontierChunks = {{chunkList[1], chunkList[2], 0}},
			alreadyAddedChunks = {chunkList},
			startChunk = chunkList,
		}
		force.print({"Desolation-message.scan-seismic-start"})
	end

	-- Now we scan one chunk, and update the scan info.
	local scanInfo = global.seismicScanners[force.index][chunkStr]
	if scanInfo.hasFinished then
		ent.active = false
	else
		Common.updateScanOnce(force, scanInfo, globalParams.seismicScanMaxDist, 30, nil)
		if scanInfo.hasFinished then -- If it has now finished, print the message.
			force.print({"Desolation-message.scan-seismic-end", Common.ticksToStr(scanInfo.lastTick - scanInfo.firstTick)})
			ent.active = false
			return
		end
	end
end

return {
	onSectorScanned = onSectorScanned,
}