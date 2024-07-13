-- We want to make it so that mining ores produces that ore, but also ice and stone.
-- Then add recipes to discard ice and stone.
-- Also, elsewhere we'll change stone ore patches so that they don't occur in the starting area, but there is one on the starting island, and all stone patches have extremely high richness, so it's not a problem to discard stone.

-- We could make each mining round output like 2x ore, 1x stone, 1x ice. However, that makes the miners get stuck outputting their ores. So rather use probabilities.

-- Create ice item
data:extend({{
	type = "item",
	name = "ice",
	icon = "__Desolation__/graphics/ice.png",
	icon_size = 64,
	subgroup = "ore",
	order = "aa-bb",
	stack_size = data.raw.item["stone"].stack_size,
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
	{type = "item", name = "stone", probability = 1/2, amount = 1},
	{type = "item", name = "ice", probability = 1/2, amount = 1},
}
-- data.raw.resource["stone"].minable.mining_time = data.raw.resource["stone"].minable.mining_time * 3
