local global_data = require("global-data")
local constants = require("constants")
local util = require("util")
local flib_table = require("__flib__.table")
local flib_direction = require("__flib__.direction")

local building_control = {}

building_control.on_entity_built = function(entity, player_index, tags)
    local machine_data = global_data.add_new_machine_data(entity, tags)

    local fuel_box_placement = constants.fuel_box_placement[entity.name]
    for i=1,2 do
        local x = (i == 2) and -fuel_box_placement.x or fuel_box_placement.x
        machine_data.containers[i] = entity.surface.create_entity {
            force = entity.force,
            name = "trainfactory-fuel-and-equipment-container",
            position = util.add_positions(entity.position, flib_direction.to_vector_2d(entity.direction, fuel_box_placement.y, x)),
        }
        machine_data.containers[i].link_id = constants.linked_chest_namespace + entity.unit_number
    end

    -- Find linkable machines to group together
    local preceding = util.find_joinable_entity(entity.surface, entity.bounding_box, entity.direction, entity.name, true)
    local proceeding = util.find_joinable_entity(entity.surface, entity.bounding_box, entity.direction, entity.name, false)

    if preceding and proceeding then
        global_data.join_groups(
            global_data.get_group_from_entity(preceding.entity),
            global_data.get_group_from_entity(proceeding.entity),
            machine_data
        )
    else
        local group_data = nil
        local add_to_front = false
        local new = false
        if preceding then
            group_data = global_data.get_group_from_entity(preceding.entity)
        elseif proceeding then
            group_data = global_data.get_group_from_entity(proceeding.entity)
            add_to_front = true
        else
            group_data = global_data.add_new_group(machine_data.id, tags)
            new = true
        end

        global_data.add_machines_to_group(group_data, { machine_data.id }, add_to_front, new)
    end
end

building_control.on_entity_removed = function(entity, player_index)
    local machine_data = global_data.get_machine_data_from_entity(entity)
    if machine_data then
        for _,container in pairs(machine_data.containers) do
            container.destroy()
        end
    end
    global_data.remove_machine_data(entity)
end

-- we might slightly miss the rail bounding box with find_entity
function find_a_rail(surface, position, direction)
    local rails = surface.find_entities_filtered {
        name = "straight-rail",
        area = {
            { position.x - 0.25, position.y - 0.25 },
            { position.x + 0.25, position.y + 0.25 }
        },
        direction = direction,
    }
    if next(rails) then
        return rails[1]
    end
    return nil
end

-- We want to make sure there is a continuous track running from the first
-- machine to the last machine.
-- 1. It has to be big enough to fit the first and last rolling stock
-- 2. We want to support trains as soon as they are researched, this means
--    we're not going to rely on signals or stops that might be already
--    on the track
-- 3. Check for rolling stock on the tracks while we're at it
function check_rail_segment(group_data)
    local num_machines = flib_table.size(group_data.machines)
    local machine_data_1 = global_data.get_machine_data(group_data.machines[1])
    local machine_data_2 = global_data.get_machine_data(group_data.machines[num_machines])
    if not machine_data_1 or not machine_data_2 then
        return constants.check_rail_segment_result.ERROR
    end

    local e1 = machine_data_1.entity
    local e1_joints = constants.entity_joint_data[e1.name]
    local e2 = machine_data_2.entity
    local e2_joints = constants.entity_joint_data[e2.name]

    local start_pos = { x = e1.position.x - e1_joints.joint_distance / 2 - e1_joints.connection_distance / 2,
        y = e1.position.y }
    local end_pos = { x = e2.position.x + e2_joints.joint_distance / 2 + e2_joints.connection_distance / 2,
        y = e2.position.y }

    -- Expect to find a straight rail located at both the start and end joint positions
    local rail_start = find_a_rail(e1.surface, start_pos, defines.direction.east)
    local rail_end = find_a_rail(e2.surface, end_pos, defines.direction.east)

    if not rail_start or not rail_end then return constants.check_rail_segment_result.BROKEN end

    -- Expect that we have a continuous connected straight rail from A to B
    local rail = rail_start
    repeat
        rail = rail.get_connected_rail {
            rail_direction = defines.rail_direction.front,
            rail_connection_direction = defines.rail_connection_direction.straight
        }
        if not rail or rail.position.x > rail_end.position.x then
            return constants.check_rail_segment_result.BROKEN
        end
    until rail == rail_end

    -- Passed the straight rail connectivity check. Now look for trains
    -- Make this search a little larger so we don't accidentally connect
    -- to a train just leaving the factory
    local rolling_stock = e1.surface.find_entities_filtered({
        area = { { start_pos.x - e1_joints.snap_distance * 2, start_pos.y },
            { end_pos.x + e2_joints.snap_distance * 2, end_pos.y } },
        type = constants.rolling_stock_types,
    })

    if next(rolling_stock) then
        return constants.check_rail_segment_result.NOT_CLEAR
    else
        return constants.check_rail_segment_result.CLEAR
    end
