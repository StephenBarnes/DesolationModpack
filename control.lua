require("code.control.notify-incorrect-mapgen-preset").register()

local ir3StartCalls = require("code.control.ir3-start-calls")

require("code.control.transfer-plate-unlocks-tech").register()

script.on_init(function()
	ir3StartCalls.onInit()
end)

script.on_load(function()
	ir3StartCalls.onLoad()
end)