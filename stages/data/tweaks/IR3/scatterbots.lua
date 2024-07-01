-- Make scatterbots a bit better, by making them slower, so that you can throw them at enemy bases and run away, and they won't follow so fast. Could make them non-following, but that makes them not subject to the follower cap, which makes them too powerful.
--data.raw["combat-robot"]["scatterbot"].follows_player -- not changing this.
data.raw["combat-robot"]["scatterbot"].speed = 0.0008 -- 0.0025 -> 0.0008.
-- Actually TODO maybe remove this change. Because there are far fewer enemy bases, and we don't want to make it too easy to kill enemy bases by just spamming scatterbots.

-- TODO make scatter bots require charged steam cells, and get rid of one of the plates requirements.