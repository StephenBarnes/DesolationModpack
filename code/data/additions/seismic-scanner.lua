-- Most of this is copied from Freight Forwarding mod.

local hit_effects = require "__base__.prototypes.entity.hit-effects"
local sounds = require "__base__.prototypes.entity.sounds"
local shift = {x = 0, y = -0.5}

data:extend({
	{
		type = "item",
		name = "seismic-scanner",
		icon = "__Desolation__/graphics/seismic-scanner/seismic-scanner-icon.png",
		icon_size = 64,
		icon_mipmaps = 1,
		subgroup = "defensive-structure",
		order = "d[radar]-b[radar]",
		place_result = "seismic-scanner",
		stack_size = 1,
	},
	{
		type = "recipe",
		name = "seismic-scanner",
		enabled = true, -- TODO add to a tech
		ingredients = {
			{"advanced-circuit", 5},
			{"electric-engine-unit", 10},
			{"explosives", 10}
		},
		result = "seismic-scanner"
	},
	{
		type = "radar",
		name = "seismic-scanner",
		icon = "__Desolation__/graphics/seismic-scanner/seismic-scanner-icon.png",
		icon_size = 64,
		icon_mipmaps = 1,
		flags = {"placeable-player", "player-creation"},
		minable = {mining_time = 0.5, result = "seismic-scanner"},
		max_health = 250,
		corpse = "radar-remnants",
		dying_explosion = "radar-explosion",
		resistances = data.raw.radar.radar.resistances,
		collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
		selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
		damaged_trigger_effect = hit_effects.entity(),
		energy_per_sector = "1MJ", -- Can set lower to speed up the scans, for testing.
		-- TODO change this to use a burner energy source, with explosives as the fuel!
		max_distance_of_sector_revealed = 1,
		max_distance_of_nearby_sector_revealed = 1,
		energy_per_nearby_scan = "250kJ", -- This is for the nearby map-revealing, not the scans far away.
		energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			emissions_per_minute = 150  -- One mining drill is 10
		},
		energy_usage = "600kW",
		integration_patch = {
			layers = {
				{
					filename = "__Desolation__/graphics/seismic-scanner/hr-hole.png",
					priority = "extra-high",
					width = 322,
					height = 300,
					scale = 0.5 * 3/4,
					variation_count = 1,
					shift = {0.25, -0.5},
					hr_version = {
						filename = "__Desolation__/graphics/seismic-scanner/hr-hole.png",
						priority = "extra-high",
						width = 322,
						height = 300,
						scale = 0.5 * 3/4,
						variation_count = 1,
						shift = {0.25, -0.5},
					},
				},
				{
					filename = "__Desolation__/graphics/seismic-scanner/hr-hole-front.png",
					priority = "extra-high",
					animation_speed = 0.5,
					width = 322,
					height = 300,
					scale = 0.5 * 3/4,
					direction_count = 1,
					shift = {0.25, -0.5},
					hr_version = {
						filename = "__Desolation__/graphics/seismic-scanner/hr-hole-front.png",
						priority = "extra-high",
						animation_speed = 0.5,
						width = 322,
						height = 300,
						scale = 0.5 * 3/4,
						direction_count = 1,
						shift = {0.25, -0.5},
					},
				},
			},
		},
		
		pictures = {
			layers = {
				{
					filename = "__Desolation__/graphics/seismic-scanner/hr-center.png",
					priority = "high",
					animation_speed = 0.5,
					line_length = 8,
					direction_count = 64,
					-- width = 70,
					-- height = 123,
					-- scale = 1.5,
					-- shift = {0 + shift.x, -1 + shift.y},
					width = 139,
					height = 246,
					scale = 0.5 * 1.5,
					shift = {-0.1 + shift.x, 0 + shift.y},
					hr_version = {
						filename = "__Desolation__/graphics/seismic-scanner/hr-center.png",
						priority = "high",
						line_length = 8,
						animation_speed = 0.5,
						direction_count = 64,
						width = 139,
						height = 246,
						scale = 0.5 * 1.5,
						shift = {-0.1 + shift.x, 0 + shift.y},
					}
				},
				{
					filename = "__Desolation__/graphics/seismic-scanner/hr-center-shadow.png",
					draw_as_shadow = true,
					priority = "high",
					line_length = 8,
					direction_count = 64,
					-- width = 108,
					-- height = 54,
					-- scale = 1.4,
					-- shift = {1.5 + shift.x, 0 + shift.y},
					width = 163,
					height = 123,
					scale = 0.5 * 1.4,
					shift = {1.5 + shift.x, 0 + shift.y},
					hr_version = {
						filename = "__Desolation__/graphics/seismic-scanner/hr-center-shadow.png",
						draw_as_shadow = true,
						priority = "high",
						line_length = 8,
						direction_count = 64,
						width = 163,
						height = 123,
						scale = 0.5 * 1.4,
						shift = {1.5 + shift.x, 0 + shift.y},
					}
				},
			},
		},
		vehicle_impact_sound = sounds.generic_impact,
		working_sound = {
			sound = {
				{
					filename = "__base__/sound/radar.ogg",
					volume = 0.8
				}
			},
			max_sounds_per_type = 3,
			--audible_distance_modifier = 0.8,
			use_doppler_shift = false
		},
		radius_minimap_visualisation_color = { r = 0.059, g = 0.092, b = 0.235, a = 0.275 },
		rotation_speed = 0.01,
		water_reflection = {
			pictures = {
				filename = "__base__/graphics/entity/radar/radar-reflection.png",
				priority = "extra-high",
				width = 28,
				height = 32,
				shift = util.by_pixel(5, 35),
				variation_count = 1,
				scale = 5
			},
			rotate = false,
			orientation_to_variation = false
		},
	},
})