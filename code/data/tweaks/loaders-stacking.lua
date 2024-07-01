
-- For IR3 Loaders and Stacking mod
------------------------------------------------------------------------
-- From this mod, we're only using the beltboxes, not the loaders.
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

-- For AAI Loaders
------------------------------------------------------------------------

-- For this mod, we have 3 loaders. All 3 require lubricant.
-- Where should they go in the tech tree? After lubricant obviously, but other than that they could go anywhere.
-- Don't pay attention to their ingredients, since we can easily change those.
-- Ok, so, here's my idea: you get logistics 1, then lubricant, then logistics 2 (red belts), then logistics 3 (blue belts).
-- (This requires making logistics 2 depend on lubricant, which is actually fine, you just don't get red belts until a bit later. Again, IR3 changes progression so things like cars don't depend on logistics 2.)
-- Then just attach the loaders respectively to lubricant, logistics 2, logistics 3.
-- And change their recipes to use the corresponding belt, plus other components guaranteed discovered by that point.
-- So the first loader 


-- The first loader only requires basic iron tech, and lubricant. Lubricant is unlocked pretty early. So, just put it as part of the lubricant tech.
-- The second "fast" loader needs red engines, red circuits

Tech.addRecipeToTech("aai-loader", "lubricant")
Tech.hideTech("aai-loader")

Tech.addRecipeToTech("aai-fast-loader", "logistics-2")
Tech.hideTech("aai-fast-loader")

Tech.addRecipeToTech("aai-express-loader", "logistics-3")
Tech.hideTech("aai-express-loader")

Tech.setPrereqs("logistics-2", {"lubricant"}) -- This adds lubricant as prereq, and also removes automation-2 and circuits-1 as prereqs (which is good, because they're already needed for lubricant).
Tech.copyCosts("lubricant", "logistics-2") -- We don't want logistics 2 (after lubricant) to cost much less than lubricant.

-- Set ingredients TODO