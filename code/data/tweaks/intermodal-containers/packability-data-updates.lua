-- This file adjusts how the packing recipes from the Intermodal Containers mod work.
-- It sets certain items to be packable or non-packable for the Intermodal Containers mod.
-- That mod already forbids packing if an item is placable, equipment-placable, in "barrel" subgroup, and some other conditions.
--   So this file is just to override those conditions in some cases.

local forbidPacking = {
	"splitter-blocker",
	"satellite",
	"solar-assembly",
	"quantum-satellite",
	"empty-barrel",
	"long-range-delivery-drone", -- Stack size is 1, so rather forbid it.

	-- With tools like science packs or ammo, there's a bit of an exploit where we could partially use up one, then pack and unpack to get that durability back.
	-- We could make that impossible by forbidding packing for those. But I don't think it's enough of a concern to justify that.
	-- A weaker (non-cyclic) version of this exploit exists in the base game, by converting partially-consumed yellow mags to red mags and then uranium mags or military science packs.
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

	local item = data.raw[itemType][itemName]
	if item == nil then
		log("ERROR: Could not force packability of item "..itemName.." because it doesn't exist.")
	else
		item.ic_create_container = val
	end
end

for _, itemSpecifier in pairs(forbidPacking) do
	forcePackability(itemSpecifier, false)
end
for _, itemSpecifier in pairs(allowPacking) do
	forcePackability(itemSpecifier, true)
end