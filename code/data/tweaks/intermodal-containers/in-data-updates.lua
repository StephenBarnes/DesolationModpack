-- This file adjusts how the packing recipes from the Intermodal Containers mod work.

------------------------------------------------------------------------
-- This section sets certain items to be packable or non-packable for the Intermodal Containers mod.
-- That mod already forbids packing if an item is placable, equipment-placable, in "barrel" subgroup, and some other conditions.
--   So this file is just to override those conditions in some cases.

local forbidPacking = {
	"splitter-blocker",
	"satellite",
	"solar-assembly",
	"quantum-satellite",
	"empty-barrel",

	-- With tools like science packs or ammo, there's a bit of an exploit where we could partially use up one, then pack and unpack to get that durability back.
	-- We could make that impossible by forbidding packing for those. But I don't think it's enough of a concern to justify that.
}
local allowPacking = {
}

local function forcePackability(itemSpecifier, val)
	local itemType
	local itemName
	if type(itemSpecifier) == "string" then
		itemType = "item"
		itemName = itemSpecifier
	else
		itemType = itemSpecifier[1]
		itemName = itemSpecifier[2]
	end

	data.raw[itemType][itemName].ic_create_container = val
end

for _, itemSpecifier in pairs(forbidPacking) do
	forcePackability(itemSpecifier, false)
end
for _, itemSpecifier in pairs(allowPacking) do
	forcePackability(itemSpecifier, true)
end

------------------------------------------------------------------------
-- This section adds packing recipes for items that can't be handled by the method above.
-- The Intermodal Containers mod only creates containers for things in types "item", "ammo", "tool".
-- So, doesn't create packing recipes for several item subclasses, namely: capsule, module, repair-tool, gun, rail-planner, and some others I don't care about.
-- It doesn't create containers for those even if you set ic_create_container to true.
-- So, we have to separately do that as well, e.g. for grenades.

-- TODO
-- At least for grenades, medical packs, etc.
-- Probably use the IC.generate_crates function, or something similar.

------------------------------------------------------------------------
-- Handle packing and unpacking of bundles.
-- Specifically:
-- * We mark all bundle items so the IC mod doesn't create containers for them. There should be no "container of bundles" items.
-- * We add a recipe to pack bundled ingots, producing a container of the ingots, not a container of bundled ingots.
-- * We add an unpacking recipe for ingots, which produces bundled ingots. So when the player unpacks a container of ingots, they can choose whether to get ingots or bundled ingots.
-- These last 2 points are moved to the data-final-fixes stage, so we can copy existing recipes.

local bundleItems = require("code.common.bundle-items")

-- Mark all bundle items so the IC mod doesn't create separate containers for them.
for _, itemId in pairs(bundleItems) do
	local bundleItemID = "stacked-"..itemId
	---@diagnostic disable-next-line: inject-field
	data.raw.item[bundleItemID].ic_create_container = false
end