-- This file adds packing recipes for items that can't be handled by the normal method of setting item.ic_create_container.

-- The Intermodal Containers mod only creates containers for things in types "item", "ammo", "tool".
-- So, it doesn't create packing recipes for several item subclasses, namely: capsule, module, repair-tool, gun, rail-planner, and some others I don't care about.
-- It doesn't create containers for those even if you set ic_create_container to true.
-- So, we have to separately do that as well, e.g. for grenades, medical packs, etc.

local Table = require("code.util.table")

local typesForPacking = {
	"capsule",
	"module",
	"repair-tool",
}
local excludeItemNames = Table.listToSet{
	"ln-flare-capsule", -- Flare capsule from Clockwork, which I'm disabling.
	"artillery-targeting-remote",
	"discharge-defense-remote",
}

local IC = require "copied-shared"
for _, type in pairs(typesForPacking) do
	for _, item in pairs(data.raw[type]) do
		if not excludeItemNames[item.name] then
			IC.generate_crates(item.name, type)
		end
	end
end
IC.generate_crates("rail", "rail-planner") -- Railways