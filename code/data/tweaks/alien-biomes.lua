-- Remove a few of the rocks that I keep noticing because they look improbable but spawn frequently.
local function changeRockPictures(rockName, expectedPicCount, picIndices)
	local originalPictures = data.raw["simple-entity"][rockName].pictures
	if originalPictures == nil then
		log("ERROR: Couldn't find original pictures for "..rockName..".")
		return
	end
	if #originalPictures ~= expectedPicCount then
		log("ERROR: Expected "..expectedPicCount.." pictures for "..rockName..", but found "..#originalPictures.." pictures.")
		return
	end
	local newPictures = {}
	for _, picIndex in pairs(picIndices) do
		table.insert(newPictures, originalPictures[picIndex])
	end
	data.raw["simple-entity"][rockName].pictures = newPictures
end
changeRockPictures("rock-huge-white", 16, {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 15, 16}) -- Remove 11, 12
changeRockPictures("rock-huge-volcanic", 16, {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 15, 16}) -- Remove 11, 12

-- Change frequency of some entities.
data.raw["simple-entity"]["rock-huge-white"].autoplace.max_probability = 0.05 -- originally 0.525

-- Reduce frequency of some of the decorations that just seem too common, or are too tropical/whatever to fit with the theme.
-- Reduce puddles, rock decals, etc.
data.raw["optimized-decorative"]["puddle-decal"].autoplace.max_probability = 0.03 -- originally 0.1
	-- Also looks like they have a typo, puddle-decal.lua line says infleunce instead of influence. Notified them on Discord.
data.raw["optimized-decorative"]["sand-decal-white"].autoplace.max_probability = 0.02
data.raw["optimized-decorative"]["stone-decal-white"].autoplace.max_probability = 0.01
-- Reduce various vegetation.
data.raw["optimized-decorative"]["cane-cluster"].autoplace.max_probability = 0.3
data.raw["optimized-decorative"]["cane-single"].autoplace.max_probability = 0.3
data.raw["optimized-decorative"]["brown-asterisk-mini"].autoplace.max_probability = 0.2
	-- This has the color as prefix instead of suffix, I think because it's a vanilla plant.
data.raw["optimized-decorative"]["red-asterisk"].autoplace.max_probability = 0.2
data.raw["optimized-decorative"]["asterisk-mini-turquoise"].autoplace.max_probability = 0.2
data.raw["optimized-decorative"]["asterisk-mauve"].autoplace.max_probability = 0.1
data.raw["optimized-decorative"]["asterisk-mini-mauve"].autoplace.max_probability = 0.15
data.raw["optimized-decorative"]["asterisk-mini-yellow"].autoplace.max_probability = 0.15
data.raw["optimized-decorative"]["pita-blue"].autoplace.max_probability = 0.2
data.raw["optimized-decorative"]["pita-green"].autoplace.max_probability = 0.2
data.raw["optimized-decorative"]["pita-olive"].autoplace.max_probability = 0.2
data.raw["optimized-decorative"]["red-pita"].autoplace.max_probability = 0.04
data.raw["optimized-decorative"]["pita-mini-turquoise"].autoplace.max_probability = 0.2
data.raw["optimized-decorative"]["pita-turquoise"].autoplace.max_probability = 0.05
data.raw["optimized-decorative"]["pita-mini-blue"].autoplace.max_probability = 0.04
data.raw["optimized-decorative"]["pita-mini-olive"].autoplace.max_probability = 0.15
data.raw["optimized-decorative"]["brown-fluff-dry"].autoplace.max_probability = 0.2
data.raw["optimized-decorative"]["red-desert-bush"].autoplace.max_probability = 0.1
data.raw["optimized-decorative"]["carpet-grass-purple"].autoplace.max_probability = 0.3
data.raw["optimized-decorative"]["croton-blue"].autoplace.max_probability = 0.2
-- Remove/reduce the craters.
data.raw["optimized-decorative"]["crater1-large"].autoplace = nil
data.raw["optimized-decorative"]["crater2-medium"].autoplace = nil
data.raw["optimized-decorative"]["crater1-large-rare"].autoplace.max_probability = 0.05
-- Remove the volcanic magma flows etc.
data.raw["optimized-decorative"]["lava-decal-orange"].autoplace = nil