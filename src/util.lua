local constants = require("constants")
local flib_area = require("__flib__.area")
local flib_direction = require("__flib__.direction")
local flib_table = require("__flib__.table")

local util = {}

-- Careful, sometimes there is no direction and it indicates "north"
util.is_northsouth_aligned = function(direction)
    return not (direction == defines.direction.east or direction == defines.direction.west)
end

util.opposite = function(direction)
    return (direction + 4) % 8
end

util.get_align = function(direction)
    if direction == defines.direction.north or direction == defines.direction.west then
        return constants.align.NW
    else
        return constants.align.SE
    end
end

util.normalize_preceding_dir = function(direction)
    return (util.is_northsouth_aligned(direction) and defines.direction.north or defines.direction.west)
end

util.normalize_proceeding_dir = function(direction)
    return flib_direction.opposite(util.normalize_preceding_dir(direction))
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

util.try_transfer_inventory = function(source_inv, dest_inv)
    source_inv.sort_and_merge()
    dest_inv.sort_and_merge()
    for i = 1, #source_inv do
        local stack = source_inv[i]
        if stack.valid_for_read then
            local count = dest_inv.insert(stack)
            stack.count = stack.count - count
        else
            -- The chests are sorted, this means we've hit the last stack
            break
        end
    end
end

util.find_joinable_entity = function(surface, bounding_box, direction, entity_name)
    local joint_info = constants.entity_joint_data[entity_name]
    local center = flib_area.center(bounding_box)

    local back_dir = flib_direction.opposite(direction)
    local vector = flib_direction.to_vector(direction,
        joint_info.joint_distance / 2 + joint_info.connection_distance / 2 + joint_info.snap_distance)
    local check_position = util.add_positions(center, vector)

    for _, name in pairs(constants.join_mapping[entity_name]) do
        entity = surface.find_entity(name, check_position)
        if entity then
            local next_joint_info = constants.entity_joint_data[name]
            local join_vector = flib_direction.to_vector(back_dir,
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

local function translate_message(rc)
    if type(rc) == "table" then return rc end

    if     rc == constants.result.OK then return nil
    elseif rc == constants.result.OCCUPIED then return {"message.occupied"}
    elseif rc == constants.result.NO_STOCK then return {"message.no-stock"}
    elseif rc == constants.result.CANT_BUILD then return {"message.cant-build"}
    elseif rc == constants.result.BROKEN then return {"message.broken"}
    elseif rc == constants.result.BUSY then return {"message.busy"}
    elseif rc == constants.result.NO_INSERT then return {"message.no-insert"}
    elseif rc == constants.result.NO_TRAIN then return {"message.no-train"}
    elseif rc == constants.result.NOT_EMPTY then return {"message.not-empty"}
    elseif rc == constants.result.TWO_GROUPS then return {"message.two-groups"}
    elseif rc == constants.result.FRONT_OF_LINE then return {"message.front-of-line"}
    elseif rc == constants.result.HALF_SIZE_NOT_SUPPORTED then return {"message.half-size-not-supported"}
    elseif rc == constants.result.COLLISION then return {"message.collision"}
    end
end

function util.show_message(result_code, surface, position, player_index)
    local message = translate_message(result_code)
    if message then
        if player_index then
            local player = game.players[player_index]
            player.create_local_flying_text {
                text = message,
                position = position,
            }
        else
            surface.create_entity {
                name = "flying-text",
                text = message,
                position = position,
            }
        end
    end
end

function util.fail_build(placed_entity, mining_products, player_index, surface, position, force, result_code)
    util.show_message(result_code, surface, position, player_index)
    if player_index then
        local player = game.players[player_index]
        if placed_entity.valid then
            player.mine_entity(placed_entity, true)
        else
            for i = 1, #mining_products do
                player.insert {
                    name = mining_products[i].name,
                    count = mining_products[i].amount
                }
            end
        end
    else
        if placed_entity.valid then
            placed_entity.order_deconstruction(force)
        end
    end
end

function util.show_group_message(group, result_code)
    local message = translate_message(result_code)
    if message then
        for _, machine in pairs(group.machines or {}) do
            util.show_message(result_code, machine.entity.surface, machine.entity.position)
        end
    end
end

return util
