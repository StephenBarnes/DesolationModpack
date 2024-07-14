-- In default IR3, every shotgun cartridge has mag size 10, stack size 100.
-- In default IR3, every submachine gun cartridge has mag size 10, stack size 100.

-- I want to reduce the stack size dramatically, so that you basically have to have a belt feeding turrets.
-- I also want to reduce the mag sizes of shotgun cartridges, bc they currently last very long.

local shotgunCartridgeItems = {
	"copper-cartridge", -- This is the normal copper cartridge.
	"bronze-cartridge",
	"iron-cartridge",
	"piercing-shotgun-shell", -- This is the steel cartridge.
}
local submachineGunMagazineItems = {
	"firearm-magazine", -- This is the normal iron magazine.
	"piercing-rounds-magazine", -- This is the steel magazine.
	"chromium-magazine",
	"uranium-rounds-magazine",
}

for _, shotgunCartridgeItem in pairs(shotgunCartridgeItems) do
	data.raw.ammo[shotgunCartridgeItem].magazine_size = 5
	data.raw.ammo[shotgunCartridgeItem].stack_size = 10
end
for _, submachineGunMagazineItem in pairs(submachineGunMagazineItems) do
	data.raw.ammo[submachineGunMagazineItem].stack_size = 10
end