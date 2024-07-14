-- Groups of trees where we want to set them to produce 8 wood and also change their names to just "tree".
-- This is basically all of the custom trees that Alien Biomes adds.
local treeFor8Groups = {
	wetland = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o"},
	grassland = {"a", "b", "c", "d", "e", "f", "g", "h", "h2", "h3", "i", "j", "k", "l", "m", "n", "o", "p", "q"},
	dryland = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o"},
	desert = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n"},
	snow = {"a"},
	volcanic = {"a"},
}

-- Increase the wood from mining trees, bc wood is scarce.
for a, bList in pairs(treeFor8Groups) do
	for _, b in pairs(bList) do
		data.raw.tree["tree-"..a.."-"..b].minable.count = 8
	end
end
data.raw.tree["dry-hairy-tree"].minable.count = 8
data.raw.tree["dead-dry-hairy-tree"].minable.count = 8 -- 2 -> 8.
data.raw.tree["dry-tree"].minable.count = 2 -- Reduced 4 -> 2.

-- Change names of some trees. We need these bc Alien Biomes sets localised_name to some compound construction like Iceblade + Konifa.
for a, bList in pairs(treeFor8Groups) do
	for _, b in pairs(bList) do
		data.raw.tree["tree-"..a.."-"..b].localised_name = {"entity-name.tree"}
	end
end
data.raw.tree["dry-hairy-tree"].localised_name = {"entity-name.tree"}
data.raw.tree["dead-dry-hairy-tree"].localised_name = {"entity-name.dead-tree"}

-- Disable some trees.
local treeToDisable = {
	"tree-palm-a",
	"tree-palm-b",
	"dead-tree-desert",
	"tree-wetland-k",
	"tree-wetland-l",
	"tree-grassland-d",
	"tree-grassland-e",
	"tree-volcanic-a",
	"tree-desert-m",
}
for _, treeName in pairs(treeToDisable) do
	data.raw.tree[treeName].autoplace = nil
end

-- Reduce frequency of some trees
data.raw.tree["tree-wetland-h"].autoplace.max_probability = 0.05