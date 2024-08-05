-- Hide recipes for long-handed inserters and the steam variant.
-- This is just to make basic logistics generally more interesting.

local Tech = require("code.util.tech")
local Recipe = require("code.util.recipe")

Tech.removeRecipeFromTech("long-handed-inserter", "ir-inserters-1")
Tech.removeRecipeFromTech("long-handed-steam-inserter", "ir-basic-research")

Recipe.hide("long-handed-inserter")
Recipe.hide("long-handed-steam-inserter")