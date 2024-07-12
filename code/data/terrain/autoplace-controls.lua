data:extend{
	{ -- Create autoplace control for overall scale - so that I can more easily see distant islands while debugging.
		-- TODO rather just use the built-in water scale setting for this.
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