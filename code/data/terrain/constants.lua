local Export = {}

Export.artifactShift = 20000 -- Added to a coordinate, to get rid of fractal symmetry.

Export.startIslandMinRad = 400 -- Distance from center of starting island to the closest ocean
Export.startIslandMaxRad = 800 -- Distance from center of starting island to the furthest end of the starting island
Export.spawnToStartIslandCenter = 200 -- Distance from center of starting island to spawn point.

local pi = 3.1416
Export.startIslandAngleToCenterMin = 0.25 * pi
Export.startIslandAngleToCenterMax = 0.75 * pi
-- These angles are radians. 0 means east, pi means west, 0.5 * pi means south.

return Export