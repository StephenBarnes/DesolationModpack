-- This file tweaks the health and resistances of vehicles.

data.raw.car["heavy-roller"].max_health = 2000 -- originally 700
data.raw.car["heavy-roller"].resistances = {
	{ type = "acid", decrease = 0, percent = 50 },
	{ type = "explosion", decrease = 10, percent = 75 },
	{ type = "fire", decrease = 0, percent = 75 },
	{ type = "impact", decrease = 0, percent = 90 },
	{ type = "physical", decrease = 1, percent = 50 },
}

data.raw.car["heavy-picket"].max_health = 4000 -- originally 3000
data.raw.car["heavy-picket"].resistances = {
	{ type = "acid", decrease = 0, percent = 90 },
	{ type = "explosion", decrease = 10, percent = 75 },
	{ type = "fire", decrease = 0, percent = 75 },
	{ type = "impact", decrease = 0, percent = 100 },
	{ type = "physical", decrease = 3, percent = 50 },
}

data.raw.car["monowheel"].max_health = 500 -- originally 250
data.raw.car["monowheel"].resistances = {
	{ type = "fire", decrease = 0, percent = 75 }, -- originally 0, 75
	{ type = "impact", decrease = 0, percent = 60 }, -- originally 0, 25; increasing so it's not so easy to wreck, especially since I'm increasing its speed.
}