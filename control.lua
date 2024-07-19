require("code.control.notify-incorrect-mapgen-preset").register()

require("code.control.transfer-plate-unlocks-tech").register()

require("code.control.start-island-scan").register()

local ir3StartCalls = require("code.control.ir3-start-calls")

require("code.control.powered-pumps").register()

script.on_init(function()
	ir3StartCalls.onInit()
end)

script.on_load(function()
	ir3StartCalls.onLoad()
end)