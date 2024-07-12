-- This code is from Freight Forwarding. Pending edits.
-- import custom Resource Autoplace
local resource_autoplace = require "code.resource-autoplace.resource-autoplace"
local noise = require "code.resource-autoplace.noise"
local tne = noise.to_noise_expression

local scaleSlider = noise.var("control-setting:Desolation-scale:frequency:multiplier")

data.raw.resource["iron-ore"].map_color = {r=1, g=0, b=0}  -- For debug
data.raw.resource["gold-ore"].map_color = {r=1, g=0, b=1}  -- For debug

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

local function clamp_aux(raw_aux)
	return noise.clamp(raw_aux, 0, 1)
end

-- Create a new expression based on vanilla's aux
data:extend {
	{
		type = "noise-expression",
		name = "resource-spread",
		--intended_property = "aux",
		expression = noise.define_noise_function(function(x, y, tile, map)
			x = x + 20000 -- Move the point where 'fractal similarity' is obvious off into the boonies
			y = y
			local raw_aux =
				0.5 +
				make_multioctave_noise_function(map.seed, 7, 4, 1 / 2, 3, 1, 0.4)(x, y, 1 / 2048, 1 / 4) -- 0.4 affects size of features. Smaller number means bigger 'islands'
			return noise.ident(clamp_aux(raw_aux))
		end)
	},
}

-- Hardcoded special cases in resource-autoplace.lua to make some ores appear both in the starting area and at the edge of the starting island.

-- Redefine base resources here so that they pick up modified defaults from config.lua (starting_resource_placement_radius)
data.raw.resource["copper-ore"].autoplace = resource_autoplace.resource_autoplace_settings {
	name = "copper-ore",
	order = "b1",
	base_density = 10,
	starting_amount = 80000,
	has_starting_area_placement = true,
	regular_rq_factor_multiplier = 1.1,
	starting_rq_factor_multiplier = 1.3,
	candidate_spot_count = 22, -- To match 0.17.50 placement
	ideal_aux = 0.8,
	aux_range = 0.05,
}
data.raw.resource["tin-ore"].autoplace = resource_autoplace.resource_autoplace_settings {
	name = "tin-ore",
	order = "b2",
	base_density = 10,
	starting_amount = 80000,
	has_starting_area_placement = true,
	regular_rq_factor_multiplier = 1.1,
	starting_rq_factor_multiplier = 1.3,
	candidate_spot_count = 22, -- To match 0.17.50 placement
	ideal_aux = 0.15,
	aux_range = 0.05,
}
data.raw.resource["coal"].autoplace = resource_autoplace.resource_autoplace_settings {
	name = "coal",
	order = "b3",
	base_density = 12,
	starting_amount = 160000,
	has_starting_area_placement = true,
	regular_rq_factor_multiplier = 1.0,
	starting_rq_factor_multiplier = 1.2,
	ideal_aux = 0.4,
	aux_range = 0.05,
}
data.raw.resource["stone"].autoplace = resource_autoplace.resource_autoplace_settings {
	name = "stone",
	order = "b4",
	base_density = 12,
	starting_amount = 160000,
	has_starting_area_placement = true,
	regular_rq_factor_multiplier = 1.0,
	starting_rq_factor_multiplier = 1.1,
	ideal_aux = 0.6,
	aux_range = 0.05,
}

local empty_radius = 2200

data.raw.resource["iron-ore"].autoplace = resource_autoplace.resource_autoplace_settings {
	name = "iron-ore",
	order = "b5",
	base_density = 6,
	base_spots_per_km2 = 1,
	has_starting_area_placement = true,
	regular_rq_factor_multiplier = 1.2,
	starting_rq_factor_multiplier = 1.7,
	starting_resource_placement_ring_radius = 1500, -- Spawns the starting patch somewhere at distance from the center
	starting_resource_placement_radius = 2000, -- Keep it reasonably above starting_resource_placement_ring_radius?
	regular_patch_fade_in_distance_start = 2000,
	regular_patch_fade_in_distance = 2000,
	ideal_aux = 0.7,
}

