-- Utils for terrain/resource generation.
-- This file should only contain general-purpose stuff, not code dealing with specific terrain shapes and positions etc. Rather put that in make-map-common-vars.lua.

-- Note much of this will change when Factorio 2.0 is released.
--   Here's an example of what it will look like: https://gist.github.com/Genhis/b4c88f47bb39e06a0739a1c177e13d4a
--   I think we won't need that many changes actually.
--     Could probably even make/use an adapter library that rewrites stuff like noise.if_else_chain to just return wrapped strings.


local noise = require "noise"
local tne = noise.to_noise_expression
local var = noise.var

local C = require("code.data.terrain.constants")

local X = {} -- Exported values.

------------------------------------------------------------------------
-- We register some of our computations as named noise-expression prototypes, so that we can use them in multiple places.
-- Before Factorio 2.0 release, this should improve performance, because it de-duplicates repeated subtrees.
-- After Factorio 2.0 release, change this to register noise-function prototypes, or local-functions, or whatever we use then.

X.namedNoiseVarPrototype = function(name, expr)
	return {
		type = "noise-expression",
		name = name,
		intended_property = name,
		expression = expr,
	}
end

X.nameNoiseExpr = function(name, expr)
	data:extend({X.namedNoiseVarPrototype(name, expr)})
end

-- For dealing with {x,y} positions, we register separate vars for x and y.
-- We could use an array-expression (within the noise system). But that's getting removed in Factorio 2.0.
X.nameNoiseExprXY = function(name, exprs)
	data:extend({
		X.namedNoiseVarPrototype(name.."-x", exprs[1]),
		X.namedNoiseVarPrototype(name.."-y", exprs[2]),
	})
end

------------------------------------------------------------------------
-- Basis noise layers

local nextSeed1 = 0
X.getNextSeed1 = function()
	nextSeed1 = nextSeed1 + 1
	return nextSeed1
end

X.basisNoise = function(inScale, outScale)
	if outScale == nil then outScale = 1 / inScale end
	return tne{
		type = "function-application",
		function_name = "factorio-basis-noise",
		arguments = {
			x = var("x") + C.artifactShift,
			y = var("y"),
			seed0 = var("map_seed"),
			seed1 = tne(X.getNextSeed1()),
			input_scale = inScale,
			output_scale = outScale,
		}
	}
end

X.multiBasisNoise = function(octaves, inScaleMultiplier, outScaleDivisor, inScale, outScale)
	-- Makes multioctave noise function by layering multiple basis noise functions.
	-- Output of first (strongest) layer will generally be between -outScale and +outScale. So all layers together will be like double that range, very roughly.
	if outScale == nil then outScale = 1 / inScale end
	return tne{
		type = "function-application",
		function_name = "factorio-quick-multioctave-noise",
		arguments = {
			x = var("x") + C.artifactShift,
			y = var("y"),
			seed0 = var("map_seed"),
			seed1 = tne(X.getNextSeed1()),
			input_scale = tne(inScale),
			output_scale = tne(outScale),
			octaves = tne(octaves),
			octave_output_scale_multiplier = 1 / tne(outScaleDivisor),
			octave_input_scale_multiplier = tne(inScaleMultiplier),
		}
	}
end

X.multiBasisNoiseSlow = function(levels, inScaleMultiplier, outScaleDivisor, inScale, outScale)
	-- Slower, Lua version of multiBasisNoise. Don't use this, just leaving it here bc it works and shows what multiBasisNoise does.
	local result = X.basisNoise(inScale, outScale)
	for i = 2, levels do
		inScale = inScale * inScaleMultiplier
		outScale = outScale / outScaleDivisor
		local basis = X.basisNoise(inScale, outScale)
		result = result + basis
	end
	return result
end

------------------------------------------------------------------------

X.varXY = function(varName)
	return { var(varName.."-x"), var(varName.."-y") }
end

X.mapRandBetween = function(a, b, seed, steps)
	-- Returns a random number between a and b, that will be constant at every point on the map for the given seed.
	return a + (b - a) * (noise.fmod(seed, steps) / steps)
end

X.moveInDir = function(x, y, angle, distance)
	return {
		x + distance * noise.cos(angle),
		y + distance * noise.sin(angle),
	}
end

X.moveVarInDir = function(varName, angle, distance)
	local x = var(varName.."-x")
	local y = var(varName.."-y")
	return X.moveInDir(x, y, angle, distance)
