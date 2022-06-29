local constants = require("constants")
local flib_area = require("__flib__.area")
local flib_direction = require("__flib__.direction")
local flib_table = require("__flib__.table")

local util = {}

-- Careful, sometimes there is no direction and it indicates "north"
util.is_northsouth_aligned = function(direction)
    return not (direction == defines.direction.east or direction == defines.direction.west)
end

util.rotate = function(d1, d2)
    return (d2 + d1) % 8
end

util.add_positions = function(pos1, pos2)
    return { x = pos1.x + pos2.x, y = pos1.y + pos2.y }
end

util.sub_positions = function(pos1, pos2)
    return { x = pos1.x - pos2.x, y = pos1.y - pos2.y }
end

local get_blueprint_bounding_box = function(blueprint_entities)
    local box = {
        left_top = { x = math.huge, y = math.huge },
        right_bottom = { x = -math.huge, y = -math.huge },
    }

    for _, entity in pairs(blueprint_entities) do
        box = flib_area.expand_to_contain_position(box, entity.position)
    end

    return box
end

-- direction = north indicates no rotation. East = 90 rotation etc
util.translate_blueprint_entities = function(blueprint_entities, direction, position)
    local translated_blueprint_entities = {}

    -- We need to know where the overall blueprint bounding box is just to
    -- know the center point
    local bounding_box = get_blueprint_bounding_box(blueprint_entities)
    for _, bp_entity in pairs(blueprint_entities) do
        if flib_table.find(constants.building_entities, bp_entity.name) then
            local translated = flib_table.deep_copy(bp_entity)
            local normalized_position = util.sub_positions(bp_entity.position, flib_area.center(bounding_box))
            local vector = flib_direction.to_vector_2d(direction, -normalized_position.y, normalized_position.x)
            translated.position = util.add_positions(position, vector)
            table.insert(translated_blueprint_entities, translated)
        end
    end

    return translated_blueprint_entities
end

util.get_resulting_entity_name = function(placer_entity_name)
    if placer_entity_name == constants.full_size_placer_entity_name then
        return constants.full_size_entity_name
    elseif placer_entity_name == constants.half_size_placer_entity_name then
        return constants.half_size_entity_name
    end
end

-- Arbitrarily we decide that north and west are preceding,
-- south and east are proceeding
util.find_joinable_entity = function(surface, bounding_box, direction, entity_name, preceding)
    local joint_info = constants.entity_joint_data[entity_name]
    local center = flib_area.center(bounding_box)

    local back_dir = (direction == defines.direction.north or direction == defines.direction.south)
        and (preceding and defines.direction.north or defines.direction.south)
        or (preceding and defines.direction.west or defines.direction.east)
    local fwd_dir = flib_direction.opposite(back_dir)
    local vector = flib_direction.to_vector(back_dir,
        joint_info.joint_distance / 2 + joint_info.connection_distance / 2 + joint_info.snap_distance)
    local check_position = util.add_positions(center, vector)

    for _, name in pairs(constants.building_entities) do
        entity = surface.find_entity(name, check_position)
        if entity then
            local next_joint_info = constants.entity_joint_data[name]
            local join_vector = flib_direction.to_vector(fwd_dir,
                next_joint_info.connection_distance / 2 + joint_info.connection_distance / 2
                + next_joint_info.joint_distance / 2 + joint_info.joint_distance / 2)
            return {
                entity = entity,
                join_position = util.add_positions(
                    entity.position,
                    join_vector
                )
            }
        end
    end
end

return util
