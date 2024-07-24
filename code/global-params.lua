local isDebug = true -- Whether I'm testing the modpack. TODO set to false when release.

return {
	runIntroCutscene = not isDebug, -- Whether to run the IR3 intro cutscene.

	printEveryIslandScanChunk = false, -- Whether to print a message for every chunk scanned by the starting island scan or seismic scanners.
	scanStartIslandMaxDist = 500, -- How many chunks away from (0,0) we'll scan chunks in the starting island scan. This is to avoid scanning forever, eg if the player has chosen terrain settings that connect all islands, or remove the sea, etc.
	seismicScanMaxDist = 500, -- How many chunks away from a seismic scanner it will scan chunks. This is to avoid scanning forever, eg if the player has chosen terrain settings that connect all islands, or remove the sea, etc.
	oceanScanMaxDist = 100, -- How many chunks away from an ocean scanner it will scan chunks. This is to avoid scanning forever, since the ocean is generally connected.
	scanEveryNTicks = 60, -- How often to update the scan of the starting island, or ocean scanners, in ticks.
	scanStartIslandChunksPerUpdate = 2, -- How many chunks to scan per update, for starting island scan.
	scanOceanChunksPerUpdate = 4, -- How many chunks to scan per update, for ocean scanners.
	-- For these settings, we want scanEveryNTicks to be large, since that's also how often we check, even if the scan isn't ongoing.
	-- So we check less frequently, and batch multiple chunks together, using the scanStartIslandChunksPerUpdate setting.
	-- I've found that 60 and 2 are reasonable numbers - no noticeable lag on my machine, and scans are fast enough.
	-- This changes depending on how complex the terrain autoplace rules are.
	-- TODO add settings for this, in case people have slower machines.

	enableMarkerLakes = false, -- Whether to place small lakes at points of interest for mapgen. For debugging.

	unifySnowTileNames = false, -- Whether to unify the names of snow tiles, so they all say "frigid terrain" instead of "Snow 0" etc.

	colorBuildableTiles = true, -- Whether to color the buildable tiles in bright colors.
}