end

X.moveInDirScaled = function(x, y, angle, distance)
	return {
		noise.define_noise_function(function(otherX, otherY, tile, map)
			local scale = 1 / (C.terrainScaleSlider * map.segmentation_multiplier)
			return x + distance * noise.cos(angle) * scale
		end),
		noise.define_noise_function(function(otherX, otherY, tile, map)
			local scale = 1 / (C.terrainScaleSlider * map.segmentation_multiplier)
			return y + distance * noise.sin(angle) * scale
		end),
	}
end

X.moveVarInDirScaled = function(varName, angle, distance)
	local x = var(varName.."-x")
	local y = var(varName.."-y")
	return X.moveInDirScaled(x, y, angle, distance)
end

X.dist = function(x1, y1, x2, y2)
	return ((noise.absolute_value(x1 - x2) ^ 2) + (noise.absolute_value(y1 - y2) ^ 2)) ^ tne(0.5)
	-- No idea why the absolute value is necessary, but it seems to be necessary.
end

X.distVarXY = function(var1, x2, y2)
	local x1 = var(var1.."-x")
	local y1 = var(var1.."-y")
	return X.dist(x1, y1, x2, y2)
end

X.distVars = function(var1, var2)
	local x1 = var(var1.."-x")
	local y1 = var(var1.."-y")
	local x2 = var(var2.."-x")
	local y2 = var(var2.."-y")
	return X.dist(x1, y1, x2, y2)
end

X.ramp = function(v, v1, v2, out1, out2)
	-- If v < v1, then return out1. If v > v2, then return out2. Otherwise interpolate between out1 and out2.
	-- We should have v1 < v2, but not necessarily out1 < out2.
	local vBelow = noise.less_than(v, v1)
	local vAbove = noise.less_than(v2, v)
	local interpolationFrac = (v - v1) / (v2 - v1)
	local interpolated = interpolationFrac * out2 + (1 - interpolationFrac) * out1
	return noise.if_else_chain(vBelow, out1, vAbove, out2, interpolated)
end

X.ramp01 = function(v, v1, v2)
	local vBelow = noise.less_than(v, v1)
	local vAbove = noise.less_than(v2, v)
	local interpolationFrac = (v - v1) / (v2 - v1)
	local interpolated = interpolationFrac
	return noise.if_else_chain(vBelow, 0, vAbove, 1, interpolated)
end

X.rampDouble = function(v, v1, v2, v3, out1, out2, out3)
	-- If v < v1, then return out1. If v > v3, then return out3. Otherwise, interpolate between out1 and out2, or between out2 and out3.
	-- We should have v1 < v2 < v3, but not necessarily out1 < out2 < out3.
	local interpolationFrac1 = (v - v1) / (v2 - v1)
	local interpolated1 = interpolationFrac1 * out2 + (1 - interpolationFrac1) * out1

	local interpolationFrac2 = (v - v2) / (v3 - v2)
	local interpolated2 = interpolationFrac2 * out3 + (1 - interpolationFrac2) * out2

	return noise.if_else_chain(noise.less_than(v, v1), out1,
		noise.less_than(v, v2), interpolated1,
		noise.less_than(v, v3), interpolated2, out3)
end

X.rampTriple = function(v, v1, v2, v3, v4, out1, out2, out3, out4)
	local interpolationFrac1 = (v - v1) / (v2 - v1)
	local interpolated1 = interpolationFrac1 * out2 + (1 - interpolationFrac1) * out1

	local interpolationFrac2 = (v - v2) / (v3 - v2)
	local interpolated2 = interpolationFrac2 * out3 + (1 - interpolationFrac2) * out2

	local interpolationFrac3 = (v - v3) / (v4 - v3)
	local interpolated3 = interpolationFrac3 * out4 + (1 - interpolationFrac3) * out3

	return noise.if_else_chain(noise.less_than(v, v1), out1,
		noise.less_than(v, v2), interpolated1,
		noise.less_than(v, v3), interpolated2,
		noise.less_than(v, v4), interpolated3, out4)
end

X.between = function(v, v1, v2, ifTrue, ifFalse)
	-- Assumes v1 < v2.
	return noise.if_else_chain(noise.less_than(v, v1), ifFalse,
		noise.less_than(v2, v), ifFalse, ifTrue)
end

------------------------------------------------------------------------

return X