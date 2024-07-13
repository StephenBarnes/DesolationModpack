data:extend{
	{ -- Create autoplace control for scale.
		-- Not using water scale, bc that's for the scale of the water, not also the resources etc.
		type = "autoplace-control",
		name = "Desolation-scale",
		richness = true,
		order = "a1",
		can_be_disabled = false,
		category = "terrain",
	},
	{ -- Create autoplace control for roughness.
		type = "autoplace-control",
		name = "Desolation-roughness",
		richness = true,
		order = "a2",
		can_be_disabled = false,
		category = "terrain",
	},
	{
		type = "autoplace-control",
		name = "Desolation-iron-arc",
		richness = true,
		order = "a3",
		can_be_disabled = true,
		category = "terrain",
	},
	{
		type = "autoplace-control",
		name = "Desolation-iron-blob",
		richness = true,
		order = "a4",
		can_be_disabled = true,
		category = "terrain",
	},
}