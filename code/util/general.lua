
local X = {} -- Exported values

X.die = function(message)
	log("ERROR: "..message)
	error(message)
	assert(false)
	return {}
end

return X