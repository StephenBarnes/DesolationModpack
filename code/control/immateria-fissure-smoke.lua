-- We want our immateria fissures to emit the red smoke when they get created.
-- IR3 currently generates smoke by listening to on_built on the fissures, which gets triggered because it does some kind of modification to make them always have 100% yield.
-- We can't add the immateria fissure to IR3's table of fissures, in CONTROL.autoplaced_fissures, bc it's control-stage so it's sandboxed.
-- So instead, just listen to on-created events.

local function addImmateriaFissureSmoke(surface, area)
	local fissures = surface.find_entities_filtered{area = area, name = "immateria-fissure", type="resource"}
	for _, fissure in pairs(fissures) do
		fissure.surface.create_entity{name = "immateria-fissure-smoke", position = fissure.position}
	end
end

return {
	onChunkGenerated = addImmateriaFissureSmoke,
}