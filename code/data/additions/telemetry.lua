-- This file adds the telemetry tech.
-- Originally I also added a "telemetry unit" item, but I think rather don't do that, just use computers for the ingredients. Because they'll mostly be ingredients for rarely-produced items (radars, vehicles), and because I don't want people to need green circuits to make late-game stuff like airships.
-- So, telemetry is an extra tech, but there's no extra intermediate.

local telemetryTech = {
	type = "technology",
	name = "telemetry",
	icon = "__Desolation__/graphics/telemetry-tech-256-128.png",
	icon_size = 256,
	icon_mipmaps = 2,
	prerequisites = {"ir-electronics-1", "ir-bronze-telescope"},
	effects = { },
	unit = data.raw.technology["ir-radar"].unit, -- TODO
}

data:extend({telemetryTech})