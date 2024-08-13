-- Adjust default settings of Alien Biomes.
-- Basically I want to keep only the icy/snowy biomes, and some cold grassland biomes. Removing all desert / jungle / swamp / etc. biomes.

local toDisable = {
	"dirt-aubergine",
	"dirt-beige",
	"dirt-black",
	"dirt-brown",
	"dirt-cream",
	"dirt-dustyrose",
	"dirt-grey",
	"dirt-purple",
	"dirt-red",
	"dirt-tan",
	"dirt-violet",
	"dirt-white",
	"grass-blue",
	"grass-green",
	"grass-mauve",
	"grass-olive",
	"grass-orange",
	"grass-purple",
	"grass-red",
	"grass-violet",
	"grass-yellow",
	"sand-aubergine",
	"sand-beige",
	"sand-black",
	"sand-brown",
	"sand-cream",
	"sand-dustyrose",
	"sand-grey",
	"sand-purple",
	"sand-red",
	"sand-tan",
	"sand-violet",
	"sand-white",
	"volcanic-blue",
	"volcanic-green",
	"volcanic-purple",

	"inland-shallows",
}

local toEnable = {
	"frozen",
	"grass-turquoise",
	"volcanic-orange",
}

local U = require("code/util/settings")

-- We need to force enable/disable tiles, bc we want to define the tile autoplaces.
for _, v in pairs(toDisable) do
	U.setDefaultOrForce("alien-biomes-include-"..v, "string", "Disabled")
end
for _, v in pairs(toEnable) do
	U.setDefaultOrForce("alien-biomes-include-"..v, "string", "Enabled")
end

-- Also enable removing obsolete tiles.
U.setDefaultOrForce("alien-biomes-remove-obsolete-tiles", "string", "Enabled")