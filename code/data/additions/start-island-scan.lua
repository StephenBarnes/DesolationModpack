-- Data-stage changes for the start island scan.
-- The code for the actual scanning is in control/start-island-scan.lua.

table.insert(data.raw.technology["ir-bronze-telescope"].effects, {
	type = "nothing",
	recipe = "start-island-scan",
	effect_description = {"effect-description.start-island-scan"},
	icon = "__core__/graphics/gps-map-placeholder.png",
	icon_size = 32,
	icon_mipmaps = 1,
})