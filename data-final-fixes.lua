local collision_mask_util = require "collision-mask-util"
local collision_data = require("prototypes.collision-mask")
local trainfactory_layer = collision_data and collision_data.layer or "layer-50" -- make YAFC happy
local flib_table = require("__flib__.table")

local straight_rail = data.raw["straight-rail"]["straight-rail"]
local curved_rail = data.raw["curved-rail"]["curved-rail"]

-- Add collision mask to curved rails to prevent building on them
curved_rail.collision_mask = flib_table.deep_copy(collision_mask_util.get_mask(curved_rail))
collision_mask_util.add_layer(curved_rail.collision_mask, trainfactory_layer)

-- Adjust rails selection priority so that we can't x-ray select them through the
-- train factory building, only x-ray select the locomotive
straight_rail.selection_priority = 49
curved_rail.selection_priority = 49
