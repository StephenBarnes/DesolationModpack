require("code.data.tweaks.loaders-stacking") -- This is in data-updates so ProductionScrapForIR3 can modify it correctly.

require("code.data.additions.ore-compounds")
require("code.data.additions.pit")
require("code.data.additions.ice-melters")
require("code.data.additions.walls")
require("code.data.additions.telemetry")

require("code.data.tweaks.lamps")
require("code.data.tweaks.turret-recipes")
require("code.data.tweaks.ammo")

require("code.data.additions.science-packs") -- Must run before data-final-fixes, so we get scrapping and containerization recipes.

require("code.data.additions.endgame.techs")
require("code.data.additions.endgame.transmutation")
require("code.data.additions.endgame.resources")

require("code.data.tweaks.intermodal-containers.packability-data-updates")

local adjustForStage = require("code.data.tweaks.stack-sizes")
adjustForStage("data-updates")