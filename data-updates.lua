require("code.data.tweaks.loaders-stacking") -- This is in data-updates so ProductionScrapForIR3 can modify it correctly.

require("code.data.additions.ore-compounds")
require("code.data.additions.pit")
require("code.data.additions.ice-melters")
require("code.data.additions.walls")
require("code.data.additions.telemetry")

require("code.data.tweaks.lamps")
require("code.data.tweaks.land-vehicles")
require("code.data.tweaks.cargo-ships")
require("code.data.tweaks.turret-recipes")
require("code.data.tweaks.ammo")

require("code.data.additions.science-packs") -- Must run before data-final-fixes, so we get scrapping and containerization recipes.

require("code.data.additions.endgame-resources") -- Must be in data-updates, not data, bc IR3 space mining mod only creates the techs in data-updates.

require("code.data.tweaks.container-packing")

local adjustForStage = require("code.data.tweaks.stack-sizes")
adjustForStage("data-updates")