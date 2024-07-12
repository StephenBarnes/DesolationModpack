local Export = {}

Export.xShift = 20000 -- Added to x, to get rid of fractal symmetry.

Export.startIslandMaxRad = 400
Export.startIslandMinRad = 200

local pi = 3.1416
Export.startIslandAngleToCenterMin = 0.25 * pi
Export.startIslandAngleToCenterMax = 0.75 * pi
-- These angles are radians. 0 means east, pi means west, 0.5 * pi means south.

return Export