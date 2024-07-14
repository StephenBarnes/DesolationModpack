local noise = require "noise"

if settings.startup["Desolation-remove-mapgen-presets"] then
	log("Removing all existing mapgen presets!")
    for k, _ in pairs(data.raw["map-gen-presets"]["default"]) do
        if k ~= "type" and k ~= "name" and k ~= "default" then
            log("Removing mapgen preset: "..k)
            data.raw["map-gen-presets"]["default"][k] = nil
        end
    end
end

-- We can't completely remove the default map preset.
-- So instead, adjust the default map preset to make it generate almost only water, so people don't accidentally pick it.
data.raw["noise-expression"]["elevation"].expression = noise.define_noise_function(function(x, y, tile, map)
    local dist = noise.absolute_value(x) + noise.absolute_value(y)
	return noise.if_else_chain(noise.less_than(dist, 10), 10, -10)
end)