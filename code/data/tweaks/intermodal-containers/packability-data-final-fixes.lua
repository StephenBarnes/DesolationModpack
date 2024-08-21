-- This file adds packing recipes for items that can't be handled by the normal method of setting item.ic_create_container.

-- The Intermodal Containers mod only creates containers for things in types "item", "ammo", "tool".
-- So, it doesn't create packing recipes for several item subclasses, namely: capsule, module, repair-tool, gun, rail-planner, and some others I don't care about.
-- It doesn't create containers for those even if you set ic_create_container to true.
-- So, we have to separately do that as well, e.g. for grenades, medical packs, etc.

local Table = require("code.util.table")
local IC = require "copied-shared"

local typesForPacking = {
	"capsule",
	"module",
	"repair-tool",
	"rail-planner",
}
local excludeItemNames = Table.listToSet{
	"ln-flare-capsule", -- Flare capsule from Clockwork, which I'm disabling.
	"artillery-targeting-remote",
	"discharge-defense-remote",
	"cliff-explosives", -- No cliffs.
	"waterway",
}

for _, type in pairs(typesForPacking) do
	for _, item in pairs(data.raw[type]) do
		if not excludeItemNames[item.name] then
			IC.generate_crates(item.name, type)
		end
	end
end

-- Create packing recipes for some placeable items.
-- We could do this in data-updates, by setting item.ic_create_container = true, but that would use IC's version of IC.generate_crates, which has an issue when dealing with items with multiple icons. I've fixed that in the version here, so rather use that, instead of using IC's version and then fixing the icons.
local entitiesToAllowPacking = {
	"transport-belt", "fast-transport-belt", "express-transport-belt",
	"underground-belt", "fast-underground-belt", "express-underground-belt",
	"small-bronze-pole", "small-iron-pole", "medium-electric-pole", -- "small-electric-pole" is disabled. "medium-electric-pole" is actually small steel pole.
	"copper-pipe", "steam-pipe", "pipe", "air-pipe",
	"copper-pipe-to-ground", "steam-pipe-to-ground", "pipe-to-ground", "air-pipe-to-ground",
	"copper-pipe-to-ground-short", "steam-pipe-to-ground-short", "pipe-to-ground-short", "air-pipe-to-ground-short",
	"burner-inserter", "steam-inserter", "inserter", "slow-filter-inserter", "fast-inserter", "filter-inserter", "stack-inserter", "stack-filter-inserter",
	"deadlock-copper-lamp", "copper-aetheric-lamp-straight", "small-lamp", "deadlock-large-lamp", "deadlock-floor-lamp",
	"rail-signal", "rail-chain-signal",
	"land-mine",
	"stone-wall", "concrete-wall", "steel-plate-wall", "gate",
	"construction-robot", "logistic-robot", "steambot",
}
for _, entityName in pairs(entitiesToAllowPacking) do
	IC.generate_crates(entityName)
end

-- Fix localised names of the packable placeable items, bc IC expects them to be item-name.transport-belt instead of entity-name.transport-belt, etc.
local specialReplacements = {
	["copper-aetheric-lamp-straight"] = "entity-name.copper-aetheric-lamp",
}
local function replaceName(itemName, replacement)
	data.raw.item["ic-container-"..itemName].localised_name[3] = replacement
	data.raw.recipe["ic-load-"..itemName].localised_name[2] = replacement
	data.raw.recipe["ic-unload-"..itemName].localised_name[2] = replacement
end
for _, entityName in pairs(entitiesToAllowPacking) do
	local replacement = specialReplacements[entityName] or ("entity-name."..entityName)
	replaceName(entityName, {replacement})
end