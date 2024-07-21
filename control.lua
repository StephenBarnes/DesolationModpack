require("code.control.notify-incorrect-mapgen-preset").register()

local transferPlateUnlocksTech = require("code.control.transfer-plate-unlocks-tech")

require("code.control.start-island-scan").register()

local ir3StartCalls = require("code.control.ir3-start-calls")

require("code.control.powered-pumps").register()

require("code.control.no-backer-names")

require("code.control.searchlight-assault").register()

script.on_init(function()
	ir3StartCalls.onInit()
	transferPlateUnlocksTech.onInit()
end)

script.on_load(function()
	ir3StartCalls.onLoad()
	transferPlateUnlocksTech.onLoad()
end)