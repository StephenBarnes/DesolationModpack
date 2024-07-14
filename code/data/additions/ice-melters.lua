-- Add machines for melting ice to water.
-- Reusing IR3's copper/iron/electric boiler images, but instead of water inputs, they have water outputs.

-- TODO make these globals.
local iconSize = 64
local numIconMipmaps = 4

local copperMelterIcons = {
	{icon = data.raw.item["copper-boiler"].icons[1].icon, scale = 0.5, icon_size = iconSize, icon_mipmaps = numIconMipmaps},
	{icon = data.raw.item.ice.icon, scale = 0.25, icon_size = iconSize, icon_mipmaps = numIconMipmaps, shift = {-7, -7}},
}
local electricMelterIcons = {
	{icon = data.raw.item["steel-boiler"].icons[1].icon, scale = 0.5, icon_size = iconSize, icon_mipmaps = numIconMipmaps},
	{icon = data.raw.item.ice.icon, scale = 0.25, icon_size = iconSize, icon_mipmaps = numIconMipmaps, shift = {-7, -7}},
}

data:extend({
	{
		type = "recipe-category",
		name = "ice-melting",
	},
	{ -- Recipe for ice melting.
		type = "recipe",
		name = "melt-ice-to-water-and-steam",
		icons = {
			{icon = data.raw.fluid.water.icon, scale = 0.5, icon_size = iconSize, icon_mipmaps = numIconMipmaps},
			{icon = data.raw.item.ice.icon, scale = 0.25, icon_size = iconSize, icon_mipmaps = numIconMipmaps, shift = {-7, -7}},
			{icon = data.raw.fluid.steam.icon, scale = 0.25, icon_size = iconSize, icon_mipmaps = numIconMipmaps, shift = {-7, 7}},
		},
		subgroup = "energy",
		order = "a",
		category = "ice-melting",
		enabled = true,
		ingredients = {{"ice", 3}},
		results = {
			{type="fluid", name="water", amount=20, temperature = 15},
			{type="fluid", name="steam", amount=10, temperature = 165},
		},
		localised_name = {"recipe-name.melt-ice-to-water-and-steam"},
		energy_required = 6,
		main_product = "water",
		allow_as_intermediate = false,
		allow_intermediates = false,
		allow_decomposition = false,
		hide_from_player_crafting = true,
	},

	-- For the copper melter: create entity, item, and recipe.
	{
		type = "item",
		name = "copper-ice-melter",
		icons = copperMelterIcons,
		subgroup = data.raw.item["copper-boiler"].subgroup,
		order = data.raw.item["copper-boiler"].order .. "b",
		stack_size = data.raw.item["copper-boiler"].stack_size,
		place_result = "copper-ice-melter",
	},
	{
		type = "recipe",
		name = "copper-ice-melter",
		icons = copperMelterIcons,
		subgroup = data.raw.recipe["copper-boiler"].subgroup,
		order = "a",
		category = "crafting",
		enabled = data.raw.recipe["copper-boiler"].enabled,
		ingredients = data.raw.recipe["copper-boiler"].ingredients,
		result = "copper-ice-melter",
		result_count = 1,
		energy_required = data.raw.recipe["copper-boiler"].energy_required,
	},
	{
		type = "furnace",
		name = "copper-ice-melter",
		source_inventory_size = 1,
		result_inventory_size = 0, -- No item results. Game automatically adds 2 slots for the fluids.
		energy_usage = "300kW",
		energy_source = data.raw.boiler["copper-boiler"].energy_source,
		crafting_speed = 1,
		crafting_categories = {"ice-melting"},
		icons = copperMelterIcons,
		flags = data.raw.boiler["copper-boiler"].flags,
		collision_box = data.raw.boiler["copper-boiler"].collision_box,
		selection_box = data.raw.boiler["copper-boiler"].selection_box,
		drawing_box = data.raw.boiler["copper-boiler"].drawing_box,
		vehicle_impact_sound = data.raw.boiler["copper-boiler"].vehicle_impact_sound,
		open_sound = data.raw.boiler["copper-boiler"].open_sound,
		close_sound = data.raw.boiler["copper-boiler"].close_sound,
		working_sound = data.raw.boiler["copper-boiler"].working_sound,
		max_health = data.raw.boiler["copper-boiler"].max_health,
		resistances = data.raw.boiler["copper-boiler"].resistances,
		fluid_boxes = {
			{
				base_area = 1,
				base_level = 1,
				filter = "water",
				height = 2,
				pipe_connections = {
					{
						position = {0, -2},
						type = "output",
					}
				},
				pipe_covers = data.raw["assembling-machine"]["assembling-machine-1"].fluid_boxes[1].pipe_covers,
				production_type = "output"
			},
			{
				base_area = 1,
				base_level = 1,
				filter = "steam",
				height = 2,
				pipe_connections = {
					{
						position = {0, 2},
						type = "output",
					}
				},
				pipe_covers = data.raw["assembling-machine"]["assembling-machine-1"].fluid_boxes[1].pipe_covers,
				production_type = "output"
			}
		},
		minable = {
			mining_time = data.raw.boiler["copper-boiler"].minable.mining_time,
			results = {{"copper-ice-melter", 1}},
		},
		animation = {
			north = data.raw.boiler["copper-boiler"].structure.north,
			east = data.raw.boiler["copper-boiler"].structure.east,
			south = data.raw.boiler["copper-boiler"].structure.south,
			west = data.raw.boiler["copper-boiler"].structure.west,
		},
		working_visualisations = { -- Show fire on top of the boiler when it's working.
			{
				north_animation = data.raw.boiler["copper-boiler"].fire.north,
				east_animation = data.raw.boiler["copper-boiler"].fire.east,
				south_animation = data.raw.boiler["copper-boiler"].fire.south,
				west_animation = data.raw.boiler["copper-boiler"].fire.west,
				render_layer = "object",
				fadeout = true,
			},
		},
	},

	-- For the electric melter: create entity, item, and recipe.
	{
		type = "item",
		name = "electric-ice-melter",
		icons = electricMelterIcons,
		subgroup = data.raw.item["steel-boiler"].subgroup,
		order = data.raw.item["steel-boiler"].order .. "b",
		stack_size = data.raw.item["steel-boiler"].stack_size,
		place_result = "electric-ice-melter",
	},
	{
		type = "recipe",
		name = "electric-ice-melter",
		icons = electricMelterIcons,
		subgroup = data.raw.recipe["steel-boiler"].subgroup,
		order = "a",
		category = "crafting",
		enabled = data.raw.recipe["steel-boiler"].enabled,
		ingredients = {
				--data.raw.recipe["steel-boiler"].ingredients, -- No, because it requires steel and concrete; the electric boiler was meant to be later in tech tree.
				{"pipe", 3},
				{"iron-plate", 10},
				{"stone-brick", 20},
				{"iron-beam", 2},
		},
		result = "electric-ice-melter",
		result_count = 1,
		energy_required = data.raw.recipe["steel-boiler"].energy_required,
	},
	{
		type = "furnace",
		name = "electric-ice-melter",
		source_inventory_size = 1,
		result_inventory_size = 0, -- No item results. Game automatically adds 2 slots for the fluids.
		energy_usage = "500kW", -- For comparison, electric boiler is 1.25MW, copper boiler is 300kW.
		energy_source = data.raw["assembling-machine"]["steel-boiler"].energy_source,
		crafting_speed = 2, -- Double the crafting speed of copper boiler.
		crafting_categories = {"ice-melting"},
		icons = electricMelterIcons,
		flags = data.raw["assembling-machine"]["steel-boiler"].flags,
		collision_box = data.raw["assembling-machine"]["steel-boiler"].collision_box,
		selection_box = data.raw["assembling-machine"]["steel-boiler"].selection_box,
		drawing_box = data.raw["assembling-machine"]["steel-boiler"].drawing_box,
		vehicle_impact_sound = data.raw["assembling-machine"]["steel-boiler"].vehicle_impact_sound,
		open_sound = data.raw["assembling-machine"]["steel-boiler"].open_sound,
		close_sound = data.raw["assembling-machine"]["steel-boiler"].close_sound,
		working_sound = data.raw["assembling-machine"]["steel-boiler"].working_sound,
		max_health = data.raw["assembling-machine"]["steel-boiler"].max_health,
		resistances = data.raw["assembling-machine"]["steel-boiler"].resistances,
		fluid_boxes = {
			{
				base_area = 1,
				base_level = 1,
				filter = "water",
				height = 2,
				pipe_connections = {
					{
						position = {0, -2},
						type = "output",
					}
				},
				pipe_covers = data.raw["assembling-machine"]["assembling-machine-1"].fluid_boxes[1].pipe_covers,
				production_type = "output"
			},
			{
				base_area = 1,
				base_level = 1,
				filter = "steam",
				height = 2,
				pipe_connections = {
					{
						position = {0, 2},
						type = "output",
					}
				},
				pipe_covers = data.raw["assembling-machine"]["assembling-machine-1"].fluid_boxes[1].pipe_covers,
				production_type = "output"
			}
		},
		minable = {
			mining_time = data.raw["assembling-machine"]["steel-boiler"].minable.mining_time,
			results = {{"electric-ice-melter", 1}},
		},
		animation = data.raw["assembling-machine"]["steel-boiler"].animation,
		working_visualisations = data.raw["assembling-machine"]["steel-boiler"].working_visualisations,
		status_colors = data.raw["assembling-machine"]["steel-boiler"].status_colors,
	},
})

-- Add recipes to techs.
local Tech = require("code.util.tech")
Tech.addRecipeToTech("copper-ice-melter", "ir-copper-working-2", 8)
Tech.addRecipeToTech("melt-ice-to-water-and-steam", "ir-copper-working-2", 9)
Tech.addRecipeToTech("electric-ice-melter", "ir-steam-power", 3) -- This is the electricity tech.
-- TODO add the iron ice melter here.


-- TODO create iron melter

-- TODO describe the recipe in the melter's description - how long, how much water per second, etc. so that people can figure out the ratios without knowing to look at the techs.
-- TODO allow unlubricated loaders to use the melters, and the boilers.