local oreStackSize = 20
local crushedOreStackSize = 40
local powderStackSize = 60
local pureOreStackSize = 40
local processedStackSize = 100
local stackedStackSize = 30 -- so a stack of stacks holds 120 ingots, for 20% total space increase from stacking.
-- NOTE this breaks manual unstacking!
-- TODO rather just infer this from the stack size of the unstacked item.

local tweakStackSizeItems = {
	["stone"] = oreStackSize,
	["gravel"] = crushedOreStackSize,
	["silica"] = powderStackSize,
	["coal"] = oreStackSize,
	["carbon-crushed"] = crushedOreStackSize,
	["wood"] = oreStackSize,
	["wood-chips"] = crushedOreStackSize,
	["charcoal"] = crushedOreStackSize,
	["rubber-wood"] = oreStackSize,
	["rubber"] = processedStackSize,
	["copper-ore"] = oreStackSize,
	["copper-crushed"] = crushedOreStackSize,
	["tin-ore"] = oreStackSize,
	["tin-crushed"] = crushedOreStackSize,
	["gold-ore"] = oreStackSize,
	["gold-crushed"] = crushedOreStackSize,
	["graphitic-coke"] = processedStackSize,
	["solid-fuel"] = processedStackSize,
	["copper-pure"] = pureOreStackSize,
	["nickel-pure"] = pureOreStackSize,
	["tin-pure"] = pureOreStackSize,
	["lead-pure"] = pureOreStackSize,
	["iron-pure"] = pureOreStackSize,
	["chromium-pure"] = pureOreStackSize,
	["gold-pure"] = pureOreStackSize,
	["platinum-pure"] = pureOreStackSize,
	["sulfur"] = oreStackSize,
	["uranium-ore"] = oreStackSize,
	["uranium-238"] = pureOreStackSize,
	["uranium-235"] = pureOreStackSize,

	["stacked-stone-brick"] = stackedStackSize,
	["stacked-plastic-bar"] = stackedStackSize,
	["stacked-concrete-block"] = stackedStackSize,
	["stacked-copper-ingot"] = stackedStackSize,
	["stacked-tin-ingot"] = stackedStackSize,
	["stacked-bronze-ingot"] = stackedStackSize,
	["stacked-glass"] = stackedStackSize,
	["stacked-nanoglass"] = stackedStackSize,
	["stacked-iron-ingot"] = stackedStackSize,
	["stacked-gold-ingot"] = stackedStackSize,
	["stacked-lead-ingot"] = stackedStackSize,
	["stacked-steel-ingot"] = stackedStackSize,
	["stacked-brass-ingot"] = stackedStackSize,
	["stacked-nickel-ingot"] = stackedStackSize,
	["stacked-chromium-ingot"] = stackedStackSize,
	["stacked-platinum-ingot"] = stackedStackSize,
}
-- NOTE "solid-fuel" is coke, and "carbon-crushed" is crushed coal.

return tweakStackSizeItems