local Settings = require("code.util.settings")

-- Disable the offshore oil and oil rig, bc our progression is rather built on island-hopping.
-- Force-set and hide this setting, ignoring globalParams.forceSettings. Because if this is enabled, it silently deletes all crude oil on land.
Settings.forceSetting("deep_oil", "bool", false)