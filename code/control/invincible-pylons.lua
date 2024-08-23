local function makePylonSafe(event)
	local entity = event.created_entity
	if not entity or not entity.valid then return end
	if entity.name == "big-electric-pole" then
		entity.destructible = false
	end
end

return {
	onBuiltEntity = makePylonSafe,
	onRobotBuiltEntity = makePylonSafe,
}