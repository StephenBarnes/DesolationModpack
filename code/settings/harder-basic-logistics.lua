-- We want to encourage the use of containers, ingot stacking, and loaders. So make belts and inserters slower.
data.raw["double-setting"]["HarderBasicLogistics-belt-speed-multiplier"].default_value = 0.2 -- Reduced 1->0.2.
data.raw["double-setting"]["HarderBasicLogistics-splitter-speed-multiplier"].default_value = 0.2 -- Reduced 1->0.2.
data.raw["double-setting"]["HarderBasicLogistics-inserter-speed-multiplier"].default_value = 0.2 -- Reduced 1->0.2.

-- Only allow the IR3 loaders with bundlers/packers.
data.raw["string-setting"]["HarderBasicLogistics-special-loaders-inserters"].default_value = "ir3-loader-steam,ir3-loader,ir3-fast-loader,ir3-express-loader"
data.raw["string-setting"]["HarderBasicLogistics-special-machines"].default_value = "ir3-beltbox-steam,ir3-beltbox,ir3-fast-beltbox,ir3-express-beltbox,ic-containerization-machine-1,ic-containerization-machine-2,ic-containerization-machine-3"
data.raw["bool-setting"]["HarderBasicLogistics-containers-are-special"].default_value = true