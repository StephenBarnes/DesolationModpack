-- Adjust the temperature noise layer so starting island is always snowy.
-- Some of this code is copied from Factorio's core code.

local noise = require "noise"
local tne = noise.to_noise_expression

local scaleSlider = noise.var("control-setting:Desolation-scale:frequency:multiplier")

local average_sea_level_temperature = 15
local elevation_temperature_gradient = 0 -- -0.5 might be a good value to start with if you want to try correlating temperature with elevation

local function make_multioctave_noise_function(seed0, seed1, octaves, octave_output_scale_multiplier,
												octave_input_scale_multiplier, output_scale0, input_scale0)
	octave_output_scale_multiplier = octave_output_scale_multiplier or 2
	octave_input_scale_multiplier = octave_input_scale_multiplier or (1 / octave_output_scale_multiplier)
	return function(x, y, inscale, outscale)
		return tne {
			type = "function-application",
			function_name = "factorio-quick-multioctave-noise",
			arguments =
			{
				x = tne(x) * scaleSlider,
				y = tne(y) * scaleSlider,
				seed0 = tne(seed0),
				seed1 = tne(seed1),
				input_scale = tne((inscale or 1) * (input_scale0 or 1)),
				output_scale = tne((outscale or 1) * (output_scale0 or 1)),
				octaves = tne(octaves),
				octave_output_scale_multiplier = tne(octave_output_scale_multiplier),
				octave_input_scale_multiplier = tne(octave_input_scale_multiplier)
			}
		}
	end
end

local function clamp_temperature(raw_temperature)
	return noise.clamp(raw_temperature, -20, 150)
end

if false then
	-- This is the vanilla game's temperature code, adjusted for cold patch.
	-- But, not using this, because we're running Alien Biomes, which makes its own temperature layer.
	data.raw["noise-expression"].temperature.expression = noise.define_noise_function(function(x, y, tile, map)
		x = x * noise.var("control-setting:temperature:frequency:multiplier") + 40000
		y = y * noise.var("control-setting:temperature:frequency:multiplier")
		local base_temp =
			average_sea_level_temperature +
			make_multioctave_noise_function(map.seed, 5, 4, 3)(x, y, 1 / 32, 1 / 20) +
			noise.var("control-setting:temperature:bias")
		local elevation_adjusted_temperature = base_temp + noise.var("elevation") * elevation_temperature_gradient

		local startColdPatchRadius = 50 * scaleSlider
		local dist = noise.distance_from(x, y, noise.var("starting_lake_positions"), 1024) * scaleSlider
		local tempAdjustment = dist - startColdPatchRadius - 20
		local tempAdjustmentClamped = noise.clamp(tempAdjustment, -20, 0)
		local correctedTemp = elevation_adjusted_temperature + tempAdjustmentClamped

		return noise.ident(clamp_temperature(correctedTemp))
	end)
end

local originalTempExpr = data.raw["noise-expression"].temperature.expression
local newTempExpr = noise.define_noise_function(function(x, y, tile, map)
	local startColdPatchRadius = 1800 / scaleSlider
	local dist = noise.distance_from(x, y, noise.var("starting_lake_positions"), 1024)
	local startPatchInfluence = (startColdPatchRadius - dist) / startColdPatchRadius
	local startPatchInfluenceClamped = noise.clamp(startPatchInfluence, 0, 1)
	local tempAdjustment = -170 * startPatchInfluenceClamped
	local correctedTemp = originalTempExpr + tempAdjustment
	return noise.ident(clamp_temperature(correctedTemp))
end)
data.raw["noise-expression"].temperature.expression = newTempExpr