-- Make vehicles non-minable.
local function setUnminable(category)
	for _, v in pairs(data.raw[category]) do
		v.minable = nil
	end
end
if settings.startup["Desolation-unminable-vehicles"].value then
	setUnminable("car")
	setUnminable("spider-vehicle")
end
if settings.startup["Desolation-unminable-trains"].value then
	setUnminable("locomotive")
	setUnminable("cargo-wagon")
	setUnminable("fluid-wagon")
end