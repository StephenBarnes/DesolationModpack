data:extend{
	{ -- Create autoplace control for scale. Not using water scale, bc it's annoying to make that also scale resource patches.
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
}