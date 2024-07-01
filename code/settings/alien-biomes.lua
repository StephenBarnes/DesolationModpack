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
	--"frozen",
	"grass-blue",
	"grass-green",
	"grass-mauve",
	"grass-olive",
	"grass-orange",
	"grass-purple",
	"grass-red",
	--"grass-turquoise",
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
	--"volcanic-orange",
	"volcanic-purple",

	"inland-shallows",
}

for _, v in pairs(toDisable) do
	data.raw["string-setting"]["alien-biomes-include-"..v].default_value = "Disabled"
end

-- Also enable removing obsolete tiles.
data.raw["string-setting"]["alien-biomes-remove-obsolete-tiles"].default_value = "Enabled"