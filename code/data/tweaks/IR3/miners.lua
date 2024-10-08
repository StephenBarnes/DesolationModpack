--[[ This file tweaks IR3's mining drills.
Most of this file is a (commented-out) script to analyze the miners in the game, and output stats for them. This is to help balance the miners relative to each other.
I'm adjusting the miners so that:
	1. they're better balanced relative to each other
	2. their stats are round numbers.
]]

--[[ Analysis script.

-- Base IR3 uses these values:
local miners_baseIR3 = {
	{ name = "copper-burner", speed = 1.25, side = 5, pollution = 15, powerKW = 750 },
	{ name = "copper-steam", speed = 1.25, side = 5, pollution = 15, powerKW = 250 },
	{ name = "electric-mining-drill", speed = 2.5, side = 5, pollution = 30, powerKW = 500 },
	{ name = "electric-mining-drill-2", speed = 3.75, side = 7, pollution = 45, powerKW = 625 },
}
--For base IR3's miners, output:
--Miner copper-burner: 0.05 items per tile-second, 600 kJ per item, 0.2 pollution per item
--Miner copper-steam: 0.05 items per tile-second, 200 kJ per item, 0.2 pollution per item
--Miner electric-mining-drill: 0.1 items per tile-second, 200 kJ per item, 0.2 pollution per item
--Miner electric-mining-drill-2: 0.076530612244898 items per tile-second, 166.66666666667 kJ per item, 0.2 pollution per item

-- Currently big mining drill actually produces less per tile-second, though with slightly less power consumption. The big mining drill is very expensive and complex to produce compared to the smaller electric drill. So I think it should have much better performance characteristics.
-- Also going to make the burner-vs-steam power consumption more comparable.

-- Modifying the miners like this:
local miners_modified = {
	{ name = "copper-burner", speed = 1, side = 5, pollution = 30, powerKW = 350 }, -- Changed output 1.25 => 1, and power 750kW => 350kW, and pollution 15 => 30 (= steam miner plus copper boiler, for reference).
	{ name = "copper-steam", speed = 1, side = 5, pollution = 15, powerKW = 250 }, -- Changed output 1.25 => 1, otherwise unchanged.
	{ name = "electric-mining-drill", speed = 2, side = 5, pollution = 30, powerKW = 500 }, -- Changed output 2.5 => 2, otherwise unchanged.
	{ name = "electric-mining-drill-2", speed = 8, side = 7, pollution = 90, powerKW = 1500 }, -- Changed speed 3.75 => 8, and power 625kW => 1500kW, and pollution 45 => 90
}
--For my modified miners, output:
--Miner copper-burner: 0.04 items per tile-second, 350 kJ per item, 0.5 pollution per item
--Miner copper-steam: 0.04 items per tile-second, 250 kJ per item, 0.25 pollution per item
--Miner electric-mining-drill: 0.08 items per tile-second, 250 kJ per item, 0.25 pollution per item
--Miner electric-mining-drill-2: 0.16326530612245 items per tile-second, 187.5 kJ per item, 0.1875 pollution per item

log("Start miner analysis:")
local minerSets = {["base IR3"] = miners_baseIR3, ["Desolation"] = miners_modified}
for name, miners in pairs(minerSets) do
	log("Miner analysis for "..name..":")
	for _, miner in pairs(miners) do
		local area = miner.side * miner.side
		local energyPerItem = miner.powerKW / miner.speed
		local itemsPerTile = miner.speed / area
		-- NOTE this is per tile occupied/blocked by the miner, not per tile harvested.
		local pollutionPerItem = (miner.pollution / 60) / miner.speed
		log(string.format("Miner %s: %s items per tile-second, %s kJ per item, %s pollution per item", miner.name, itemsPerTile, energyPerItem, pollutionPerItem))
	end
end
]]

-- Enact the modifications above.
-- Change mining speeds.
data.raw["mining-drill"]["burner-mining-drill"].mining_speed = 1
data.raw["mining-drill"]["steam-drill"].mining_speed = 1
data.raw["mining-drill"]["steam-drill-simulation"].mining_speed = 1
data.raw["mining-drill"]["electric-mining-drill"].mining_speed = 2
data.raw["mining-drill"]["electric-mining-drill-simulation"].mining_speed = 2
data.raw["mining-drill"]["chrome-drill"].mining_speed = 8
data.raw["mining-drill"]["chrome-drill-simulation"].mining_speed = 8
-- Change burner copper drill power consumption.
data.raw["mining-drill"]["burner-mining-drill"].energy_usage = "350kW"
data.raw["mining-drill"]["burner-mining-drill"].energy_source.emissions_per_minute = 30
-- Change the big electric drill's speed and power.
data.raw["mining-drill"]["chrome-drill"].energy_source.emissions_per_minute = 90
data.raw["mining-drill"]["chrome-drill"].energy_usage = "1500kW"
data.raw["mining-drill"]["chrome-drill-simulation"].energy_source.emissions_per_minute = 90
data.raw["mining-drill"]["chrome-drill-simulation"].energy_usage = "1500kW"