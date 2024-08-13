local Settings = require("code.util.settings")

Settings.setDefaultOrForce("ir-ghost-tint", "string", "blue") -- Tint ghosts blue, not white, bc the terrain is mostly white snow.

Settings.setDefaultOrForce("ir-bottomless-pit", "string", "notavailable")

--Settings.setDefaultOrForce("ir-starting-age", "string", "none") -- Don't start with ammo, miner, blunderbuss.
-- This crashes if Inspiration is enabled, bc it changes the allowed values or something.