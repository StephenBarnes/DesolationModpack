local Settings = require("code.util.settings")
Settings.setDefaultOrForce("Clockwork-evening", "double", 0.35) -- Changed 0.45 -> 0.35 to make night longer.
Settings.setDefaultOrForce("Clockwork-morning", "double", 0.65) -- Changed 0.55 -> 0.65 to make night longer.
Settings.setDefaultOrForce("Clockwork-darknight-percent", "int", 100) -- Changed 0 -> 100 to make night darker.
Settings.setDefaultOrForce("Clockwork-enable-flares", "bool", false)
Settings.setDefaultOrForce("Clockwork-cycle-length", "double", 8) -- Changed 4 -> 8.