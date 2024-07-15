local Recipe = require("code.util.recipe")

-- Add some scrap to wood beams recipe.
-- Need to be careful about fuel values, so we don't incentivize cutting/crushing wood before burning it.
-- Wood chips have fuel value 1MJ, beam is 1MJ, wood is 2MJ. Ordinarily 1 wood => 2 beams, and then using the beams gives 5% extra in wood chips as scrap.
--   Let's change that recipe so it's 1 wood => 1-2 beams and 0-1 wood chips. Conserves totals.
-- Wood chips are used to make charcoal, and to make ethanol. So, can't be used to make more wood, at least.
--   (Except by powering forestries, but that's expected to make stuff out of nothing, since it uses land area.)
Recipe.setResults("wood-beam", {
	{type="item", name="wood-beam", amount_min=1, amount_max=2},
	{type="item", name="wood-chips", amount_min=0, amount_max=1},
})

-- Reduce the fuel value of plain wood, so you have reason to cut or crush it before burning.
--data.raw.item.wood.fuel_value = 1500000 -- 1.5 MJ
-- Actually, rather just make it so you have to cut/crush it before burning.
data.raw.item.wood.fuel_category = nil
data.raw.item.wood.fuel_value = nil