-- This file tweaks the Bulk Rail Loaders mod, which is a dependency of Desolation.
-- There's also a file to tweak settings, and a file that runs in control-stage and changes allowed items.

-- Move crafting recipes around to make things neater.
data.raw.item["railloader"].subgroup = "train-transport"
data.raw.item["railloader"].order = "a[train-system]-j"
data.raw.item["railunloader"].subgroup = "train-transport"
data.raw.item["railunloader"].order = "a[train-system]-j2"

-- Change capacity of the loader and unloader.
-- The mod has a setting for the capacity of the loader, which is 320 by default. I'm hiding that setting, and then overwriting the capacity here.
local wagonSize = data.raw["cargo-wagon"]["cargo-wagon"].inventory_size
data.raw.container["railloader-chest"].inventory_size = wagonSize * 2
data.raw.container["railunloader-chest"].inventory_size = wagonSize * 2

-- TODO tweak recipes
-- TODO tweak techs
-- TODO tweak allowed items