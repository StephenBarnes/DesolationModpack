-- Remove scrap from container recipe, to prevent exploits with disassembling containers.
data.raw.recipe["ic-container"].result = "ic-container"
data.raw.recipe["ic-container"].result_count = 1
data.raw.recipe["ic-container"].results = nil