local Export = {}

Export.startupSetting = function(name)
	return settings.startup["Desolation-"..name].value
end

Export.setDefault = function(name, settingType, value)
	local s = data.raw[settingType .. "-setting"][name]
	if s == nil then
		log("Couldn't find setting "..name.." to set default value for.")
	else
		s.default_value = value
	end
end

return Export