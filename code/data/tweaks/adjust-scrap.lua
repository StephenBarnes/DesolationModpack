-- Reduce scrap from intermodal container recipe, to prevent exploits with disassembling containers.
local icContainerResults = data.raw.recipe["ic-container"].results
if icContainerResults ~= nil and icContainerResults[2] ~= nil and icContainerResults[2].probability ~= nil then
	icContainerResults[2].probability = math.min(icContainerResults[2].probability, 0.15)
end