-- Remove scrap from intermodal container recipe, to prevent exploits with disassembling containers.
if mods["ProductionScrapForIR3"] then
	local icContainerResults = data.raw.recipe["ic-container"].results
	if icContainerResults ~= nil then
		local newResults = {}
		for _, result in pairs(icContainerResults) do
			if result.name ~= "iron-scrap" and result[1] ~= "iron-scrap" then
				table.insert(newResults, result)
			end
		end
		data.raw.recipe["ic-container"].results = newResults
	end
end