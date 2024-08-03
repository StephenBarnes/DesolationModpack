-- This file adjusts stack sizes of various groups of items.
-- General philosophy is that items should have higher stack sizes as they get more processed, to incentivise local processing.
-- Also, we want to make it hard to move around things like buildings and vehicles.

-- Define stackSizeGroups, table mapping group name to: {
--    items = {a, b, c},
--    defaultStackSize = d,
-- }
-- Note these are also used in the names of settings.
local stackSizeGroups = {
	raw = {
		defaultStackSize = 20,
		items = {
			"copper-ore", "tin-ore", "gold-ore", "uranium-ore",
			"coal", "stone",
			"wood", "rubber-wood",
		},
	},
	crushed = {
		defaultStackSize = 40,
		items = {
			"copper-crushed", "tin-crushed", "gold-crushed",
			"gravel", "wood-chips",
			"charcoal",
			"carbon-crushed", -- This ID is used for crushed coal.
			"silica",
		},
	},
	purified = {
		defaultStackSize = 60,
		items = {
			"copper-pure", "nickel-pure", "tin-pure", "lead-pure", "iron-pure", "chromium-pure", "gold-pure", "platinum-pure",
			"sulfur",
			"uranium-235", "uranium-238",
			"graphitic-coke",
			"solid-fuel", -- This ID is used for coke.
		},
	},
	processed = {
		defaultStackSize = 100,
		items = {
			"copper-ingot", "tin-ingot", "bronze-ingot", "iron-ingot", "gold-ingot", "lead-ingot", "steel-ingot", "brass-ingot", "nickel-ingot", "chromium-ingot", "platinum-ingot",
			"glass", "nanoglass",
			"stone-brick",
			"rubber",
		},
	},

	-- TODO remove this, handle some other way
	-- bundle = {
	-- 	defaultStackSize = 30,
	-- 		-- Note that player can manually unbundle - feature added by IR3.
	-- 		-- So we can't set the stack sizes of the bundles too high, or it'll break, bc unbundle product will be capped at 1 stack.
	-- 		-- TODO maybe rather just set these per-item, using the non-bundle item divided by the appropriate factor.
	-- 	items = {
	-- 		"stacked-stone-brick", "stacked-plastic-bar", "stacked-concrete-block", "stacked-copper-ingot", "stacked-tin-ingot", "stacked-bronze-ingot", "stacked-glass", "stacked-nanoglass", "stacked-iron-ingot", "stacked-gold-ingot", "stacked-lead-ingot", "stacked-steel-ingot", "stacked-brass-ingot", "stacked-nickel-ingot", "stacked-chromium-ingot", "stacked-platinum-ingot",
	-- 	}
	-- },
}

return stackSizeGroups

-- TODO gemstones