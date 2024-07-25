-- In Desolation, enemy evolution is based on techs. Specifically, techs with the evolution effect increase evolution.

local function getTechEvo(tech)
	-- Given a LuaTechnology, returns the evolution effect in that tech, or nil if none.
	-- This is the percentage, ie a number like 15, not 0.15.
	if not tech.valid then return nil end
	if tech.effects == nil then return nil end
	for _, effect in pairs(tech.effects) do
		if effect.type == "nothing" and effect.effect_description[1] == "effect-description.evolution" then
			return tonumber(effect.effect_description[2])
				-- We store the amount in the localised description field, bc there's no other convenient place to store it.
		end
	end
	return nil
end

local function disableVanillaEvolution()
	-- Sets all evolution factors to 0 for enemy force, so vanilla evolution is effectively disabled.
	game.map_settings.enemy_evolution.enabled = false
	local force = game.forces["enemy"]
	force.evolution_factor = 0
	force.evolution_factor_by_killing_spawners = 0
	force.evolution_factor_by_pollution = 0
	force.evolution_factor_by_time = 0
	-- Looks like these factors are for the enemy force, not for the player's force. So no need to set them for other forces.
end

local function calculateEvoForForce(force)
	-- Return sum of evolution effects for all techs owned by the given force.
	-- This is the percentage, ie a number like 15, not 0.15.
	if not force.valid then return 0 end
	if force.name == "enemy" or force.name == "ir-sims" then return 0 end
		-- Force ir-sims has all techs researched from the start. Used by IR3 to show simulations.
	if #force.players == 0 then return 0 end
	if force.technologies == nil then return 0 end
	local evo = 0
	for techName, tech in pairs(force.technologies) do
		if tech.researched then
			--log("Tech is researched: "..techName.." by force: "..force.name)
			evo = evo + (getTechEvo(tech) or 0)
		end
	end
	return evo
end

local function recalculateEvolution()
	-- Recalculate evolution by looking through all techs for all forces, and setting evolution factor for enemy faction to the max for all forces's techs.
	local maxEvo = 0
	for _, force in pairs(game.forces) do
		local evoForForce = calculateEvoForForce(force)
		maxEvo = math.max(maxEvo, evoForForce)
	end
	game.forces["enemy"].evolution_factor = maxEvo
end

local function onInit()
	disableVanillaEvolution()
end

local function onConfigChanged()
	disableVanillaEvolution()
	recalculateEvolution()
end

local function onLoad()
	--disableVanillaEvolution()
	--recalculateEvolution()
	-- Seems game is nil on load.
	-- Don't really need to re-set stuff here anyway.
end

local function onResearchFinished(event)
	local tech = event.research
	if (not tech.valid) or (tech.force == nil) then return end
	local force = tech.force
	if not force.valid then return end

	local thisForceEvo = calculateEvoForForce(force)
	if thisForceEvo > 100 then thisForceEvo = 100 end
	local thisForceEvoFrac = thisForceEvo / 100.0

	local enemyCurrEvoFrac = game.forces["enemy"].evolution_factor
	if thisForceEvoFrac > enemyCurrEvoFrac then
		game.forces["enemy"].evolution_factor = thisForceEvoFrac
		game.print({"Desolation-message.evolution-increased", string.format("%.0f", thisForceEvo)})
	end
end

return {
	onResearchFinished = onResearchFinished,
	onInit = onInit,
	onLoad = onLoad,
	onConfigChanged = onConfigChanged,
}