-- Singleton-damnit pattern from jarg

local require = require
-- force canonical name require to ensure only one instance of this library
if ... ~= "__trainfactory__/prototypes/collision-mask.lua" then
    return require("__trainfactory__/prototypes/collision-mask.lua")
end

if collision_data then
    return collision_data
end

--- the rest of the library here
local collision_mask_util = require "collision-mask-util"
collision_data = {
    layer = collision_mask_util.get_first_unused_layer()
}

return collision_data
