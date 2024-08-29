local Settings = require("code.util.settings")
if mods["HarderBasicLogistics"] ~= nil then
	Settings.setDefaultOrForce("HarderBasicLogistics-inserter-placement-blocking", "string", "allow-all")
	Settings.setDefaultOrForce("HarderBasicLogistics-remove-long-inserters", "bool", true)
	Settings.setDefaultOrForce("HarderBasicLogistics-shorten-underground-belts", "string", "all-1")
end