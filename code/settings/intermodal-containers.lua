local Settings = require("code.util.settings")

-- Set the size of the stack inserters to 3x3, not 4x4.
Settings.setDefaultOrForce("ic-machine-size", "string", "3×3")

-- Stacks per container; default is 0.2.
Settings.setDefaultOrForce("ic-stacks-per-container", "double", 1)

-- Set stack size of containers to 5.
Settings.setDefaultOrForce("ic-container-stack-size", "int", 10)

Settings.setDefaultOrForce("ic-stack-size-multiplier", "double", 1)