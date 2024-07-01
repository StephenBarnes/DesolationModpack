local Table = {}

Table.extend = function(t, l)
	for _, val in pairs(l) do
		table.insert(t, val)
	end
end

Table.copy = function(t)
	local new = {}
	for k, v in pairs(t) do
		new[k] = v
	end
	return new
end

return Table