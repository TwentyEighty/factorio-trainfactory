local collision_mask_util = require "collision-mask-util"
local collision_data = require("prototypes.collision-mask")
local flib_table = require("__flib__.table")

-- Add our custom collision mask to every object-like entity, except for straight rails,
-- which we need to build on
for _,entity in pairs(collision_mask_util.collect_prototypes_with_layer("object-layer")) do
    if entity.name ~= "straight-rail" then
        entity.collision_mask = flib_table.deep_copy(collision_mask_util.get_mask(entity))
        collision_mask_util.add_layer(entity.collision_mask, collision_data.layer)
    end
end

-- Adjust straight rails selection priority so that we can't x-ray select them through the
-- train factory building, only x-ray select the locomotive
data.raw["straight-rail"]["straight-rail"].selection_priority = 49
