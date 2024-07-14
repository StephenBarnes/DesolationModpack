-- Fewer fish, bc there's far too many.
data.raw.fish.fish.autoplace.influence = 0.0005 -- Default is 0.01.

-- Reduce healing
data.raw.capsule["raw-fish"].capsule_action.attack_parameters.ammo_type.action.action_delivery.target_effects[1].damage.amount = -5 -- Default is -80.
data.raw.capsule["raw-fish"].capsule_action.attack_parameters.cooldown = 120 -- Default is 30 (ticks), so 2/sec. Increase to 120 ticks = 2 secs.

-- Mining fish should only produce 1 fish, not 5.
data.raw.fish.fish.minable.count = 1 -- 5 -> 1.
data.raw.fish.fish.minable.mining_time = 0.2 -- 0.4 -> 0.2.