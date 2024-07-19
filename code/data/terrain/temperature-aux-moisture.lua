-- This file makes the noise expressions "Desolation-temperature", "Desolation-aux", and "Desolation-moisture".
-- The "meaning" of these is:
--   Temperature: in cold regions, we place snow or ice, which cannot be built on. In hot regions, we place grass or volcanic rock, which can be built on.
--   Aux: In cold regions, determines whether snow or ice is placed.
--   Moisture: In hot regions, determines whether grass or volcanic rock is placed.

-- Using this system because it sorta makes sense (unbuildable tiles are snow/ice), and it works well with the built-in peaks autoplace system.
-- (I tried using non-peaks for placing tiles, but it ran very slowly.)

-- TODO this should have bumps at the starting area, iron+coal patch, extra copper+tin patch, and then outside the starting island.
-- TODO the resource spawning layers outside the starting island should also use this buildable noise-layer.

local noise = require "noise"
local tne = noise.to_noise_expression
local var = noise.var

local C = require("code.data.terrain.constants")
local U = require("code.data.terrain.util")

U.nameNoiseExpr("Desolation-temperature",
	U.multiBasisNoise(9, 2, 2,
		C.temperatureScale / var("scale"),
		C.temperatureAmplitude)
	)

U.nameNoiseExpr("Desolation-aux",
	U.multiBasisNoise(9, 2, 2,
		C.auxScale / var("scale"),
		tne(13) * C.auxAmplitude)
	+ C.auxBias
)

U.nameNoiseExpr("Desolation-moisture",
	U.multiBasisNoise(9, 2, 2,
		C.moistureScale / var("scale"),
		tne(13) * C.moistureAmplitude)
	+ C.moistureBias
)