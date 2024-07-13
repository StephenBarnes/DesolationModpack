data.raw["map-gen-presets"]["default"]["Desolation"] = {
    order = "Desolation",
    basic_settings = {
        property_expression_names = {
			--["control-setting:moisture:bias"] = 0.05, -- Moisture bias
			--["control-setting:aux:bias"] = -0.35, -- Terrain bias

            -- Use the custom noise expression for elevation.
            elevation = "Desolation-islands-elevation",
		},
        autoplace_controls = {
			-- Resources
            coal = {
                frequency = 1,
                size = 1,
                richness = 2,
            },
            ["copper-ore"] = {
                frequency = 1,
                size = 1,
				richness = 0.5,
            },
            ["iron-ore"] = {
                frequency = 1,
                size = 1,
				richness = 0.5,
            },
            ["tin-ore"] = {
                frequency = 1,
                size = 1,
				richness = 0.5,
            },
            ["gold-ore"] = {
                frequency = 6,
                size = 1,
				richness = 0.5,
            },
            stone = {
                frequency = 1,
                size = 1,
				richness = 2,
            },
            ["crude-oil"] = {
                frequency = 6,
                size = 1,
            },
            ["uranium-ore"] = {
                frequency = 6,
                size = 1,
            },
            ["ir-fissures"] = {
                frequency = 1,
                size = 1,
            },

			trees = {
				frequency = 2, -- Inverse of scale
				size = 1/6, -- Coverage
			},
            ["enemy-base"] = {
				frequency = 1/6,
                size = 1,
            },

            -- Desolation scale; using smaller value for debug, increase when releasing.
            ["Desolation-scale"] = {
                frequency = 1, -- Inverse of the "scale" slider. So setting this number higher here makes the island smaller.
            },

			-- Temperature controls for Alien Biomes
			hot = {
				frequency = 4, -- Inverse of scale
				size = 0.5, -- Coverage
			},
			cold = {
				frequency = 4, -- Inverse of scale
				size = 3, -- Coverage
			},

            -- For IR3: minimize rubber trees. Seems I can't actually remove them completely in the mapgen preset.
            -- I'm rather removing the control completely, see rubber-trees-edit.lua.
            --["ir-rubber-trees"] = {
            --    frequency = 1/6,
            --},
        },

        --default_enable_all_autoplace_controls = false,
        -- Wanted to use this to disable rubber trees, but, it seems to cause issues with showing terrain, so rather not using.

        terrain_segmentation = 1, -- Inverse of water scale. Has no effects, rather using custom Desolation-scale autoplace.
        water = 1, -- Water coverage; increasing will hide most of the islands.
    },
    advanced_settings = {
        enemy_evolution = {
            time_factor = 0.0
        },
    }
}