end

local function parse_inventory(contents)
    local data = {}
    for item_name, count in pairs(contents) do
        local item_proto = game.item_prototypes[item_name]
        local entity = item_proto.place_result and game.entity_prototypes[item_proto.place_result.name]
        if entity and flib_table.find(constants.rolling_stock_types, entity.type) then
            data.rolling_stock_name = entity.name
            data.rolling_stock_item_name = item_name
        else
            return nil
        end
    end

    return data
end

local function prepare_build_train(group_data)
    local build_data = {}
    for _, machine_id in pairs(group_data.machines) do
        local machine_data = global_data.get_machine_data(machine_id)
        if not machine_data or not machine_data.entity then return nil end

        local output_inventory = machine_data.entity.get_output_inventory()
        if not output_inventory or #output_inventory == 0 or output_inventory.count_empty_stacks() > 0 then return nil end

        local parsed_inventory = parse_inventory(output_inventory.get_contents())
        if not parsed_inventory then return nil end

        build_data[machine_id] = parsed_inventory
        build_data[machine_id].output_inventory = output_inventory
        build_data[machine_id].machine_data = machine_data
    end

    return build_data
end

local function build_train(group_data, train_build_data)
    -- Make sure each train can be placed
    for _, build_data in pairs(train_build_data) do
        local machine_entity = build_data.machine_data.entity
        if not machine_entity.surface.can_place_entity {
            name = build_data.rolling_stock_name,
            position = machine_entity.position,
            direction = machine_entity.direction,
            force = machine_entity.force,
            build_check_type = defines.build_check_type.manual,
        } then
            return false
        end
    end

    local train = nil
    for _, build_data in pairs(train_build_data) do
        local machine_data = build_data.machine_data
        local machine_entity = machine_data.entity
        local rolling_stock_entity = machine_entity.surface.create_entity {
            name = build_data.rolling_stock_name,
            position = machine_entity.position,
            direction = machine_entity.direction,
            force = machine_entity.force,
            build_check_type = defines.build_check_type.manual,
            color = machine_data.config.color,
        }
        local rolling_stock_item_count = build_data.output_inventory.get_item_count(build_data.rolling_stock_item_name)
        build_data.output_inventory.remove({
            name = build_data.rolling_stock_item_name,
            count = 1,
        })

        local fuel_inventory = rolling_stock_entity.get_fuel_inventory()
        local burner_proto = game.entity_prototypes[build_data.rolling_stock_name].burner_prototype
        if fuel_inventory and burner_proto and machine_data.containers[1] then
            -- The train takes fuel, try to find it in the fuel/equipment box
            local burner = game.entity_prototypes[build_data.rolling_stock_name].burner_prototype
            local container_inventory = machine_data.containers[1].get_inventory(defines.inventory.chest)

            for i=1,#container_inventory do
                if container_inventory[i] and container_inventory[i].valid_for_read then
                    local item_stack = container_inventory[i]
                    if burner.fuel_categories[item_stack.prototype.fuel_category] then
                        local count = math.ceil(constants.fuel_joules_to_insert / item_stack.prototype.fuel_value)
                        local removed = container_inventory.remove({
                            name = item_stack.name,
                            count = count
                        })
                        local inserted = fuel_inventory.insert({
                            name = item_stack.name,
                            count = removed
                        })
                    end
                end
            end
        end
        train = rolling_stock_entity.train
    end
    if train and group_data.config.station_name and string.len(group_data.config.station_name) > 0 then
        train.manual_mode = false
        train.schedule = {
            current = 1,
            records = { {
                station = group_data.config.station_name
            } }
        }
    end
end

building_control.on_entity_settings_pasted = function(player, source, dest)
    local machine_data_src = global_data.get_machine_data_from_entity(source)
    local group_data_src = global_data.get_group_from_entity(source)

    if machine_data_src and group_data_src then
        global_data.machine_config_change(dest, machine_data_src.config)
        -- global_data.group_config_change(dest, group_data_src.config)
    end
end

building_control.on_nth_tick = function(event)
    for _, group_data in pairs(global.groups) do
        -- First make sure all machines are in the same rail segment
        local result = check_rail_segment(group_data)

        if result == constants.check_rail_segment_result.CLEAR then
            local train_build_data = prepare_build_train(group_data)
            if train_build_data then
                build_train(group_data, train_build_data)
            end
        elseif result == constants.check_rail_segment_result.NOT_CLEAR then
            -- local message = constants.check_rail_segment_message[result]
            -- global_data.show_group_update(group_data, message)
        else
            local message = constants.check_rail_segment_message[result]
            global_data.show_group_update(group_data, message)
        end
    end
end

return building_control
