local noise = require "noise"

local elevationFunc = noise.define_noise_function(function(x, y, tile, map)
	local scaleVar = noise.var("control-setting:Desolation-scale:frequency:multiplier")
	local scaledDistance = tile.distance / scaleVar
	return noise.ridge(scaledDistance, -20, 20)
end)

data:extend{
	{
		type = "noise-expression",
		name = "Desolation-islands-elevation",
		intended_property = "elevation",
		expression = elevationFunc,
	},
}