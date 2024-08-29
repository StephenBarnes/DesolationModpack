local Settings = require("code.util.settings")

-- The mod has a setting for the capacity of the loader, which is 320 by default.
-- Since Desolation has a setting for cargo wagon size, we want to set the loader to hold like 2 or 4 wagons' worth.
-- Can't access that setting during settings stage. So instead we hide the setting for the loader here, and then change the capacity in data stage.
Settings.forceSetting("railloader-railloader-capacity", "int", 20)

-- I'm adding and removing categories of allowed items while in control stage. So force-set to ore here.
Settings.forceSetting("railloader-allowed-items", "string", "ore")