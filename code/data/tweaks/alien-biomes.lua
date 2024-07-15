-- Remove a few of the rocks that I keep noticing because they look improbable but spawn frequently.
local originalPictures = data.raw["simple-entity"]["rock-huge-white"].pictures
if originalPictures ~= nil and #originalPictures == 16 then
	data.raw["simple-entity"]["rock-huge-white"].pictures = {
		originalPictures[1],
		originalPictures[2],
		originalPictures[3],
		originalPictures[4],
		originalPictures[5],
		originalPictures[6],
		originalPictures[7],
		originalPictures[8],
		originalPictures[9],
		originalPictures[10],
		-- originalPictures[11],
		-- originalPictures[12],
		originalPictures[13],
		originalPictures[14],
		originalPictures[15],
		originalPictures[16],
	}
end

-- Change frequency of some entities.
data.raw["simple-entity"]["rock-huge-white"].autoplace.max_probability = 0.1 -- originally 0.525

-- Reduce frequency of some of the decorations.
data.raw["optimized-decorative"]["cane-cluster"].autoplace.max_probability = 0.1
data.raw["optimized-decorative"]["cane-single"].autoplace.max_probability = 0.1
data.raw["optimized-decorative"]["puddle-decal"].autoplace.max_probability = 0.03 -- originally 0.1
	-- Also looks like they have a typo, puddle-decal.lua line says infleunce instead of influence. Notified them on Discord.
data.raw["optimized-decorative"]["sand-decal-white"].autoplace.max_probability = 0.03
data.raw["optimized-decorative"]["brown-asterisk-mini"].autoplace.max_probability = 0.1
	-- This has the color as prefix instead of suffix, I think because it's a vanilla plant.
data.raw["optimized-decorative"]["red-asterisk"].autoplace.max_probability = 0.1
data.raw["optimized-decorative"]["asterisk-mini-turquoise"].autoplace.max_probability = 0.1
data.raw["optimized-decorative"]["pita-blue"].autoplace.max_probability = 0.1
data.raw["optimized-decorative"]["pita-green"].autoplace.max_probability = 0.1
data.raw["optimized-decorative"]["red-pita"].autoplace.max_probability = 0.02
data.raw["optimized-decorative"]["pita-mini-turquoise"].autoplace.max_probability = 0.1
data.raw["optimized-decorative"]["pita-turquoise"].autoplace.max_probability = 0.025
data.raw["optimized-decorative"]["pita-mini-blue"].autoplace.max_probability = 0.02
data.raw["optimized-decorative"]["brown-fluff-dry"].autoplace.max_probability = 0.1
data.raw["optimized-decorative"]["crater2-medium"].autoplace = nil
data.raw["optimized-decorative"]["red-desert-bush"].autoplace.max_probability = 0.05
data.raw["optimized-decorative"]["asterisk-mauve"].autoplace.max_probability = 0.05
data.raw["optimized-decorative"]["asterisk-mini-mauve"].autoplace.max_probability = 0.08
data.raw["optimized-decorative"]["carpet-grass-purple"].autoplace.max_probability = 0.2
data.raw["optimized-decorative"]["croton-blue"].autoplace.max_probability = 0.1
