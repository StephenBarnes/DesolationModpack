-- This file changes what tiles get autoplaced where.
-- Use noise layers defined in other files to determine whether we need buildable tiles (eg at resources) or not.

-- Disable autoplace for the hotter volcanic terrain, bc we want to use the greyer rock ones as buildable land.
data.raw.tile["volcanic-orange-heat-3"].autoplace = nil
data.raw.tile["volcanic-orange-heat-4"].autoplace = nil