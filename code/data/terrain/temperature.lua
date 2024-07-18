-- This file makes the noise expression "Desolation-temperature".
-- This is used to determine where to place buildable tiles. It doesn't affect eg presence of "volcanic" tiles.
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
		tne(13) * C.temperatureAmplitude)
	)