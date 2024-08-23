-- Remove scrap from intermodal container recipe, to prevent exploits with disassembling containers.
-- TODO ProductionScrap mod should probably be modified to check some field of the recipe prototype, and then not generate scrap for those.
if mods["ProductionScrapForIR3"] then
	local noScrapRecipes = {"ic-container", "empty-barrel"}
	for _, recipeName in pairs(noScrapRecipes) do
		local recipe = data.raw.recipe[recipeName]
		if recipe == nil then
			log("ERROR: Couldn't find recipe "..recipeName.." to remove scrap from.")
		else
			local results = data.raw.recipe[recipeName].results
			if results ~= nil then
				local newResults = {}
				for _, result in pairs(results) do
					if (result.name ~= "iron-scrap" and result[1] ~= "iron-scrap"
							and result.name ~= "steel-scrap" and result[1] ~= "steel-scrap"
						) then
						table.insert(newResults, result)
					end
				end
				data.raw.recipe[recipeName].results = newResults
			end
		end
	end
end