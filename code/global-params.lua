local G = require("code.util.general")

local isDebug = false -- Whether currently debugging; this changes multiple settings below. TODO set to false when releasing.

return {
	runIntroCutscene = not isDebug, -- Whether to run the IR3 intro cutscene.

	forceSettings = true, -- Whether to force-set and hide settings for other mods. If false, Desolation will only set the default values of those settings.
		-- I wanted to add a checkbox setting for whether Desolation should do this. But I don't think that's possible, bc the settings' values are only available in the data stage, but we need to adjust the other mods' settings in the settings stage.

	printEveryIslandScanChunk = false, -- Whether to print a message for every chunk scanned by the starting island scan or seismic scanners.
	enableStartIslandScan = not isDebug, -- Whether to enable the starting island scan.
	scanStartIslandMaxDist = 500, -- How many chunks away from (0,0) we'll scan chunks in the starting island scan. This is to avoid scanning forever, eg if the player has chosen terrain settings that connect all islands, or remove the sea, etc.
	seismicScanMaxDist = 500, -- How many chunks away from a seismic scanner it will scan chunks. This is to avoid scanning forever, eg if the player has chosen terrain settings that connect all islands, or remove the sea, etc.
	oceanScanMaxDist = 150, -- How many chunks away from an ocean scanner it will scan chunks. This is to avoid scanning forever, since the ocean is generally connected.
	scanEveryNTicks = G.ifThenElse(isDebug, 30, 60), -- How often to update the scan of the starting island, or ocean scanners, in ticks.
	scanStartIslandChunksPerUpdate = 2, -- How many chunks to scan per update, for starting island scan.
	scanOceanChunksPerUpdate = 4, -- How many chunks to scan per update, for ocean scanners.
	-- For these settings, we want scanEveryNTicks to be large, since that's also how often we check, even if the scan isn't ongoing.
	-- So we check less frequently, and batch multiple chunks together, using the scanStartIslandChunksPerUpdate setting.
	-- I've found that 60 and 2 are reasonable numbers - no noticeable lag on my machine, and scans are fast enough.
	-- This changes depending on how complex the terrain autoplace rules are.
	-- TODO add settings for this, in case people have slower machines.

	enableMarkerLakes = false, -- Whether to place small lakes at points of interest for mapgen. For debugging.

	unifySnowIceTileNames = true, -- Whether to unify the names of snow/ice tiles, so they all say "can't build on snow" instead of "Snow 0" etc.

	colorBuildableTiles = false, -- Whether to color the buildable tiles in bright colors, for debugging.

	runAutoDebug = isDebug, -- Whether to enable debug code in auto-debug.lua.

	notifyIncorrectMapgenPreset = not isDebug, -- Whether to notify the player when they try to play a scenario with the wrong mapgen preset.

	waterCoverage = 1,
	inverseWaterScale = 1/3,

	victoryOnFinalTech = true, -- Whether to enable victory on the final tech.
	victoryMinTicks = 60 * 60, -- Final tech won't give victory if researched within this many ticks; this is for sandbox games.
}