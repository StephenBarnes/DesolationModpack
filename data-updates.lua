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

require("code.data.tweaks.stack-sizes") -- Seems some other mod is adjusting stack sizes, eg setting ingot stack sizes to 50. So this can't be in data.lua.
-- Note this needs to be before the containerization mod creates its recipes, I think.