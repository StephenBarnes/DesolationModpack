local Settings = require("code.util.settings")

-- Ignore the scattergun and photonic turrets
Settings.setDefault("searchlight-assault-setting-ignore-entries-list", "string", "scattergun-turret;photon-turret")

-- Turn off the animated spotlight effect
Settings.setDefault("searchlight-assault-enable-light-animation", "bool", false)

-- Set warning color and safe color to 230/230/230/230
-- Set alarm color to 255/255/255/230
--Settings.setDefault("searchlight-assault-safe-color", "string", "230,230,230,230")
--Settings.setDefault("searchlight-assault-warn-color", "string", "230,230,230,230")
--Settings.setDefault("searchlight-assault-alarm-color", "string", "255,255,255,230")
-- This doesn't work due to a bug. Opened an issue: https://github.com/bolderbrush10/SearchlightAssault/issues/5
-- The lines below work around the bug.
Settings.setDefault("250,190,0,230", "string", "230,230,230,230")
Settings.setDefault("230,25,25,230", "string", "230,230,230,230")
Settings.setDefault("20,230,20,230", "string", "255,255,255,230")