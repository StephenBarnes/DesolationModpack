local function setFuel(type, name, slots, categories)
	data.raw[type][name].burner.fuel_inventory_size = slots
	data.raw[type][name].burner.burnt_inventory_size = slots
	data.raw[type][name].burner.fuel_categories = categories
end

return {
	setFuel = setFuel,
}