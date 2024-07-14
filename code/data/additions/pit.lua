-- Create a "furnace" that can be used to void ice, stone, gravel, silica, scrap, maybe more.
-- Use the images for IR3's "bottomless pit".
-- TODO add this to the set of machines that allow unlubricated loaders. And explain that in the descriptions.

local pitIngredients = {{"stone-brick", 40}}

data:extend({
	{
		type = "recipe-category",
		name = "pit-voiding",
	},
	{
		name = "pit",
		type = "furnace",
		minable = {
			mining_time = data.raw["infinity-container"]["bottomless-pit"].minable.mining_time,
			results = pitIngredients,
		},
		source_inventory_size = 1,
		result_inventory_size = 0,
		icons = data.raw.item["bottomless-pit"].icons,
		icon = data.raw.item["bottomless-pit"].icon,
		icon_size = data.raw.item["bottomless-pit"].icon_size,
		energy_usage = "100kW", -- Determines how long crafting recipes take, I think.
		energy_source = { type = "void" },
		flags = {"placeable-neutral", "player-creation"},
		crafting_categories = {"pit-voiding"},
		crafting_speed = 1,
		collision_box = data.raw["infinity-container"]["bottomless-pit"].collision_box,
		selection_box = data.raw["infinity-container"]["bottomless-pit"].selection_box,
		drawing_box = data.raw["infinity-container"]["bottomless-pit"].drawing_box,
		--placeable_by = {item = "pit", count = 1},
		corpse = data.raw["infinity-container"]["bottomless-pit"].corpse,
		max_health = data.raw["infinity-container"]["bottomless-pit"].max_health,
		mined_sound = data.raw.furnace["stone-furnace"].mined_sound,
		vehicle_impact_sound = data.raw.furnace["stone-furnace"].vehicle_impact_sound,
		resistances = data.raw.furnace["stone-furnace"].resistances,
		picture = data.raw["infinity-container"]["bottomless-pit"].picture,
		-- The pit is invisible if we just use the same picture and animation as the bottomless-pit.
		-- Seems that furnaces have to play animation, while containers (like bottomless-pit) don't.
		animation = {
			layers = {
				{
					filename = "__IndustrialRevolution3Assets3__/graphics/entities/machines/storage/bottomless-pit-base.png",
					priority = "high",
					width = 64,
					height = 64,
					animation_speed = 1,
					draw_as_glow = false,
					draw_as_light = false,
					draw_as_shadow = false,
					scale = 0.5,
					shift = {0, 0},
					x = 0,
					y = 0,
					frame_count = 1,
				},
				{
					filename = "__IndustrialRevolution3Assets3__/graphics/entities/machines/storage/bottomless-pit-shadow.png",
					priority = "high",
					height = 64,
					width = 64,
					animation_speed = 1,
					draw_as_glow = false,
					draw_as_light = false,
					draw_as_shadow = true,
					scale = 0.5,
					shift = {0.25, 0},
					x = 0,
					y = 0,
				},
			}
		},
	},
	{
		type = "item",
		name = "pit",
		icons = data.raw.item["bottomless-pit"].icons,
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "storage",
		order = "a",
		stack_size = 1,
		place_result = "pit",
	},
	{
		type = "recipe",
		name = "pit",
		icons = data.raw.item["bottomless-pit"].icons,
		icon_size = 64,
		icon_mipmaps = 4,
		group = "crafting",
		order = "zc",
		ingredients = pitIngredients,
		result = "pit",
		result_count = 1,
		energy_required = 2,
		enabled = true,
	},
})

local pittableItems = {
	"stone",
	"gravel",
	"silica",
	"ice",
	"copper-scrap",
	"tin-scrap",
	"copper-scrap",
	"bronze-scrap",
	"concrete-scrap",
	"gold-scrap",
	"lead-scrap",
	"steel-scrap",
	"brass-scrap",
	"glass-scrap",
}
for _, itemName in pairs(pittableItems) do
	data:extend({{
		type = "recipe",
		name = "pit-voiding-"..itemName,
		category = "pit-voiding",
		ingredients = {{itemName, 1}},
		enabled = true,
		hide_from_player_crafting = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
		allow_intermediates = false,
		icon = data.raw.item[itemName].icon,
		icon_size = data.raw.item[itemName].icon_size,
		icon_mipmaps = data.raw.item[itemName].icon_mipmaps,
		subgroup = "storage", -- This is item subgroup, not recipe subgroup. Usually it would be the main product's subgroup, but there's no product here.
		order = "a",
		results = {},
		energy_required = 0.01,
	}})
	-- TODO add recipes for scrap
end

-- TODO force-set the IR3 runtime-global setting for the bottomless pit, to disable it.

-- TODO add pit to the stone tech