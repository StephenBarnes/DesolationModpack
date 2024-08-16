-- Add machines for melting ice to water.
-- Reusing IR3's copper/iron/electric boiler images, but instead of water inputs, they have water outputs.

-- We want these to be in line with IR3's boilers, roughly.
-- In IR3, water at 15C gets converted to steam at 165C, using 300kW burnable fuel - for copper boiler. Iron boiler is the same but x6.
-- In IR3, this steam at 165C is worth 11.67kJ per 1steam.
-- A steam inserter uses 1steam/sec.
-- So roughly, the 10/sec steam at 165C produced by the boiler is worth 11.67kJ * 10/sec = 116.7kW.
-- So the boilers lose around 2/3 of the input burnable fuel.
-- For the melters, we want the total fluid produced to be in line with the boilers, so like 10/sec to 60/sec.
-- And for the melters, steam output should be lower than boilers with the same amount of fuel; they should mostly output water.

local Table = require("code.util.table")

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
local ironMelterIcons = {
	{icon = data.raw.item.boiler.icon, scale = 0.5, icon_size = iconSize, icon_mipmaps = numIconMipmaps},
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
		ingredients = {{"ice", 5}},
		results = {
			{type="fluid", name="water", amount=50, temperature = 15},
			{type="fluid", name="steam", amount=25, temperature = 165},
		},
		localised_name = {"recipe-name.melt-ice-to-water-and-steam"},
		energy_required = 5, -- Seconds for the copper melter.
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

	-- For the iron melter: create entity, item, and recipe.
	{
		type = "item",
		name = "iron-ice-melter",
		icons = ironMelterIcons,
		subgroup = data.raw.item.boiler.subgroup,
		order = data.raw.item.boiler.order .. "b",
		stack_size = data.raw.item.boiler.stack_size,
		place_result = "iron-ice-melter",
	},
	{
		type = "recipe",
		name = "iron-ice-melter",
		icons = ironMelterIcons,
		subgroup = data.raw.recipe.boiler.subgroup,
		order = "a",
		category = "crafting",
		enabled = data.raw.recipe.boiler.enabled,
		ingredients = data.raw.recipe.boiler.ingredients,
		result = "iron-ice-melter",
		result_count = 1,
		energy_required = data.raw.recipe.boiler.energy_required,
	},
	{
		type = "furnace",
		name = "iron-ice-melter",
		source_inventory_size = 1,
		result_inventory_size = 0, -- No item results. Game automatically adds 2 slots for the fluids.
		energy_usage = "1MW", -- For comparison, electric boiler is 1.25MW, copper boiler is 300kW.
		energy_source = Table.copyAndEdit(data.raw.boiler.boiler.energy_source, {
			fuel_inventory_size = 2,
			burnt_inventory_size = 2,
			fuel_categories = {"chemical", "coke", "canister", "barrel"},
		}),
		crafting_speed = 4,
		crafting_categories = {"ice-melting"},
		icons = ironMelterIcons,
		flags = data.raw.boiler.boiler.flags,
		collision_box = data.raw.boiler.boiler.collision_box,
		selection_box = data.raw.boiler.boiler.selection_box,
		drawing_box = data.raw.boiler.boiler.drawing_box,
		vehicle_impact_sound = data.raw.boiler.boiler.vehicle_impact_sound,
		open_sound = data.raw.boiler.boiler.open_sound,
		close_sound = data.raw.boiler.boiler.close_sound,
		working_sound = data.raw.boiler.boiler.working_sound,
		max_health = data.raw.boiler.boiler.max_health,
		resistances = data.raw.boiler.boiler.resistances,
		fluid_boxes = {
			{
				base_area = 1,
				height = 2,
				base_level = 1,
				pipe_covers = data.raw.boiler.boiler.fluid_box.pipe_covers,
				pipe_connections =
					{ -- Seems like they must be input/output, not "input-output", for crafting machines, including furnaces. No passthrough.
						{type = "output", position = {-2, 0.5}},
						{type = "output", position = {2, 0.5}}
					},
				production_type = "output",
				filter = "water"
			},
			{
				base_area = 1,
				height = 2,
				base_level = 1,
				pipe_covers = data.raw.boiler.boiler.fluid_box.pipe_covers,
				pipe_connections = { {type = "output", position = {0, -1.5}} },
				production_type = "output",
				filter = "steam"
			},
		},
		minable = {
			mining_time = data.raw.boiler.boiler.minable.mining_time,
			results = {{"iron-ice-melter", 1}}
		},
		animation = {
			north = data.raw.boiler.boiler.structure.north,
			east = data.raw.boiler.boiler.structure.east,
			south = data.raw.boiler.boiler.structure.south,
			west = data.raw.boiler.boiler.structure.west,
		},
		working_visualisations = { -- Show fire on top of the boiler when it's working.
			{
				north_animation = data.raw.boiler.boiler.fire.north,
				east_animation = data.raw.boiler.boiler.fire.east,
				south_animation = data.raw.boiler.boiler.fire.south,
				west_animation = data.raw.boiler.boiler.fire.west,
				render_layer = "object",
				fadeout = true,
			},
		},
	},
})

-- Add recipes to techs.
local Tech = require("code.util.tech")
Tech.addRecipeToTech("copper-ice-melter", "ir-copper-working-2", 8)
Tech.addRecipeToTech("melt-ice-to-water-and-steam", "ir-copper-working-2", 9)
Tech.addRecipeToTech("iron-ice-melter", "ir-steam-power", 3) -- This is the electricity tech.
Tech.addRecipeToTech("electric-ice-melter", "ir-steam-power", 4)