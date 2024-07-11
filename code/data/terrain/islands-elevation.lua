local noise = require "noise"

local simpleElevationFunc = {
	type = "literal-number",
	literal_value = 100,
}

data:extend{
	{
		type = "noise-expression",
		name = "Desolation-islands-elevation",
		intended_property = "elevation",
		expression = simpleElevationFunc,
	},
}