local constants = require('constants')
local global_data = require("global-data")
local util = require('util')
local flib_orientation = require('__flib__.orientation')
local flib_math = require('__flib__.math')
local flib_table = require('__flib__.table')

local placer_control = {}

-- Make sure everything is valid, and if so, replace this entity
-- with the final intented building entity
-- This function snaps the entity onto adjacent trainfactory buildings
placer_control.on_entity_built = function(placed_entity, player_index)
    local mining_products = placed_entity.prototype.mineable_properties.products
    local target_entity_name = constants.placer_mapping[placed_entity.name]
    local direction = flib_orientation.to_direction(placed_entity.orientation)
    local ns_aligned = util.is_northsouth_aligned(direction)
    local force = placed_entity.force
    local surface = placed_entity.surface

    -- Find the rail directly under the center point and start from there
    local rail = surface.find_entity("straight-rail", placed_entity.position)
    if not rail then
        return util.fail_build(placed_entity, mining_products, player_index, surface, placed_entity.position, force,
            constants.result.NEED_RAILS)
    end

    -- center onto the rail
    local new_building_position = placed_entity.position
    if ns_aligned then
        new_building_position.x = flib_math.round(new_building_position.x + 1, 2) - 1
    else
        new_building_position.y = flib_math.round(new_building_position.y + 1, 2) - 1
    end

    -- We must manually "snap" to any similar entity within 2 tiles of the joint location in the
    -- direction of train travel, as if it was all rolling stock
    local nw_joiner = util.find_joinable_entity(surface, placed_entity.bounding_box,
        ns_aligned and defines.direction.north or defines.direction.west, target_entity_name) or {}
    local se_joiner = util.find_joinable_entity(surface, placed_entity.bounding_box,
        ns_aligned and defines.direction.south or defines.direction.east, target_entity_name) or {}


    local nw_data = global_data.get_machine_data_from_entity(nw_joiner.entity)
    local se_data = global_data.get_machine_data_from_entity(se_joiner.entity)

    -- Don't let the user place new machines in front of the integrated train stop
    if nw_data and nw_data.stop and
        (nw_data.stop.direction == defines.direction.south or nw_data.stop.direction == defines.direction.east) then
        return util.fail_build(placed_entity, mining_products, player_index, surface, placed_entity.position, force,
            constants.result.FRONT_OF_LINE)
    end
    if se_data and se_data.stop and
        (se_data.stop.direction == defines.direction.north or se_data.stop.direction == defines.direction.west) then
        return util.fail_build(placed_entity, mining_products, player_index, surface, placed_entity.position, force,
            constants.result.FRONT_OF_LINE)
    end

    if nw_data then
        new_building_position = nw_joiner.join_position
    elseif se_data then
        new_building_position = se_joiner.join_position
    else
        -- clamp to the nearest tile, to start off grid-aligned when possible
        if target_entity_name == constants.full_size_entity_name or
            target_entity_name == constants.full_size_disassemble_entity_name then
            -- full size entities should start out snapped to the train grid
            -- This allows integrated train stops to snap correctly.
            if ns_aligned then
                new_building_position.y = flib_math.round(new_building_position.y, 2)
            else
                new_building_position.x = flib_math.round(new_building_position.x, 2)
            end
        else
            return util.fail_build(placed_entity, mining_products, player_index, surface, placed_entity.position, force,
                constants.result.HALF_SIZE_NOT_SUPPORTED)
        end
    end

    -- Everything appears correct. Get ready to replace. First, destroy the placed entity,
    -- so that it won't collide with the new one
    placed_entity.destroy()

    -- Check to see if we can place the new, snapped entity. It's possible and normal that this
    -- might fail, because the coordinates have shifted
    if not surface.can_place_entity {
        name = target_entity_name,
        position = new_building_position,
        direction = direction,
        force = force,
        build_check_type = defines.build_check_type.manual,
    } then
        return util.fail_build(placed_entity, mining_products, player_index, surface, new_building_position, force,
            constants.result.COLLISION)
    end

    -- Create the intended entity, and raise the event.
    -- At that point, the bot and manual placement flow will be the same
    surface.create_entity {
        name = target_entity_name,
        position = new_building_position,
        direction = direction,
        force = force,
        raise_built = true,
    }
end

return placer_control
