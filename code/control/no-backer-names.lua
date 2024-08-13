-- Remove backer names when placing labs, train stops, etc.
-- I'm changing it to not apply to ghosts or train stops, bc otherwise train stops in blueprints aren't pasted correctly.
-- Unfortunately this means that eg blueprinting labs will still give them names.
-- Could remove the exclusion for train stops, but then in some cases (eg blueprint-pasting a train stop, then building it manually) the train stop will get its name removed.
-- Basically, I'm erring on the side of never causing possibly-disruptive behavior, just eliminating backer names in some cases where it's known to be non-disruptive.

-- To fix this permanently, the user could just change the file Factorio/data/core/backers.json to only have the one entry "".

-- I could make a separate mod that has the entire list of ~3000 backer names included with Factorio, and then checks all named entities against this list, setting names to "" if they're in that list. But that should be in a separate QOL mod, and also seems unnecessary since users could just edit backers.json themselves.

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