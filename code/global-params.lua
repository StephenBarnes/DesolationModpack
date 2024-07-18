local isDebug = true -- Whether I'm testing the modpack. TODO set to false when release.

return {
	runIntroCutscene = not isDebug, -- Whether to run the IR3 intro cutscene.

	printStartIslandScanEveryChunk = true, -- Whether to print a message for every chunk scanned.
	scanStartIslandEveryNTicks = 60, -- How often to update the scan of the starting island, in ticks.
	scanStartIslandChunksPerUpdate = 20, -- How many chunks to scan per update.
}