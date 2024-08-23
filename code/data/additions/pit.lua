-- Create a "furnace" that can be used to void ice, stone, gravel, sand, scrap, etc.
-- Uses the sprite for IR3's "bottomless pit".

local pitIngredients = {{"stone-brick", 20}}

data:extend({
	{
		type = "recipe-category",
		name = "pit-voiding",
		icons = data.raw.item["bottomless-pit"].icons,
		icon_size = 64,
		icon_mipmaps = 4,
	},
	{
		name = "pit",
		type = "furnace",
		minable = {
			mining_time = 0.5,
			result = "pit",
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
		enabled = false, -- This says, hide it at start of game.
	},
})

local pittableItems = {
	"stone",
	"gravel",
	"silica",
	"stone-brick",
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
	"wood-chips",
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
		icons = data.raw.item["bottomless-pit"].icons,
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "storage", -- This is item subgroup, not recipe subgroup. Usually it would be the main product's subgroup, but there's no product here.
		order = "a",
		results = {},
		energy_required = 0.01,
		localised_name = {"recipe-name.pit-voiding", {"item-name."..itemName}},
	}})
end

local Tech = require("code.util.tech")
Tech.addRecipeToTech("pit", "ir-basic-research")