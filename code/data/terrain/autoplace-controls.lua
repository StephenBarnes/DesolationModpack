-- I'm creating a lot of autoplace controls here, mostly not for users to fiddle with, but rather so that I can fine-tune what values to use.
-- We use a startup setting to enable/disable these, for performance.

local Settings = require("code.util.settings")

if Settings.startupSetting("complex-sliders") then
	local nextOrder = 0
	local function getNextOrderString()
		nextOrder = nextOrder + 1
		return string.format("a%02d", nextOrder)
	end

	local newAutoplaceControlNames = {
		"Desolation-scale",
			-- For overall terrain scale.
			-- Not using water scale, bc that's for the scale of the water, not also the resources etc.
			-- TODO maybe remove this, rather just use the water scale.

		"Desolation-startisland-noise",
		"Desolation-temperature",
		"Desolation-aux",
		"Desolation-moisture",

		"Desolation-otherisland-elevation-noise",

		"Desolation-surrounding-islands-toggle",

		"Desolation-start-island-oasis-noise",
		"Desolation-spawn-oasis-rad",

		"Desolation-coppertin-oasis-rad",

		"Desolation-arcblob-noise",

		"Desolation-iron-arc",
		"Desolation-iron-blob",
		"Desolation-coppertin-arc",
		"Desolation-coppertin-blob",

		"Desolation-resource-noise",

		"Desolation-iron-patch",
		"Desolation-iron-prob-center-weight",

		"Desolation-second-coal-patch",
		"Desolation-second-coal-prob-center-weight",
	}

	local newAutoplaceControls = {}
	for _, name in pairs(newAutoplaceControlNames) do
		table.insert(newAutoplaceControls, {
			type = "autoplace-control",
			name = name,
			richness = false,
			order = getNextOrderString(),
			can_be_disabled = true,
			category = "terrain",
		})
	end
	data:extend(newAutoplaceControls)
end