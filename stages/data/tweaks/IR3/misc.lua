
-- Considered: Make all small and large frames cost twice as much, to make infrastructure more expensive. Decided against because current costs already seem pretty expensive.

-- Reduce copper boiler effectiveness, so you need more of them and you're more eager to upgrade to iron boilers.
data.raw.boiler["copper-boiler"].energy_consumption = "300000W" -- changed 15000 -> 5000, or 900kW -> 300kW

-- Reduce copper pump effectiveness, so you're more eager to upgrade to iron ones.
data.raw["offshore-pump"]["copper-pump"].pumping_speed = 3.0 -- 8.0 -> 3.0, so water is 480/sec -> 180/sec, can provide water to 16 -> 6 copper boilers (excluding change to copper boilers above).

-- Make rubber tree beds require ordinary wood, not rubber wood, because the Desolation map preset makes rubber trees rare.
data.raw.recipe["tree-planter-ir-rubber-tree"].ingredients = {{"wood", 12}, {"stone-brick", 8}}

-- TODO make transport belts more expensive, to discourage long-distance belting in the early game, in favor of the heavy roller/picket.
