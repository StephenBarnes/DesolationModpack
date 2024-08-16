-- This file tweaks the beacon rebalance mod by wretlaw120: https://mods.factorio.com/mod/wret-beacon-rebalance-mod

-- I don't like having multiple tiers of beacons with basically the same sprites. So rather have 2 beacon tiers, tier 1 using the sprites included with Beacon Rebalance, and tier 2 using the vanilla sprites.

-- I think these rebalanced beacons are interesting, so I want them to be available for more of the game.
-- Also, IR3 makes modules available earlier, so I think it fits to make beacons available earlier too.
-- So, going to put beacon tier 1 soon after modules 1, namely having only modules 1 as its prereq.
-- Then beacon tier 2 comes after modules tier 3 and force fields.

-- TODO rewrite descriptions and names
-- TODO note that they only allow speed and efficiency, not prod

local Tech = require("code.util.tech")
local Recipe = require("code.util.recipe")

Tech.setPrereqs("effect-transmission", {"ir-modules-1"})
Tech.setPrereqs("effect-transmission-2", {"ir-modules-3", "effect-transmission", "ir-force-fields"})

Recipe.setIngredients("beacon", {
	{"iron-frame-large", 1},
	{"copper-coil", 4}, -- Iron core EM coil.
	{"copper-cable-heavy", 1}, -- Heavy copper cable, rubber-coated.
})
Recipe.setIngredients("beacon2-recipe", {
	{"field-effector", 4},
	--{"electrum-plate-special", 4}, -- Null field plate
	{"chromium-frame-large", 1},
	{"junction-box", 2}, -- Because 2 modules are shown on the sprite, plugged into things that look like junction boxes.
})

-- Set image for the beacon 2 tech; beacon 1 tech is already fine.
data.raw.technology["effect-transmission-2"].icon = "__base__/graphics/technology/effect-transmission.png"
data.raw.technology["effect-transmission-2"].icon_size = 256
data.raw.technology["effect-transmission-2"].icon_mipmaps = 4

-- Set beacon 1 item icons (wret "classic" beacon)
data.raw.item["beacon"].icons = nil
data.raw.item["beacon"].icon = "__wret-beacon-rebalance-mod__/classic_beacon_graphics/icon/beacon.png"
data.raw.item["beacon"].icon_size = 64
data.raw.item["beacon"].icon_mipmaps = 4

-- Set beacon 2 item icons (vanilla "pole" beacon)
data.raw.item["beacon2-item"].icons = nil
data.raw.item["beacon2-item"].icon = "__base__/graphics/icons/beacon.png"
data.raw.item["beacon2-item"].icon_size = 64
data.raw.item["beacon2-item"].icon_mipmaps = 4

-- Set entity images for beacon 2
data.raw.beacon["beacon2"].graphics_set = require("__base__.prototypes.entity.beacon-animations")

-- Set params for the beacon mk1.
local beacon1ent = data.raw.beacon["beacon"]
beacon1ent.distribution_effectivity = 0.5
beacon1ent.energy_usage = "100kW"
beacon1ent.module_specification.module_slots = 2
beacon1ent.module_specification.module_info_max_icon_rows = 1
beacon1ent.module_specification.module_info_max_icons_per_row = 2
beacon1ent.supply_area_distance = 3.5 - 1.2
-- It's a 3x3 building, collision box extending 1.2 each direction, supply area 7x7.

-- Set params for the beacon mk2.
local beacon2ent = data.raw.beacon["beacon2"]
beacon2ent.distribution_effectivity = 1
beacon2ent.energy_usage = "1MW"
beacon2ent.module_specification.module_slots = 2
beacon2ent.module_specification.module_info_max_icon_rows = 1
beacon2ent.module_specification.module_info_max_icons_per_row = 2
beacon2ent.collision_box = {{-1.2, -1.2}, {1.2, 1.2}}
beacon2ent.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}
beacon2ent.drawing_box = {{-1.5, -1.5}, {1.5, 1.5}}
beacon2ent.supply_area_distance = 6.5 - 1.2
-- It's a 3x3 building, collision box extending 1.2 each direction, supply area 13x13.
-- For the supply area, I want it to be a bit irregular, maybe 5 on each side plus the beacon itself, so 13x13.

-- Beacons 2 tech name and description
data.raw.technology["effect-transmission-2"].localised_name = {"technology-name.effect-transmission-2"}
data.raw.technology["effect-transmission-2"].localised_description = {"technology-description.effect-transmission-2"}

-- Beacon 1 tech should be cheap
data.raw.technology["effect-transmission"].unit = table.deepcopy(data.raw.technology["ir-modules-1"].unit)
data.raw.technology["effect-transmission"].unit.count = 200

-- Thinking a bit about how strong these beacons should be, and what power consumption they should have.
-- Electric assemblers consume 125kW.
-- A basic beacon with 2x efficiency 1 modules operating at 50% strength provides -30% power consumption, reducing 8 electric assemblers to 90kW each.
-- This is a 35kW * 8 = 280kW savings in energy, if they operate all the time. So the basic beacon could consume say 100kW, so it's still a slight savings overall.
-- After player researches modules 2, (after red circuits, after gold and oil), one beacon provides -40% power consumption, reducing 8 electric assemblers to 77kW each. This is a 48kW * 8 = 384kW savings in energy, compared to the 100kW cost for the basic beacon.
-- The large beacon has 13x13 = 169 area of effect, compared to 49, so it's around 3.5x as big. It applies effects at double the strength. So overall like 7x as good, ignoring issues of packing assemblers in etc. It also affects more powerful machines, so larger energy savings. So it could consume maybe 1MW.