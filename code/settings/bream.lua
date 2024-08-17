-- Make electric poles military targets. Like Power Overload, this heavily discourages connecting outposts into one electric network, encouraging local power generation.
local Settings = require("code.util.settings")
Settings.forceSetting("BREAM-safety-power-poles", "string", "default") -- Rather going to separately implement military-target or invincibility in Desolation.
Settings.setDefaultOrForce("BREAM-safety-lamps", "string", "military-target")
Settings.setDefaultOrForce("BREAM-safety-railways", "string", "never-attack")
Settings.setDefaultOrForce("BREAM-safety-rail-signals", "string", "never-attack")
Settings.setDefaultOrForce("BREAM-lamp-safety-factor", "double", 1.6)