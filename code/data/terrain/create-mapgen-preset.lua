data.raw["map-gen-presets"]["default"]["Desolation"] = {
    order = "2001",
    basic_settings = {
        property_expression_names = {
			--["control-setting:moisture:bias"] = 0.05, -- Moisture bias
			--["control-setting:aux:bias"] = -0.35, -- Terrain bias

            -- Use the custom noise expression for elevation.
            elevation = "Desolation-islands-elevation",
            temperature = "Desolation-temperature", -- We use this to decide where to place buildable tiles.
            aux = "Desolation-aux", -- We use this to decide where to place snow vs ice.
            moisture = "Desolation-moisture", -- We use this to decide where to place grass vs volcanic rock.
		},
        autoplace_controls = {
			-- Resources
            -- All of these should have everything set to 1. Rather adjust them in resource-placing.lua, when creating autoplace expressions.
            coal = {
                frequency = 1,
                size = 1,
                richness = 1,
            },
            ["copper-ore"] = {
                frequency = 1,
                size = 1,
				richness = 1,
            },
            ["iron-ore"] = {
                frequency = 1,
                size = 1,
				richness = 1,
            },
            ["tin-ore"] = {
                frequency = 1,
                size = 1,
				richness = 1,
            },
            ["gold-ore"] = {
                frequency = 1,
                size = 1,
				richness = 1,
            },
            stone = {
                frequency = 1,
                size = 1,
				richness = 1,
            },
            ["crude-oil"] = {
                frequency = 1,
                size = 1,
            },
            ["uranium-ore"] = {
                frequency = 1,
                size = 1,
            },
            ["ir-fissures"] = {
                frequency = 1,
                size = 1,
            },

            -- TODO in resource-placing.lua, create custom noise expressions for these, then set these here to 1.
			trees = {
				frequency = 2, -- Inverse of scale
				size = 1/6, -- Coverage
			},
            ["enemy-base"] = {
				frequency = 1/6,
                size = 1,
            },

            -- Desolation scale; using smaller value for debug, increase when releasing.
            --["Desolation-scale"] = {
            --    frequency = 1, -- Inverse of the "scale" slider. So setting this number higher here makes the island smaller.
            --},

			-- Temperature controls for Alien Biomes
            -- TODO in resource-placing.lua, create custom noise expressions for these, then set these here to 1.
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
        cliff_settings = {
            -- I want to disable cliffs, bc (1) the snowy terrain has lakes, and I don't want to make them depend on the divergence of the elevation or whatever (bc it'll be slow), and (2) they interfere with creating ports etc.
            -- This way, I can also just completely disable cliff explosives.
            -- No way to control the checkbox from the mapgen preset, apparently, so rather do this to effectively disable them.
            cliff_elevation_0 = 100000,
        },

        --default_enable_all_autoplace_controls = false,
        -- Wanted to use this to disable rubber trees, but, it seems to cause issues with showing terrain, so rather not using.

        --terrain_segmentation = 1/3, -- Inverse of water scale.
            -- Using a default setting of 1/3 for 300% scale, not 100%, because I want to be able to see surrounding islands from map-gen view.
        --water = 1, -- Water coverage; increasing will hide most of the islands, decreasing will connect them more.

        -- For debugging, TODO remove:
        terrain_segmentation = 3,
        water = 1/3,
    },
    advanced_settings = {
        enemy_evolution = {
            time_factor = 0.0
        },
    }
}