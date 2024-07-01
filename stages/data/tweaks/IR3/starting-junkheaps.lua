-- Make the starting copper/tin junkpiles produce some better products, to jumpstart the game.
-- IR3 has a setting for starting age, which determines which junkpiles are used. Desolation uses the "stone" setting which starts us with copper/tin junkpiles. Other starting ages already produce non-scrap stuff. So we only modify if we're starting with stone.
-- But we don't need to care about any of that, just modify those starting junkpiles. Won't affect starting items if a different starting age is used, because the junkpiles we're modifying here won't be placed.
local metals = {"copper", "tin"}
local itemsAmounts = {
	["scrap"] = {40, 60},
	["plate"] = {4, 6},
	["rod"] = {8, 12},
	["gear-wheel"] = {4, 6},
	["rivet"] = {4, 6},
}
data.raw["simple-entity"]["copper-tin-junkpile-scrap"].minable.results = {}
for _, metal in pairs(metals) do
	for item, amounts in pairs(itemsAmounts) do
		local itemName = metal .. "-" .. item
		if data.raw.item[itemName] ~= nil then
			local itemData = {
				name = itemName,
				type = "item",
				amount_min = amounts[1],
				amount_max = amounts[2],
			}
			table.insert(data.raw["simple-entity"]["copper-tin-junkpile-scrap"].minable.results, itemData)
		end
	end
end
-- Note that these items can trigger inspirations like copper/tin-working 2, even before their prereqs are researched. So I need to increase the inspiration cost of those items, which I'll do elsewhere.