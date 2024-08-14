-- Unmark the airships as military target. Bc otherwise BREAM is going to spawn bugs in all the frigid terrain, and they'll attack your airships. Anyway makes sense the bugs wouldn't be able to reach the airships.
data.raw["spider-vehicle"]["hydrogen-airship"].is_military_target = false
data.raw["spider-vehicle"]["helium-airship"].is_military_target = false
data.raw["spider-vehicle"]["hydrogen-airship"].spider_engine.military_target = nil
data.raw["spider-vehicle"]["helium-airship"].spider_engine.military_target = nil

-- TODO maybe make the airships cheaper? Bc they're nice, should encourage using them in large numbers, rather than cargo ships.
