-- For the IR3 Loaders and Stacking mod, we're only using the beltboxes, not the loaders.
-- We're disabling the loaders via default settings - rather using AAI loaders because they require lubricant.
-- I don't want IR3 beltboxes to have separate techs, rather just put them in a corresponding logistics tech.

local Tech = require("code.util.tech")

Tech.addRecipeToTech("ir3-beltbox-steam", "logistics")
Tech.hideTech("ir3-beltbox-steam")

Tech.addRecipeToTech("ir3-beltbox", "ir-inserters-1")
data.raw.technology["ir-inserters-1"].localised_name = {"technology-name.ir-inserters-1"}
Tech.hideTech("ir3-beltbox")

Tech.addRecipeToTech("ir3-fast-beltbox", "logistics-2")
Tech.hideTech("ir3-fast-beltbox")

Tech.addRecipeToTech("ir3-express-beltbox", "logistics-3")
Tech.hideTech("ir3-express-beltbox")