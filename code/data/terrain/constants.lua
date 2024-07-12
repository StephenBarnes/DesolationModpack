local Export = {}

Export.artifactShift = 20000 -- Added to a coordinate, to get rid of fractal symmetry.

Export.startIslandMinRad = 300 -- Distance from center of starting island to the closest ocean
Export.startIslandMaxRad = 600 -- Distance from center of starting island to the furthest end of the starting island
Export.startIslandAndOffshootsMaxRad = 900 -- Distance from center of starting island to the furthest end of the furthest "offshoot", currently just the iron.
Export.coldStartRegionRad = Export.startIslandAndOffshootsMaxRad -- How big of a "cold patch" to put around the center of the starting island.
Export.puddleMargin = 70 -- Distance before minRad where puddles start to appear.
Export.spawnToStartIslandCenter = 200 -- Distance from center of starting island to spawn point.

-- These angles are radians. 0 means east, pi means west, 0.5 * pi means south.
local pi = 3.1416
Export.startIslandAngleToCenterMin = 0.25 * pi
Export.startIslandAngleToCenterMax = 0.75 * pi
Export.startIslandIronMaxDeviationAngle = 0.25 * pi -- On starting island, iron ore spawns on the other side of the island center, with this big of an angle in either direction.

Export.distCenterToIron = 800 -- Distance from center of starting island to the center of the first iron ore patch.
Export.distCenterToIronArcStart = Export.startIslandMinRad -- Distance from center of starting island to the start of the arc leading to the first iron ore patch.
Export.distCenterToIronArcCenter = (Export.distCenterToIron + Export.distCenterToIronArcStart) / 2 -- Distance from center of starting island to the center of the arc leading to the first iron ore patch.
Export.ironArcRad = Export.distCenterToIron - Export.distCenterToIronArcCenter -- Radius of the circular arc around the center.
Export.ironArcWidth = 40 -- Approximate width of terrain along the circular arc leading to the first iron ore patch.
Export.ironBlobMinRad = 50 -- Approximate width of terrain around the iron ore patch.
Export.ironBlobMaxRad = 100
-- TODO for iron, add the circular arc and blob, so iron falls on land

return Export