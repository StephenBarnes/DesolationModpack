
-- Tweak vehicle inventory sizes.
if settings.startup["Desolation-modify-vehicle-inventories"] then
	data.raw.car["monowheel"].inventory_size = settings.startup["Desolation-inventory-size-monowheel"].value
	data.raw.car["heavy-roller"].inventory_size = settings.startup["Desolation-inventory-size-heavy-roller"].value
	data.raw.car["heavy-picket"].inventory_size = settings.startup["Desolation-inventory-size-heavy-picket"].value
	data.raw.car["car"].inventory_size = settings.startup["Desolation-inventory-size-car"].value
	data.raw.car["tank"].inventory_size = settings.startup["Desolation-inventory-size-tank"].value
	data.raw["spider-vehicle"]["hydrogen-airship"].inventory_size = settings.startup["Desolation-inventory-size-hydrogen-airship"].value
	data.raw["spider-vehicle"]["helium-airship"].inventory_size = settings.startup["Desolation-inventory-size-helium-airship"].value
	data.raw["spider-vehicle"]["spidertron"].inventory_size = settings.startup["Desolation-inventory-size-spidertron"].value
	-- TODO do cargo ships
end

-- Make vehicles non-minable.
function setUnminable(l)
	for k, v in pairs(l) do
		v.minable = nil
	end
end
if settings.startup["Desolation-unminable-vehicles"] then
	setUnminable(data.raw.car)
	setUnminable(data.raw["spider-vehicle"])
end
if settings.startup["Desolation-unminable-trains"] then
	setUnminable(data.raw.locomotive)
	setUnminable(data.raw["cargo-wagon"])
	setUnminable(data.raw["fluid-wagon"])
end
-- TODO make vehicles more expensive to produce as well, like x10 cost, so you don't just place a new one every time.

-- TODO make it impossible to walk while you have a vehicle in your inventory! Check how it's done by mods like the radioactivity mod, or Ultracube.