local Export = {}

Export.artifactShift = 20000 -- Added to a coordinate, to get rid of fractal symmetry.

Export.startIslandMinRad = 400 -- Distance from center of starting island to the closest ocean
Export.startIslandMaxRad = 800 -- Distance from center of starting island to the furthest end of the starting island
Export.coldStartRegionRad = Export.startIslandMaxRad -- How big of a "cold patch" to put around the center of the starting island.
Export.puddleMargin = 100 -- Distance before minRad where puddles start to appear.
Export.spawnToStartIslandCenter = 200 -- Distance from center of starting island to spawn point.

-- These angles are radians. 0 means east, pi means west, 0.5 * pi means south.
local pi = 3.1416
Export.startIslandAngleToCenterMin = 0.25 * pi
Export.startIslandAngleToCenterMax = 0.75 * pi
Export.startIslandIronMaxDeviationAngle = 0.25 * pi -- On starting island, iron ore spawns on the other side of the island center, with this big of an angle in either direction.
Export.distCenterToIron = 400 -- TODO add the ellipse and blob, so this falls on land.

return Export