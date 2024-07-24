-- Control-stage handlers for the ocean scanner pods.

local globalParams = require("code.global-params")
local Common = require("code.control.map-scanning.common-island-scanning")

-- We use a global table to keep track of which ocean scanners are in progress.
-- This is indexed by the force index, then by the string of the chunk.
-- Each entry in global.oceanScanners[force.index] contains: frontierChunks, alreadyAddedChunks, firstTick, lastTick, hasFinished, startChunk.

local function reportIncorrectTile(player)
	player.create_local_flying_text{
		text = {"Desolation-message.scan-ocean-incorrect-tile"},
		create_at_cursor = true,
		time_to_live = 60,
	}
end

local function reportAlreadyScanning(player)
	player.create_local_flying_text{
		text = {"Desolation-message.scan-ocean-already-scanning"},
		create_at_cursor = true,
		time_to_live = 60,
	}
end

local function onCapsuleThrown(event)
	-- Check if it was an ocean scanner capsule.
	if event.item.name ~= "ocean-scanner" then return end

	-- Check if the tile is deep water, else report error.
	local tile = game.surfaces[1].get_tile(event.position.x, event.position.y)
	if tile.name ~= "deepwater" then
		reportIncorrectTile(game.players[event.player_index])
		return
	end

	-- Set up global table context.
	local player = game.players[event.player_index]
	local force = player.force
	if global.oceanScanners == nil then global.oceanScanners = {} end
	if global.oceanScanners[force.index] == nil then global.oceanScanners[force.index] = {} end

	-- Check if an ocean scan is already in progress from this chunk.
	local plopChunkPos = {math.floor(event.position.x/32), math.floor(event.position.y/32)}
	local plopChunkStr = Common.chunkToStr(plopChunkPos)
	if global.oceanScanners[force.index][plopChunkStr] ~= nil then
		reportAlreadyScanning(game.players[event.player_index])
		return
	end

	-- At this point, we know the capsule is being thrown. So we can play the sound and print message.
	game.play_sound{path = "ocean-scanner-plop", position = event.position}
	game.play_sound{path = "ocean-scanner-radar", position = event.position, volume_modifier = 0.6}
	force.print({"Desolation-message.scan-ocean-start"})
	player.create_local_flying_text{
		text = {"Desolation-message.scan-ocean-start"},
		create_at_cursor = true,
		time_to_live = 60,
	}

	-- Remove an item from the stack.
	player.cursor_stack.count = player.cursor_stack.count - 1
	player.clear_cursor()

	-- Initiate the scan.
	global.oceanScanners[force.index][plopChunkStr] = {
		hasFinished = false,
		firstTick = event.tick,
		frontierChunks = {{plopChunkPos[1], plopChunkPos[2], 0}},
		alreadyAddedChunks = {plopChunkPos},
		startChunk = plopChunkPos,
	}
end

local function updateScan(force, scanInfo, chunkStr)
	for _ = 1, globalParams.scanOceanChunksPerUpdate do
		Common.updateScanOnce(force, scanInfo, globalParams.oceanScanMaxDist, nil, 30)
		if scanInfo.hasFinished then
			force.print({"Desolation-message.scan-ocean-end", Common.ticksToStr(scanInfo.lastTick - scanInfo.firstTick)})
			global.oceanScanners[force.index][chunkStr] = nil -- Remove completely; so you could toss a new one in the same chunk.
			return
		end
	end
end

local function onNthTick(event)
	if global.oceanScanners == nil then return end
	for forceIndex, forceScans in pairs(global.oceanScanners) do
		local force = game.forces[forceIndex]
		if force and force.valid then
			for chunkStr, scanInfo in pairs(forceScans) do
				updateScan(force, scanInfo, chunkStr)
			end
		end
	end
end

return {
	onCapsuleThrown = onCapsuleThrown,
	onNthTick = onNthTick,
}