-- Remove backer names when placing labs, train stops, etc.
-- I'm changing it to not apply to ghosts or train stops, bc otherwise train stops in blueprints aren't pasted correctly.
-- Unfortunately this means that eg blueprinting labs will still give them names.
-- Could remove the exclusion for train stops, but then in some cases (eg blueprint-pasting a train stop, then building it manually) the train stop will get its name removed.
-- Basically, I'm erring on the side of never causing unexpected behavior, just eliminating some obviously stupid behavior like naming labs.

local function onBuiltEntity(event)
	local entity = event.created_entity or event.entity
	if entity.type == "entity-ghost" or entity.type == "train-stop" then return end
	if entity.supports_backer_name() then
		entity.backer_name = ""
	end
end

return {
	onBuiltEntity = onBuiltEntity,
	onRobotBuiltEntity = onBuiltEntity,
}

-- TODO rather check the list of backer names in Factorio/data/core/backers.json, and put those in a table, and then remove any entity name that's in that set.

-- TODO check how this mod does it: https://mods.factorio.com/mod/Namelists?from=search