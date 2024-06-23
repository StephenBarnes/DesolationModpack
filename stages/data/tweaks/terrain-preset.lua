data.raw["map-gen-presets"]["default"]["Desolation"] = {
    order = "__",
    basic_settings = {
        property_expression_names = {
			--["control-setting:moisture:bias"] = 0.05, -- Moisture bias
			--["control-setting:aux:bias"] = -0.35, -- Terrain bias
		},
        autoplace_controls = {
			-- Temperature controls for Alien Biomes
			hot = {
				frequency = 2, -- Inverse of scale
				size = 0.5, -- Coverage
			},
			cold = {
				frequency = 2, -- Inverse of scale
				size = 4, -- Coverage
			},

			-- Resources
            coal = {
                frequency = 1/6,
                size = 1,
            },
            ["copper-ore"] = {
                frequency = 1/6,
                size = 1,
				richness = 0.5,
            },
            ["iron-ore"] = {
                frequency = 1/6,
                size = 1,
				richness = 0.5,
            },
            ["tin-ore"] = {
                frequency = 1/6,
                size = 1,
				richness = 0.5,
            },
            ["gold-ore"] = {
                frequency = 1/6,
                size = 1,
				richness = 0.5,
            },
            stone = {
                frequency = 1/6,
                size = 1,
				richness = 2,
            },
            ["crude-oil"] = {
                frequency = 1/6,
                size = 1,
            },
            ["uranium-ore"] = {
                frequency = 1/6,
                size = 1,
            },
            ["ir-fissures"] = {
                frequency = 1/3,
                size = 1,
            },
			trees = {
				frequency = 2, -- Inverse of scale
				size = 1/6, -- Coverage
			},
            ["enemy-base"] = {
				frequency = 1/6,
                size = 1
            },
        },
        terrain_segmentation = 1/3, -- Inverse of water scale
        water = 6, -- Water coverage
    },
    advanced_settings = {
        enemy_evolution = {
            time_factor = 0.0
        },
    }
}