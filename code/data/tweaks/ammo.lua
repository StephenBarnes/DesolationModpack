-- In default IR3, every shotgun cartridge has mag size 10, stack size 100.
-- In default IR3, every submachine gun cartridge has mag size 10, stack size 100.

-- I want to reduce the stack size dramatically, so that you basically have to have a belt feeding turrets.
-- I also want to reduce the mag sizes of shotgun cartridges, bc they currently last very long.

-- Note that the stack sizes are instead set in common/stack-sizes.lua and then used in data/tweaks/stack-sizes.lua.
-- So this file is only doing mag size.

local shotgunCartridgeItems = {
	"shotgun-shell", -- This is the normal copper cartridge.
	"bronze-cartridge",
	"iron-cartridge",
	"piercing-shotgun-shell", -- This is the steel cartridge.
}

for _, shotgunCartridgeItem in pairs(shotgunCartridgeItems) do
	data.raw.ammo[shotgunCartridgeItem].magazine_size = 5
end