-- Register flammable items and fluids for the Arson mod.

-- In-game, to view info for a specific item:
-- /c __Arson__ game.print(game.table_to_json(global.flammable["wood-pallet"]))

-- In-game, to dump the whole table:
-- /c __Arson__ game.write_file("data.json", game.table_to_json(global.flammable))

local function add_flammables()
    if remote.interfaces["maticzplars-flammables"] and remote.interfaces["maticzplars-flammables"].add_item then
        --[[
        remote.call("maticzplars-flammables", "add_item",
            "se-vulcanite",  -- Item name
            5, -- Fire strength
            10, -- Fire spread cooldown
            true, -- Make fireball
            0.5 -- Explosion radius
        )
        remote.call("maticzplars-flammables", "add_fluid",
            "se-liquid-rocket-fuel", -- Fluid name
            20, -- Fire strength
            true, -- Make fireball
            1.5 -- Explosion radius
        )
            --]]

        --remote.call("maticzplars-flammables", "recalculate_flammables",
        --    "diamond%-" -- Ignore match statement
        --)
    end
end

script.on_init(add_flammables)
script.on_configuration_changed(add_flammables)

-- To remove: diamond-powder, diamond-gem, medical-pack

-- bitumen-fluid
-- atomic-artillery-shell
-- rockets, explosive rockets
-- the new shotgun cartridges
-- the new ammo type
-- the batteries, if charged?
-- hydrogen cell, if full
-- petroleum canister, high octane fuel canister
-- heavy and light oil barrels, petroleum barrel
-- lox canister?
-- liquid natural gas canister
-- fossil gas, liquid hydrogen?, etc.
-- rubber wood
-- rubber?