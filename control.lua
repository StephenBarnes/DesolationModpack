require("code.control.notify-incorrect-mapgen-preset").register()
require("code.control.ir3-start-calls").register()

local transferPlateUnlocksTech = require("code.control.transfer-plate-unlocks-tech")
transferPlateUnlocksTech.register()

script.on_init(function()
	transferPlateUnlocksTech.onInit()
end)

script.on_load(function()
	transferPlateUnlocksTech.onLoad()
end)