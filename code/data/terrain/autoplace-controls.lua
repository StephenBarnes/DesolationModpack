data:extend{
	{ -- Create autoplace control for scale.
		-- Not using water scale, bc that's for the scale of the water, not also the resources etc.
		type = "autoplace-control",
		name = "Desolation-scale",
		richness = false,
		order = "a1",
		can_be_disabled = false,
		category = "terrain",
	},
	{ -- Create autoplace control for roughness.
		-- TODO this isn't implemented.
		type = "autoplace-control",
		name = "Desolation-roughness",
		richness = false,
		order = "a2",
		can_be_disabled = false,
		category = "terrain",
	},
	{
		type = "autoplace-control",
		name = "Desolation-iron-arc",
		richness = false,
		order = "a3",
		can_be_disabled = true,
		category = "terrain",
	},
	{
		type = "autoplace-control",
		name = "Desolation-iron-blob",
		richness = false,
		order = "a4",
		can_be_disabled = true,
		category = "terrain",
	},
}