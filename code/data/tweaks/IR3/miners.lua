-- This file tweaks IR3's mining drills.
-- Most of this file is a (commented-out) script to analyze the miners in the game, and output stats for them. This is to help balance the miners relative to each other.

--[[
-- Base IR3 uses these values:
local miners_baseIR3 = {
	{ name = "copper-burner", speed = 1.25, side = 7, pollution = 15, powerKW = 750 },
	{ name = "copper-steam", speed = 1.25, side = 7, pollution = 15, powerKW = 250 },
	{ name = "electric-mining-drill", speed = 2.5, side = 9, pollution = 30, powerKW = 500 },
	{ name = "electric-mining-drill-2", speed = 3.75, side = 11, pollution = 45, powerKW = 625 },
}
--For base IR3's miners, output:
-- Miner copper-burner: 0.025510204081633 items per tile-second, 600 kJ per item, 0.2 pollution per item
-- Miner copper-steam: 0.025510204081633 items per tile-second, 200 kJ per item, 0.2 pollution per item
-- Miner electric-mining-drill: 0.030864197530864 items per tile-second, 200 kJ per item, 0.2 pollution per item
-- Miner electric-mining-drill-2: 0.03099173553719 items per tile-second, 166.66666666667 kJ per item, 0.2 pollution per item

-- Going to make the burner-vs-steam power consumption more comparable.
-- The big mining drill is very expensive and complex to produce compared to the smaller electric drill. So I think it should have much better performance characteristics.

-- Modifying the miners like this:
local miners = {
	{ name = "copper-burner", speed = 1.25, side = 7, pollution = 30, powerKW = 300 }, -- Changed power 750kW => 300kW, and pollution 15 => 30 (= steam miner plus copper boiler, for reference)
	{ name = "copper-steam", speed = 1.25, side = 7, pollution = 15, powerKW = 250 },
	{ name = "electric-mining-drill", speed = 2.5, side = 9, pollution = 30, powerKW = 500 },
	{ name = "electric-mining-drill-2", speed = 6, side = 11, pollution = 36, powerKW = 600 }, -- Changed speed 3.75 => 6, and power 625kW => 600kW, and pollution 45 => 36
}
--For my modified miners, output:
-- Miner copper-burner: 0.025510204081633 items per tile-second, 240 kJ per item, 0.4 pollution per item
-- Miner copper-steam: 0.025510204081633 items per tile-second, 200 kJ per item, 0.2 pollution per item
-- Miner electric-mining-drill: 0.030864197530864 items per tile-second, 200 kJ per item, 0.2 pollution per item
-- Miner electric-mining-drill-2: 0.049586776859504 items per tile-second, 100 kJ per item, 0.1 pollution per item

log("Start miner analysis:")
for _, miner in pairs(miners) do
	local area = miner.side * miner.side
	local energyPerItem = miner.powerKW / miner.speed
	local itemsPerTile = miner.speed / area
	-- NOTE this is per tile occupied/blocked by the miner, not per tile harvested.
	local pollutionPerItem = (miner.pollution / 60) / miner.speed
	log(string.format("Miner %s: %s items per tile-second, %s kJ per item, %s pollution per item", miner.name, itemsPerTile, energyPerItem, pollutionPerItem))
end
]]

-- Enact the modifications above.
-- Change burner copper drill power consumption.
data.raw["mining-drill"]["burner-mining-drill"].energy_usage = "300kW"
data.raw["mining-drill"]["burner-mining-drill"].energy_source.emissions_per_minute = 30
-- Change the big electric drill's speed and power.
data.raw["mining-drill"]["chrome-drill"].mining_speed = 6
data.raw["mining-drill"]["chrome-drill"].energy_usage = "600kW"