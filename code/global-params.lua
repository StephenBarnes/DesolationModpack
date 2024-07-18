local isDebug = true -- Whether I'm testing the modpack. TODO set to false when release.

return {
	runIntroCutscene = not isDebug, -- Whether to run the IR3 intro cutscene.

	printStartIslandScanEveryChunk = false, -- Whether to print a message for every chunk scanned.
	scanStartIslandEveryNTicks = 60, -- How often to update the scan of the starting island, in ticks.
	scanStartIslandChunksPerUpdate = 20, -- How many chunks to scan per update.
	-- For these two settings, we want scanStartIslandEveryNTicks to be large, since that's also how often we check, even if the scan isn't ongoing.
	-- So we check less frequently, and batch multiple chunks together, using the scanStartIslandChunksPerUpdate setting.
	-- I've found that 60 and 20 are reasonable numbers - no noticeable lag on my machine, and scans are fast enough.
}