-- This file disables the default rocket victory condition, and creates a new victory condition.
-- Some code taken from Freight Forwarding modpack.

-- Taken from Freight Forwarding.
local function interferingMods()
	return script.active_mods["Krastorio2"] or script.active_mods["SpaceMod"]
end

-- Disable default rocket victory condition. Code taken from Freight Forwarding.
-- I've checked, this works.
local function disableRocketVictory()
	if interferingMods() then return end

	-- Call set_no_victory for every interface that has that function.
	-- For the vanilla game you'd call remote.call("silo_script", "set_no_victory", true) but you need to also call this for eg Better Victory Screen.
	for interface, functions in pairs(remote.interfaces) do
		if (functions["set_no_victory"] ~= nil) then
			remote.call(interface, "set_no_victory", true)
		end
	end
end

return {
	onInit = disableRocketVictory,
	onConfigChanged = disableRocketVictory,
}