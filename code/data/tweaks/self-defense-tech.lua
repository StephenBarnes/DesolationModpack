-- Change blunderbuss tech to self-defense tech, and then add light armor to it.
local Tech = require("code.util.tech")
Tech.addRecipeToTech("light-armor", "ir-blunderbuss")
Tech.removeRecipeFromTech("light-armor", "ir-tin-working-2")