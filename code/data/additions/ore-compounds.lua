-- We want to make it so that mining ores produces that ore, but also ice and stone.
-- Then add recipes to discard ice and stone.
-- Also, elsewhere we'll change stone ore patches so that they don't occur in the starting area, but there is one on the starting island, and all stone patches have extremely high richness, so it's not a problem to discard stone.

-- We could make each mining round output like 2x ore, 1x stone, 1x ice. However, that makes the miners get stuck outputting their ores. So rather use probabilities.

-- Create ice item
-- Pictures are vanilla Factorio's icons for uranium-ore, but colorized and with a color-to-alpha filter to make them partially transparent.
data:extend({{
	type = "item",
	name = "ice",
	icon = "__Desolation__/graphics/ice/ice.png",
	icon_size = 64,
	icon_mipmaps = 4,
	subgroup = "ore",
	order = "aa-bb",
	stack_size = data.raw.item["stone"].stack_size,
	pictures = { -- Multiple pictures, to make it not look so uniform on the belts.
		{ filename = "__Desolation__/graphics/ice/ice.png", size = 64, scale = 0.25, mipmap_count = 4 },
		{ filename = "__Desolation__/graphics/ice/ice-1.png", size = 64, scale = 0.25, mipmap_count = 4 },
		{ filename = "__Desolation__/graphics/ice/ice-2.png", size = 64, scale = 0.25, mipmap_count = 4 },
		{ filename = "__Desolation__/graphics/ice/ice-3.png", size = 64, scale = 0.25, mipmap_count = 4 },
	}
}})

-- Adjust ores so that they also produce ice and stone.
for _, resourceName in pairs({"iron-ore", "copper-ore", "tin-ore", "coal"}) do
	data.raw.resource[resourceName].minable.results = {
		{type = "item", name = resourceName, probability = 1/2, amount = 1},
		{type = "item", name = "stone", probability = 1/4, amount = 1},
		{type = "item", name = "ice", probability = 1/4, amount = 1},
	}
	-- Increase mining time?
	-- data.raw.resource[resourceName].minable.mining_time = data.raw.resource[resourceName].minable.mining_time * 5
end

data.raw.resource["stone"].minable.results = {
	{type = "item", name = "stone", probability = 3/4, amount = 1},
	{type = "item", name = "ice", probability = 1/4, amount = 1},
}
-- data.raw.resource["stone"].minable.mining_time = data.raw.resource["stone"].minable.mining_time * 3
