local nextOrder = 0
local function getNextOrderString()
    nextOrder = nextOrder + 1
    return string.format("a%02d", nextOrder)
end

data:extend{
	{ -- Create autoplace control for scale.
		-- Not using water scale, bc that's for the scale of the water, not also the resources etc.
		-- TODO maybe remove this, rather just use the water scale.
		type = "autoplace-control",
		name = "Desolation-scale",
		richness = false,
		order = getNextOrderString(),
		can_be_disabled = false,
		category = "terrain",
	},
	-- TODO create autoplaces for the starting island.
	{
		type = "autoplace-control",
		name = "Desolation-iron-arc",
		richness = false,
		order = getNextOrderString(),
		can_be_disabled = true,
		category = "terrain",
	},
	{
		type = "autoplace-control",
		name = "Desolation-iron-blob",
		richness = false,
		order = getNextOrderString(),
		can_be_disabled = true,
		category = "terrain",
	},
	{
		type = "autoplace-control",
		name = "Desolation-iron-arcblob-noise",
		richness = false,
		order = getNextOrderString(),
		can_be_disabled = false,
		category = "terrain",
	},
}