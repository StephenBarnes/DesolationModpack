local Table = {}

Table.extend = function(t, l)
	for _, val in pairs(l) do
		table.insert(t, val)
	end
end

Table.concat = function(tables)
	local result = {}
	for _, t in pairs(tables) do
		for _, v in pairs(t) do
			table.insert(result, v)
		end
	end
	return result
end

Table.hasEntry = function(v, list)
	for _, entry in pairs(list) do
		if v == entry then return true end
	end
	return false
end

Table.stringProduct = function(strings1, strings2)
	-- Given two lists of strings, returns a list of all combinations of the two.
	local result = {}
	for _, s1 in pairs(strings1) do
		for _, s2 in pairs(strings2) do
			table.insert(result, s1 .. s2)
		end
	end
	return result
end

Table.copy = function(t)
	-- TODO delete this, should rather use that existing deepcopy function. Not sure if this is being used anywhere.
	local new = {}
	for k, v in pairs(t) do
		new[k] = v
	end
	return new
end

Table.overwriteInto = function(a, b)
	-- Given tables a and b, set b[.] to a[.] for all keys in b.
	for k, v in pairs(a) do
		b[k] = v
	end
end

Table.maybeGet = function(t, k)
	-- Equivalent to the "?." operator.
	if t == nil then return nil end
	return t[k]
end

Table.listToSet = function(l)
	-- Converts sth like {"a", "b", "c"} to {a=true, b=true, c=true}.
	local s = {}
	for _, v in pairs(l) do
		s[v] = true
	end
	return s
end

return Table