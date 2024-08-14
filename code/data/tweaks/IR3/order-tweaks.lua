-- Move batteries to their own subgroup, underneath canisters.
-- Partly bc it makes more sense in the crafting menu, and partly bc it reorders vehicle fuel slots more sensibly.
data:extend({{
	type = "item-subgroup",
	name = "batteries",
	group = "intermediate-products", -- Complex components
	order = "i2",
}})
local items = {
	"battery",
	"charged-battery",
	"advanced-battery",
	"charged-advanced-battery",
	"hydrogen-battery",
	"charged-hydrogen-battery",
}
for _, item in pairs(items) do
	data.raw.item[item].subgroup = "batteries"
end
data.raw.recipe["battery"].subgroup = "batteries"

-- Move flamethrower ammo to shell/mag row, so there isn't an ugly row with only atomic bomb.
data.raw.ammo["flamethrower-ammo"].subgroup = "ir-ammo"
data.raw.recipe["flamethrower-ammo"].order = "c"