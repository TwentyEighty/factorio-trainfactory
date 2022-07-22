local global_data = require("global-data")
local constants = require("constants")
local util = require("util")
local flib_direction = require("__flib__.direction")

local building_control = {}

building_control.on_entity_built = function(entity, player_index, tags, disassemble)
    local align = util.get_align(entity.direction)
    local ns_aligned = util.is_northsouth_aligned(entity.direction)
    local machine_data = global_data.add_new_machine_data(entity, tags)

    -- Create the fuel/equipment input/outputs
    local fuel_box_container_name = constants.fuel_container_mapping[entity.name] and
        constants.fuel_container_mapping[entity.name][ns_aligned]
    if fuel_box_container_name then
        local fuel_box_placement = constants.fuel_box_placement[entity.name]
        for i = 1, 2 do
            local x = (i == 2) and -fuel_box_placement.x or fuel_box_placement.x
            machine_data.containers[i] = entity.surface.create_entity {
                force = entity.force,
                name = fuel_box_container_name,
                position = util.add_positions(entity.position,
                    flib_direction.to_vector_2d(entity.direction, fuel_box_placement.y, x)),
            }
            machine_data.containers[i].link_id = constants.linked_fuel_chest_namespace + entity.unit_number
        end
    end

    -- Create the smelting outputs
    local output_container_name = constants.output_container_mapping[entity.name] and
        constants.output_container_mapping[entity.name][ns_aligned]
    if output_container_name then
        local output_box_placement = constants.output_box_placement[entity.name]
        for i = 1, 2 do
            local x = (i == 2) and -output_box_placement.x or output_box_placement.x
            machine_data.containers[i] = entity.surface.create_entity {
                force = entity.force,
                name = output_container_name,
                position = util.add_positions(entity.position,
                    flib_direction.to_vector_2d(entity.direction, output_box_placement.y, x)),
            }
            machine_data.containers[i].link_id = constants.linked_recipe_chest_namespace + entity.unit_number
        end
    end

    -- Find linkable machines to group together
    local nw_joiner = util.find_joinable_entity(entity.surface, entity.bounding_box,
        ns_aligned and defines.direction.north or defines.direction.west, entity.name) or {}
    local se_joiner = util.find_joinable_entity(entity.surface, entity.bounding_box,
        ns_aligned and defines.direction.south or defines.direction.east, entity.name) or {}

    local nw_data = global_data.get_machine_data_from_entity(nw_joiner.entity)
    local se_data = global_data.get_machine_data_from_entity(se_joiner.entity)

    if nw_data and nw_data.group and se_data and se_data.group then
        return util.fail_build(entity, entity.prototype.mineable_properties.products, player_index, entity.surface,
            entity.position, entity.force, constants.result.TWO_GROUPS)
    end

    local group_data = nil
    local stop_config = nil

    if tags then
        -- If coming from a blueprint, this will have tags to tell us whether to create the integrated stop
        stop_config = tags.stop_config
    elseif (align == constants.align.NW and not nw_data and (not se_data or not se_data.group))
        or (align == constants.align.SE and not se_data and (not nw_data or not nw_data.group)) then
        -- Otherwise, we're manually built
        -- If we're at the front of the line, create the new group and integrated stop
        stop_config = {
            backer_name = string.format("TrainFactory %s %s", disassemble and "Disassembly" or "Assembly",
                global.group_index),
            trains_limit = 1,
        }
    end

    -- Brand new, unconnected machines get an integrated train stop
    if stop_config then
        machine_data.stop = entity.surface.create_entity {
            force = entity.force,
            name = constants.integrated_stop_name,
            position = util.add_positions(entity.position, flib_direction.to_vector_2d(entity.direction, 3, 2)),
            direction = entity.direction,
            color = { 1, 0, 0 },
        }
        machine_data.stop.backer_name = stop_config.backer_name
        machine_data.stop.trains_limit = stop_config.trains_limit
        group_data = global_data.add_new_group(tags, machine_data.stop, disassemble and "disassemble" or "assemble")
        global_data.add_machines_to_group(group_data, { machine_data }, machine_data.stop ~= nil)
    end

    global_data.link_machines(nw_data, machine_data)
    global_data.link_machines(machine_data, se_data)
end

building_control.on_entity_removed = function(entity, player_index)
    local machine_data = global_data.get_machine_data_from_entity(entity)
    if machine_data then
        local containers = machine_data.containers
        local stop = machine_data.stop
        global_data.remove_machine_data(entity)

        for _, container in pairs(containers) do
            container.destroy()
        end
        if stop then
            stop.destroy()
        end
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

return building_control
