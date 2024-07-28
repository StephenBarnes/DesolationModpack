local Settings = require("code.util.settings")

-- Disable the offshore oil and oil rig, bc our progression is rather built on island-hopping.
-- Also, if this is enabled, it silently deletes all crude oil on land.
Settings.forceSetting("deep_oil", "bool", false)