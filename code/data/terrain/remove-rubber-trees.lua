-- Remove all IR3's rubber trees, bc they don't visually fit in, and it seems I can't toggle the checkbox with a map gen preset.
data.raw["autoplace-control"]["ir-rubber-trees"] = nil
data.raw.tree["ir-rubber-tree"].autoplace = nil