data.raw.resource["uranium-ore"].autoplace = resource_autoplace.resource_autoplace_settings {
	name = "uranium-ore",
	order = "b6",
	base_density = 3,
	base_spots_per_km2 = 1.25,
	has_starting_area_placement = false,
	random_spot_size_minimum = 2,
	random_spot_size_maximum = 4,
	regular_rq_factor_multiplier = 1,
	ideal_aux = 0.3,
	starting_resource_placement_radius = 3000,
	regular_patch_fade_in_distance_start = 3000,
	regular_patch_fade_in_distance = 3000,
}


data.raw.resource["gold-ore"].autoplace = resource_autoplace.resource_autoplace_settings {
	name = "gold-ore",
	order = "b7",
	base_density = 0.9,
	base_spots_per_km2 = 1.25,
	has_starting_area_placement = false,
	regular_rq_factor_multiplier = 0.7,
	regular_patch_fade_in_distance_start = empty_radius,
	regular_patch_fade_in_distance = empty_radius + 100,
	ideal_aux = 0.5,
	aux_range = 0.1,
}

-- TODO controls for the gemstone rocks
-- TODO controls for oil wells
-- TODO controls for the gas fissures.


-- Lava pools
if false then
	data:extend {
		{
			type = "autoplace-control",
			name = "ff-lava-pool",
			localised_name = { "", "[entity=ff-lava-pool] ", { "entity-name.ff-lava-pool" } },
			richness = false,
			order = "z-b",
			category = "resource"
		},
	}

	resource_autoplace.initialize_patch_set("ff-lava-pool-resource", false) -- No idea what it does but it says to call it before resource_autoplace_settings
	data.raw.resource["ff-lava-pool-resource"].autoplace = resource_autoplace.resource_autoplace_settings
		{
			name = "ff-lava-pool",
			order = "a", -- Other resources are "b"; lava will override if something else is already there.
			base_density = 8.2,
			base_spots_per_km2 = 2,
			random_probability = 1 / 48,
			random_spot_size_minimum = 0.8,
			random_spot_size_maximum = 1.2,
			size_multiplier_coefficient = 4,
			has_starting_area_placement = false,
			regular_rq_factor_multiplier = 1,
			starting_resource_placement_radius = 3000,
			regular_patch_fade_in_distance_start = 3000,
			regular_patch_fade_in_distance = 3000,
			ideal_aux = 0.9,
		}
end

if false and not (mods["Mining-Space-Industries-II"] or mods["LunarLandings"] or mods["space-exploration"]) then
	data:extend {
		{
			type = "autoplace-control",
			name = "ff-rocket-silo-hole",
			--localised_name = {"", "[entity=ff-seamount] ", {"entity-name.ff-seamount"}},
			localised_name = { "entity-name.ff-rocket-silo-hole" },
			richness = false,
			order = "z-c",
			category = "resource"
		},
	}

	data.raw.resource["ff-rocket-silo-hole"].autoplace = {
		control = "ff-rocket-silo-hole",
		order = "a",
		probability_expression = noise.define_noise_function(function(x, y, tile, map)
			-- Frequency value from map gen settings
			local frequency_multiplier = noise.var("control-setting:ff-rocket-silo-hole:frequency:multiplier")
			local desired_frequency = 1.4 / (64 * 64 ^ 2)

			local elevation = noise.var("elevation")
			local distance = noise.var("distance")
			local aux = noise.var("resource-spread")

			local elevation_multiplier = noise.if_else_chain(
				noise.less_than(8, elevation),                      -- only spawn at elevation 10 or higher
				noise.if_else_chain(
					noise.less_than(4000, distance),                -- spawn far from start
					noise.if_else_chain(noise.less_than(aux, 0.6), 1, 0), -- keep away from lava pools
					0
				),
				0
			)
			return desired_frequency * frequency_multiplier * elevation_multiplier
		end),
		richness_expression = noise.define_noise_function(function(x, y, tile, map)
			return 10 -- Overwritten in control by script trigger
		end)
	}
end
