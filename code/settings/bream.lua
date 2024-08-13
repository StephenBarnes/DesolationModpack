-- Make electric poles military targets. Like Power Overload, this heavily discourages connecting outposts into one electric network, encouraging local power generation.
local Settings = require("code.util.settings")
Settings.setDefaultOrForce("BREAM-safety-power-poles", "string", "military-target")
Settings.setDefaultOrForce("BREAM-lamp-safety-factor", "double", 1.6)