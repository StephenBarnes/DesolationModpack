local Settings = require("code.util.settings")
Settings.setDefaultOrForce("ir3ls-enabled", "string", "both")
Settings.setDefaultOrForce("ir3ls-batch-mode", "string", "batch") -- Batch into groups of 4 stacked ingots, to give bonus when using both lanes.