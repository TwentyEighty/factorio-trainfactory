local constants = require('constants')
local util = require('util')
local flib_orientation = require('__flib__.orientation')
local flib_math = require('__flib__.math')

local placer_control = {}

local function fail_build(placed_entity, player_index, surface, position, force, text)
    if player_index then
        local player = game.players[player_index]
        player.create_local_flying_text {
            text = text,
            position = position,
        }

        if placed_entity.valid then
            player.mine_entity(placed_entity, true)
        else
            player.insert { name = constants.full_size_placer_item_name } -- DAVE TODO
        end
    else
        surface.create_entity {
            name = "flying-text",
            text = text,
            position = position,
        }
        if placed_entity.valid then
            placed_entity.order_deconstruction(force)
        end
    end
end

-- Make sure everything is valid, and if so, replace this entity
-- with the final intented building entity
placer_control.on_entity_built = function(placed_entity, player_index)
    local target_entity_name = util.get_resulting_entity_name(placed_entity.name)
    local direction = flib_orientation.to_direction(placed_entity.orientation)
    local ns_aligned = util.is_northsouth_aligned(direction)
    local force = placed_entity.force
    local surface = placed_entity.surface

    -- Find the rail directly under the center point and start from there
    local rail = surface.find_entity("straight-rail", placed_entity.position)
    if not rail then
        return fail_build(placed_entity, player_index, surface, placed_entity.position, force, "Must be built on rails")
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
    local preceding = util.find_joinable_entity(surface, placed_entity.bounding_box, direction, target_entity_name, true)
    local proceeding = util.find_joinable_entity(surface, placed_entity.bounding_box, direction, target_entity_name, false)

    if preceding then
        new_building_position = preceding.join_position
    elseif proceeding then
        new_building_position = proceeding.join_position
    else
        -- clamp to the nearest tile, to start off grid-aligned when possible
        if target_entity_name == constants.full_size_entity_name then
            if ns_aligned then
                new_building_position.y = flib_math.round(new_building_position.y, 1)
            else
                new_building_position.x = flib_math.round(new_building_position.x, 1)
            end
        elseif target_entity_name == constants.half_size_entity_name then
            new_building_position.x = flib_math.round(new_building_position.x + .25, .5) - .25
            if ns_aligned then
                new_building_position.y = flib_math.round(new_building_position.y + .25, .5) - .25
            else
                new_building_position.x = flib_math.round(new_building_position.x + .25, .5) - .25
            end
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
        return fail_build(placed_entity, player_index, surface, new_building_position, force, "Collision is preventing snap placement")
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
