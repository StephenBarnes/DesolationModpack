-- This file makes the noise expressions "Desolation-temperature", "Desolation-aux", and "Desolation-moisture".
-- The "meaning" of these is:
--   Temperature: in cold regions, we place snow or ice, which cannot be built on. In hot regions, we place grass or volcanic rock, which can be built on.
--   Aux: In cold regions, determines whether snow or ice is placed.
--   Moisture: In hot regions, determines whether grass or volcanic rock is placed.

-- Using this system because it sorta makes sense (unbuildable tiles are snow/ice), and it works well with the built-in peaks autoplace system.
-- (I tried using non-peaks for placing tiles, but it ran very slowly.)

-- TODO this should have bumps at the starting area, iron+coal patch, extra copper+tin patch, and then outside the starting island.
-- TODO the resource spawning layers outside the starting island should also use this temperature layer.

local noise = require "noise"
local tne = noise.to_noise_expression
local var = noise.var

local C = require("code.data.terrain.constants")
local U = require("code.data.terrain.util")


------------------------------------------------------------------------
-- Temperature

local function clamp_temperature(raw_temperature)
	return noise.clamp(raw_temperature, -20, 150) -- Alien Biomes seems to use this range, so let's use the same range.
end

-- Start with a base layer of noise.
local tempNoise = U.multiBasisNoise(7, 2, 2,
	C.temperatureScale / var("scale"),
	C.temperatureAmplitude)
local temperature = tempNoise

-- Then make the entire starting island cold.
local maxTempStartIsland = U.ramp(var("dist-to-start-island-rim") / var("scale"),
	0, C.otherIslandsMinDistFromStartIsland,
	-10, 200)
temperature = noise.min(temperature, maxTempStartIsland)

-- Noise layer for the warm oasis at spawn and the two arc-oases.
local tempOasisNoise = U.multiBasisNoise(7, 2, 2,
	C.oasisNoiseScale / var("scale"),
	C.oasisNoiseAmplitude)

-- Add warm patch at spawn.
local minTempForSpawn = U.rampDouble(var("distance") / var("scale"),
	C.spawnOasisMinRad, C.spawnOasisMidRad, C.spawnOasisMaxRad,
	50, 10, -150)
temperature = noise.max(temperature, minTempForSpawn + tempOasisNoise)

-- Add warm patch at the copper/tin center.
local minTempForCopperTin = U.rampDouble(var("dist-to-copper-tin-patches-center") / var("scale"),
	C.copperTinOasisMinRad, C.copperTinOasisMidRad, C.copperTinOasisMaxRad,
	40, 10, -150)
temperature = noise.max(temperature, minTempForCopperTin + tempOasisNoise)

-- Add warm patch at the iron/copper center.
local minTempForIronCoal = U.rampDouble(var("dist-to-iron-coal-center") / var("scale"),
	C.ironCoalOasisMinRad, C.ironCoalOasisMidRad, C.ironCoalOasisMaxRad,
	50, 10, -150)
temperature = noise.max(temperature, minTempForIronCoal + tempOasisNoise)

-- TODO add warm patches near sides, so you can load ships.

U.nameNoiseExpr("Desolation-temperature",
	temperature)

U.nameNoiseExpr("buildable-temperature",
	noise.less_than(C.temperatureThresholdForSnow, temperature))

------------------------------------------------------------------------
-- Aux -- this determines snow vs ice.

U.nameNoiseExpr("Desolation-aux",
	U.multiBasisNoise(4, 2, 2,
		C.auxScale / var("scale"),
		C.auxAmplitude)
	+ C.auxBias
)

------------------------------------------------------------------------
-- Moisture -- this determines grass vs volcanic rock.

local moistureNoise = U.multiBasisNoise(4, 2, 2,
	C.moistureScale / var("scale"),
	C.moistureAmplitude)

local moisture = moistureNoise + C.moistureBias

-- Adjust so that start island is completely volcanic rock, not grass.
moisture = noise.if_else_chain(noise.less_than(var("dist-to-start-island-rim"), 200 * var("scale")), -10, moisture)

U.nameNoiseExpr("Desolation-moisture", moisture)