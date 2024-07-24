-- Scattergun turrets now require a large copper frame. Original cost is 19 copper + 16 tin ingots; this makes the cost about 3 times greater
data.raw.recipe["scattergun-turret"].ingredients = {
	{"copper-motor", 2}, -- unchanged
	{"copper-plate", 4}, -- 12->4
	-- tin-plate 12->0
	{"tin-gear-wheel", 4}, -- unchanged
	{"copper-frame-large", 1}, -- added 0->1
}

-- Autogun turrets require a large iron frame, and have electronics 1 as prerequisite for the tech (to unlock large iron frame).
table.insert(data.raw.technology["gun-turret"].prerequisites, "ir-electronics-1")
data.raw.recipe["gun-turret"].ingredients = {
	{"iron-piston", 2}, -- changed motor to piston, bc I want to put it pre-electricity.
	{"iron-plate-heavy", 4}, -- reinforced iron plate, 10->4
	-- iron-beam 8->0
	{"iron-gear-wheel", 8}, -- reduced amount 16->8
	{"iron-frame-small", 1}, -- can't be large frame bc I want to put it pre-electricity.
}
