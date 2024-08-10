-- This file sets custom intro message. Code taken from Freight Forwarding modpack.

local function onInit()
	if remote.interfaces["freeplay"] and remote.interfaces["freeplay"]["set_custom_intro_message"] then
		remote.call("freeplay", "set_custom_intro_message", {"Desolation-message.freeplay-intro-message"})
	end
end

return {
	onInit = onInit,
}