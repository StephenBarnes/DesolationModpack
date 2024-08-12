-- Make the starting copper/tin junkpiles produce some better products, to jumpstart the game.
-- IR3 has a setting for starting age, which determines which junkpiles are used. Desolation uses the "stone" setting which starts us with copper/tin junkpiles. Other starting ages already produce non-scrap stuff. So we only modify if we're starting with stone.
-- But we don't need to care about any of that, just modify those starting junkpiles. Won't affect starting items if a different starting age is used, because the junkpiles we're modifying here won't be placed.

-- Note that these items can trigger inspirations like copper/tin-working 2, even before their prereqs are researched. I tried and failed to change the costs of these in Inspiration, so instead I'll just make sure we don't get many of those inspiration-triggering items here.

local itemsAmounts = {
	["copper-scrap"] = {80, 120},
	["tin-scrap"] = {80, 120},
	["copper-plate"] = {1, 1},
	["tin-plate"] = {1, 1},
	["copper-rod"] = {3, 7},
	["tin-rod"] = {3, 7},
	["copper-gear-wheel"] = {1, 1},
	["tin-gear-wheel"] = {1, 1},
	["copper-rivet"] = {4, 6},
}

local junkpileName = "copper-tin-junkpile-scrap"
-- If Inspiration is enabled, this should be "copper-tin-junkpile-scrap", else "copper-tin-junkpile".

data.raw["simple-entity"][junkpileName].minable.results = {}
for itemName, amounts in pairs(itemsAmounts) do
	if data.raw.item[itemName] ~= nil then
		local itemData = {
			name = itemName,
			type = "item",
			amount_min = amounts[1],
			amount_max = amounts[2],
		}
		table.insert(data.raw["simple-entity"][junkpileName].minable.results, itemData)
	end
end