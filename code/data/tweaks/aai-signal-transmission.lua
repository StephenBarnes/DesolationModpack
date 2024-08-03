-- Desolation uses the AAI Signal Transmission mod for signal towers.
-- But we change all its sprites to look like radio towers, rather than big inter-planetary transmitters and receivers.
-- The sprites are from the RadioNetwork mod, which got them from some other mod (I don't know where exactly), which I have upscaled with AI.
-- We also need to change dimensions of buildings etc. to match.

-- AAI Signal Transmission registers its 2 entities as roboports called "aai-signal-sender" and "aai-signal-receiver".

-- Could package this separately and publish as a separate mod.
-- Would need to change tech prereqs (remove telemetry), ingredients (with special case for IR3), and copy locale strings separately.

-- Locale strings are changed separately in the locale file.

------------------------------------------------------------------------
-- Change images and shadows for the receiver and transmitter entities.
-- Also changing their sounds and collision boxes, and connection points for wires.

local senderSprite = "__Desolation__/graphics/radio-towers/transmitter.png"
local senderShadowSprite = "__Desolation__/graphics/radio-towers/transmitter-shadow.png"
local receiverSprite = "__Desolation__/graphics/radio-towers/receiver.png"
local receiverShadowSprite = "__Desolation__/graphics/radio-towers/receiver-shadow.png"

data.raw.roboport["aai-signal-sender"].base_animation = {
	layers = {
		{
			filename = senderSprite,
			priority = "high",
			width = 287,
			height = 753,
			frame_count = 1,
			line_length = 1,
			shift = util.by_pixel(12, -134),
			scale = 0.5,
			animation_speed = 1,
		},
		{
			draw_as_shadow = true,
			filename = senderShadowSprite,
			priority = "high",
			width = 796,
			height = 240,
			frame_count = 1,
			line_length = 1,
			--shift = util.by_pixel(188, 5),
			shift = util.by_pixel(197, 19),
			scale = 0.5,
			animation_speed = 1,
		},
	},
}
data.raw.roboport["aai-signal-sender"].collision_box = {{-1.5, -1.3}, {1.5, 1.3}}
data.raw.roboport["aai-signal-sender"].selection_box = {{-1.5, -1.5}, {1.5, 1.5}}
data.raw.roboport["aai-signal-sender"].drawing_box = {{-2, -9}, {7, 1.5}}
local wirePos = {
	red = { 1.2, -0.7 },
	green = { -0.2, 0.6 },
}
data.raw.roboport["aai-signal-sender"].circuit_wire_connection_point = {
	wire = wirePos,
	shadow = wirePos,
}
data.raw.roboport["aai-signal-sender"].open_door_trigger_effect = nil
data.raw.roboport["aai-signal-sender"].close_door_trigger_effect = nil
data.raw.roboport["aai-signal-sender"].build_sound = data.raw.radar.radar.build_sound
data.raw.roboport["aai-signal-sender"].working_sound = data.raw.radar.radar.working_sound
data.raw.roboport["aai-signal-sender"].is_military_target = true

-- For the receiver, from base to top-left of shadow is (62, -96). From there to center of shadow is (319, 77). So, from base to center of shadow is (62 + 319, -96 + 77) = (381, -19). Divide by 2 (for scale 0.5) to get (190, -10). Then negate for the other direction.
-- And for receiver's main sprite, from base to top-left of image is (-113, -597). Then from there to center is (110, 355). So, from base to center of image is (-113 + 110, -597 + 355) = (-3, -242). Divide by 2 (for scale 0.5) to get (-1.5, -121). Then negate for the other direction.
data.raw.roboport["aai-signal-receiver"].base_animation = {
	layers = {
		{
			filename = receiverSprite,
			priority = "high",
			width = 221,
			height = 711,
			frame_count = 1,
			line_length = 1,
			shift = util.by_pixel(-2, -121),
			scale = 0.5,
			animation_speed = 1,
		},
		{
			draw_as_shadow = true,
			filename = receiverShadowSprite,
			priority = "high",
			width = 637,
			height = 155,
			frame_count = 1,
			line_length = 1,
			--shift = util.by_pixel(175, 24),
			shift = util.by_pixel(190, -10),
			scale = 0.5,
			animation_speed = 1,
		},
	},
}
data.raw.roboport["aai-signal-receiver"].collision_box = {{-1.5, -1.3}, {1.5, 1.3}}
data.raw.roboport["aai-signal-receiver"].selection_box = {{-1.5, -1.5}, {1.5, 1.5}}
data.raw.roboport["aai-signal-receiver"].drawing_box = {{-2, -9}, {7, 1.5}}
local receiverWirePos = {
	red = { -0.7, -0.3 },
	green = { 0.7, 0 },
}
data.raw.roboport["aai-signal-receiver"].circuit_wire_connection_point = {
	wire = receiverWirePos,
	shadow = receiverWirePos,
}
data.raw.roboport["aai-signal-receiver"].open_door_trigger_effect = nil
data.raw.roboport["aai-signal-receiver"].close_door_trigger_effect = nil
data.raw.roboport["aai-signal-receiver"].build_sound = data.raw.radar.radar.build_sound
data.raw.roboport["aai-signal-receiver"].working_sound = data.raw.radar.radar.working_sound
data.raw.roboport["aai-signal-receiver"].is_military_target = true

------------------------------------------------------------------------
-- Change icons for items.

data.raw.item["aai-signal-sender"].icon = "__Desolation__/graphics/radio-towers/transmitter-item.png"
data.raw.item["aai-signal-sender"].icon_size = 64
data.raw.item["aai-signal-sender"].icon_mipmaps = 4
data.raw.item["aai-signal-receiver"].icon = "__Desolation__/graphics/radio-towers/receiver-item.png"
data.raw.item["aai-signal-receiver"].icon_size = 64
data.raw.item["aai-signal-receiver"].icon_mipmaps = 4

------------------------------------------------------------------------
-- Change technology

-- Tech icon
data.raw.technology["aai-signal-transmission"].icon = "__Desolation__/graphics/radio-towers/radio-tech.png"
data.raw.technology["aai-signal-transmission"].icon_size = 256
data.raw.technology["aai-signal-transmission"].icon_mipmaps = 2

data.raw.technology["aai-signal-transmission"].prerequisites = {"telemetry", "circuit-network"}

------------------------------------------------------------------------
-- Change energy consumption

-- For comparison, a radar uses 300kW.
data.raw.roboport["aai-signal-sender"].energy_usage = "300kW"
data.raw.roboport["aai-signal-receiver"].energy_usage = "200kW"
-- TODO change the size of the battery / whatever too.

------------------------------------------------------------------------
-- Change recipes

data.raw.recipe["aai-signal-sender"].ingredients = {
	{"copper-coil", 2},
	{"iron-beam", 16},
	{"iron-stick", 16},
	{"copper-cable-heavy", 2},
}
data.raw.recipe["aai-signal-receiver"].ingredients = {
	{"iron-beam", 12},
	{"iron-stick", 12},
	{"copper-cable-heavy", 4},
}