local flib_table = require('__flib__.table')
local flib_direction = require("__flib__.direction")
local global_data = require("global-data")
local util = require("util")
local constants = require("constants")

local tick = {}

local function train_present(group)
    if group.stop.trains_count > 0 then return true end
end

local function has_rolling_stock_output(machine)
    local output_inventory = machine.entity.get_output_inventory()
    return not output_inventory.is_empty()
end

-- we might slightly miss the rail bounding box with find_entity
local function find_a_rail(surface, position, dir1, dir2)
    local rails = surface.find_entities_filtered {
        name = "straight-rail",
        area = {
            { position.x - 0.25, position.y - 0.25 },
            { position.x + 0.25, position.y + 0.25 }
        },
        direction = { dir1, dir2 },
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
local function check_rail_segment(group)
    local back = util.normalize_preceding_dir(group.stop.direction)
    local forward = flib_direction.opposite(back)
    local e1 = nil
    local e2 = nil
    for _, machine in pairs(group.machines) do
        local e = machine.entity
        if not e1 or e.position.x < e1.position.x or e.position.y < e1.position.y then
            e1 = e
        end
        if not e2 or e.position.x > e2.position.x or e.position.y > e2.position.y then
            e2 = e
        end
    end

    local e1_joints = constants.entity_joint_data[e1.name]
    local e2_joints = constants.entity_joint_data[e2.name]

    local start_pos = util.add_positions(e1.position, flib_direction.to_vector(back, e1_joints.joint_distance / 2))
    local end_pos = util.add_positions(e2.position, flib_direction.to_vector(forward, e2_joints.joint_distance / 2))

    -- Expect to find a straight rail located at both the start and end joint positions
    local rail_start = find_a_rail(e1.surface, start_pos, back, forward)
    local rail_end = find_a_rail(e2.surface, end_pos, back, forward)
    if not rail_start or not rail_end then return constants.result.BROKEN end

    local rail_direction = (
        rail_start.direction == defines.direction.south or rail_start.direction == defines.direction.east)
        and defines.rail_direction.front or defines.rail_direction.back

    -- Expect that we have a continuous connected straight rail from A to B
    local rail = rail_start
    repeat
        rail = rail.get_connected_rail {
            rail_direction = rail_direction,
            rail_connection_direction = defines.rail_connection_direction.straight
        }
        if not rail or rail.position.x > rail_end.position.x or rail.position.y > rail_end.position.y then
            return constants.result.BROKEN
        end
    until rail.unit_number == rail_end.unit_number

    -- Passed the straight rail connectivity check. Now look for trains
    -- Make this search a little larger so we don't accidentally connect
    -- to a train just leaving the factory
    start_pos = util.add_positions(start_pos,
        flib_direction.to_vector(back, e1_joints.connection_distance / 2 + e1_joints.snap_distance))
    end_pos = util.add_positions(end_pos,
        flib_direction.to_vector(forward, e2_joints.connection_distance / 2 + e2_joints.snap_distance))
    local rolling_stock = e1.surface.find_entities_filtered({
        area = { top_right = start_pos, bottom_left = end_pos },
        type = constants.rolling_stock_types,
    })

    if next(rolling_stock) then
        return constants.result.OCCUPIED
    end
end

local function try_insert_fuel(machine, rolling_stock)
    local burner_proto = game.entity_prototypes[rolling_stock.name].burner_prototype
    if burner_proto then
        local fuel_inventory = rolling_stock.get_fuel_inventory()
        if fuel_inventory and fuel_inventory[1].valid and fuel_inventory[1].count == 0 then
            -- The train takes fuel, try to find it in the fuel/equipment box
            local fuel_equipment_container_inventory = machine.containers[1].get_inventory(defines.inventory.chest)
            for i = 1, #fuel_equipment_container_inventory do
                if fuel_equipment_container_inventory[i] and fuel_equipment_container_inventory[i].valid_for_read then
                    local item_stack = fuel_equipment_container_inventory[i]
                    if burner_proto.fuel_categories[item_stack.prototype.fuel_category] then
                        local name = item_stack.name
                        local count = math.ceil(constants.fuel_joules_to_insert / item_stack.prototype.fuel_value)
                        local removed = fuel_equipment_container_inventory.remove({
                            name = name,
                            count = count
                        })
                        fuel_inventory.insert({
                            name = name,
                            count = removed
                        })
                    end
                end
            end
        end
    end
end

local function build_train(group)
    -- Make sure each train can be placed
    for _, machine in pairs(group.machines) do
        local entity = machine.entity
        local output_inventory = entity.get_output_inventory()
        if not output_inventory[1] or not output_inventory[1].valid_for_read then
            return constants.result.NO_STOCK
        end

        if not entity.surface.can_place_entity {
            name = output_inventory[1].name,
            position = entity.position,
            direction = entity.direction,
            force = entity.force,
            build_check_type = defines.build_check_type.manual,
        } then
            return constants.result.CANT_BUILD
        end
    end

    local train = nil
    for _, machine in pairs(group.machines) do
        local entity = machine.entity
        local output_inventory = entity.get_output_inventory()
        local rolling_stock_entity = entity.surface.create_entity {
            name = output_inventory[1].name,
            position = entity.position,
            direction = entity.direction,
            force = entity.force,
            color = machine.config.color,
        }
        output_inventory.remove({
            name = output_inventory[1].name,
            count = 1,
        })

        try_insert_fuel(machine, rolling_stock_entity)

        train = rolling_stock_entity.train
    end

    if train and group.config.station_name and string.len(group.config.station_name) > 0 then
        train.manual_mode = false
        train.schedule = {
            current = 1,
            records = { {
                station = group.config.station_name,
            } }
        }
    end
end

local function update_assemble_group(group)
    if not group.stop then return end

    -- Fastest thing to check for is a train already present
    if train_present(group) then
        util.show_group_message(group, constants.result.OCCUPIED)
        return
    end

    -- Second fastest thing to check is if each machine has output ready
    for _, machine in pairs(group.machines) do
        if not has_rolling_stock_output(machine) then
            util.show_group_message(group, constants.result.NO_STOCK)
            return
        end
    end

    -- Finally, check for continous rails
    local error = check_rail_segment(group)
    if error then
        util.show_group_message(group, error)
        return
    end

    error = build_train(group)
    if error then
        util.show_group_message(group, error)
    end
end

local function try_transfer_output(group_data)
    for _, machine in pairs(group_data.machines) do
        local output_inventory = machine.entity.get_inventory(defines.inventory.furnace_result)
        local container_inventory = machine.containers[1].get_inventory(defines.inventory.chest)
        util.try_transfer_inventory(output_inventory, container_inventory)
    end
end

local function can_disassemble_train(group)
    for _, machine in pairs(group.machines) do
        -- Make sure nothing is currently being crafted
        if machine.entity.is_crafting() then return constants.result.BUSY end

        -- If there's a rolling stock present, make sure it can be inserted into the crafting machine
        local found_rolling_stock = machine.entity.surface.find_entities_filtered({
            position = machine.entity.position,
            type = constants.rolling_stock_types,
        })
        local input_inventory = machine.entity.get_inventory(defines.inventory.furnace_source)

        for _, rolling_stock in pairs(found_rolling_stock) do
            local mining_products = rolling_stock.prototype.mineable_properties.products
            if next(mining_products) then
                if not input_inventory.can_insert({
                    name = mining_products[1].name,
                    count = mining_products[1].amount or 1,
                }) then
                    return constants.result.NO_INSERT
                end
            end
        end
    end
end

local function disassemble_train(group)
    for _, machine in pairs(group.machines) do
        local found_rolling_stock = machine.entity.surface.find_entities_filtered({
            position = machine.entity.position,
            type = constants.rolling_stock_types,
        })
        local input_inventory = machine.entity.get_inventory(defines.inventory.furnace_source)
        local fuel_equipment_container_inventory = machine.containers[1].get_inventory(defines.inventory.chest)

        -- First, we need to completely empty out the fuel/burnt/etc
        local not_empty = false
        for _, rolling_stock in pairs(found_rolling_stock) do
            for _, inv in pairs { defines.inventory.fuel, defines.inventory.burnt_result } do
                local source_env = rolling_stock.get_inventory(inv)
                if source_env then
                    util.try_transfer_inventory(source_env, fuel_equipment_container_inventory)
                    if source_env.get_item_count() > 0 then
                        not_empty = true
                    end
                end
            end
        end

        try_transfer_output(group)

        if not_empty then
            return constants.result.NOT_EMPTY
        end

        -- cars/locos are empty, stick them into the furnace
        for _, rolling_stock in pairs(found_rolling_stock) do
            rolling_stock.mine { inventory = input_inventory }
        end
    end
end

local function update_disassemble_group(group)
    if not group.stop then return end

    local stop = group.stop
    local stopped_train = stop.get_stopped_train()

    try_transfer_output(group)
    if not stopped_train then
        util.show_group_message(group, constants.result.NO_TRAIN)
        return
    end

    local error = can_disassemble_train(group)
    if error then
        util.show_group_message(group, error)
        return
    end

    error = disassemble_train(group)
    if error then
        util.show_group_message(group, error)
    end
end

function tick.bucket_update(bucket)
    for _, group in pairs(bucket) do
        if group.type == "assemble" then
            update_assemble_group(group)
        elseif group.type == "disassemble" then
            update_disassemble_group(group)
        end
    end
end

return tick
