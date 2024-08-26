--[[ This file modifies IR3's metal casting machines.
Specifically, I want to sync the sounds and animation with the recipes, and I also want to make the numbers more round.

Metal cast machines have speed 2.5, and recipes 1s. So actually they take 0.4s.
Item is called steel-cast, but when placed you get ingot-cast entity. There's no steel-cast entity.
So, before modifying the animations and sounds for this, they don't seem to be synced to the recipes at all.
	Animation has 80 frames and animation speed 0.75. Animations play at 30 frames per second, so this lasts (80 / 30) / 0.75 = 3.555 seconds.
	Working sound has fade-in ticks 10 and fade-out ticks 30. Seems to correspond to metal cooling at first, but then desyncs when you leave the machine running.
	Output is much greater than the visible casting. About 7 plates output for every animation that plays, very roughly.
	Recipe takes 0.4 seconds. Animation should take around 3.555 seconds. That's 3.55 / 0.4 = 8.89 outputs per animation, which is roughly what I saw.
I think I'll change:
	Cast machine speed to 1.
	Recipe times to some lower number, not sure what.
	Animation speed is then determined by that recipe time.
	This is drastically reducing the output per casting machine.
		So, maybe also reduce the ingredients of them, I guess? Or not, just have a row of them. They're cheap, no energy needed. And they look satisfying.
]]

local animationSpeed = 2.6666666666667 -- Can adjust this freely. Base IR3 has 0.75. Setting to 2.6667 makes recipes 1s.
local numFrames = 80 -- Constant, set by IR3.
local animationFramesPerSecond = 30 -- Constant, set by the engine.
local animationTime = (numFrames / animationFramesPerSecond) / animationSpeed -- This is the time per animation in seconds, so time per recipe.
local itemClasses = {"gear-wheel", "ingot", "plate", "rod"}
for _, itemClass in pairs(itemClasses) do
	data.raw.furnace[itemClass.."-cast"].crafting_speed = 1 -- Changed speed 2.5 => 1.

	-- Set animation speed of the casting machine.
	for _, vis in pairs(data.raw.furnace[itemClass.."-cast"].working_visualisations) do
		vis.animation.animation_speed = animationSpeed
	end

	-- Sync sounds to animation.
	data.raw.furnace[itemClass.."-cast"].working_sound.match_progress_to_activity = true
	data.raw.furnace[itemClass.."-cast"].working_sound.fade_in_ticks = 0
	data.raw.furnace[itemClass.."-cast"].working_sound.fade_out_ticks = 0

	-- The current sound file is a "metal hiss" which is 3.44 seconds long. Longer than I'm making the animation loop, so it doesn't play every loop.
	-- So, change it to a different sound?
	--data.raw.furnace[itemClass.."-cast"].working_sound.sound.filename = "__IndustrialRevolution3Assets1__/sound/medical-pack.ogg"
	--data.raw.furnace[itemClass.."-cast"].working_sound.sound.filename = "__base__/sound/gate-close-1.ogg"
	--data.raw.furnace[itemClass.."-cast"].working_sound.sound.filename = "__base__/sound/fight/flamethrower-end.ogg"
	data.raw.furnace[itemClass.."-cast"].working_sound.sound.filename = "__core__/sound/landfill-small-5.ogg"

	-- Reduce audible distance modifier, otherwise you hear it from far away.
	data.raw.furnace[itemClass.."-cast"].working_sound.audible_distance_modifier = 0.7

	--[[
	-- Editing the descriptions to have suffix saying how many components are cast per second.
	local numPerSecond = (itemClass == "rod") and 4 or 2
	data.raw.furnace[itemClass.."-cast"].localised_description = {
		"", -- Concatenate strings.
		data.raw.furnace[itemClass.."-cast"].localised_description,
		{"shared-description.casting-machine-suffix", numPerSecond},
	}
	-- In locale file:
	> casting-machine-suffix=\nCasts __1__ component__plural_for_parameter_1_{1=|rest=s}__ per second.
	]]
end

-- Create a set of recipe categories whose times we want to modify.
local castingCategorySet = {}
for _, itemClass in pairs(itemClasses) do
	castingCategorySet[itemClass.."-casting"] = true
end

-- Modify the times of all recipes in casting categories, so they match the animation time.
for _, recipe in pairs(data.raw.recipe) do
	if castingCategorySet[recipe.category] then
		recipe.energy_required = animationTime
	end
end