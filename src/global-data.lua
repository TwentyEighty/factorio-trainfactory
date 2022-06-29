local constants = require('constants')
local flib_table = require('__flib__.table')

local global_data = {}

function global_data.on_init()
    if not global.version then
        global.version = 1
        global.players = {}
        global.machines = {}
        global.groups = {}
        global.group_index = 1
    end

    for _,player in pairs(game.players) do
        global_data.init_player_data(player.index)
    end
end

function global_data.init_player_data(player_index)
    if not global.players[player_index] then
        global.players[player_index] = {}
    end
end

function global_data.clear()
    for _,key in pairs(global) do
        global[key] = nil
    end
end

function global_data.remove_player_data(player_index)
    global.players[player_index] = nil
end

function global_data.add_new_machine_data(entity, tags)
    local new_machine_data = {
        id = entity.unit_number,
        entity = entity,
        config = tags and tags.machine_config or {
            color = constants.default_color,
        },
        containers = {}
    }
    global.machines[new_machine_data.id] = new_machine_data

    return new_machine_data
end

function global_data.get_machine_data(machine_id)
    return global.machines[machine_id]
end

function global_data.get_machine_data_from_entity(entity)
    return global.machines[entity.unit_number]
end

function global_data.remove_machine_data(entity)
    local machine_data = global_data.get_machine_data(entity.unit_number)
    if machine_data then
        global_data.remove_machine_from_group(machine_data)
    end

    global.machines[entity.unit_number] = nil
end

function global_data.add_new_group(first_machine_id, tags)
    -- Don't identify groups by machine ID, otherwise we
    -- will need complex logic when splitting and re-joining
    -- groups together.
    local new_group_data = {
        id = global.group_index,
        machines = {},
        config = tags and tags.group_config or {
            station_name = constants.default_station_name,
        },
    }

    global.groups[new_group_data.id] = new_group_data
    global.group_index = global.group_index + 1

    return new_group_data
end

function global_data.remove_group(group_data)
    global.groups[group_data.id] = nil
end

function global_data.add_machines_to_group(group_data, machine_ids, to_front, is_new)
    if to_front then
        group_data.machines = flib_table.array_merge { machine_ids, group_data.machines }
    else
        group_data.machines = flib_table.array_merge { group_data.machines, machine_ids }
    end

    for _,machine_id in pairs(machine_ids) do
        global.machines[machine_id].group_id = group_data.id
    end

    global_data.show_group_update(group_data, string.format("%s Group %d", is_new and "New" or "Grow", group_data.id))
end

function global_data.join_groups(group_data, group2_data, joiner_machine_data)
    group_data.machines = flib_table.array_merge{group_data.machines, {joiner_machine_data.id}, group2_data.machines}

    joiner_machine_data.group_id = group_data.id
    for _,machine_id in pairs(group2_data.machines) do
        global.machines[machine_id].group_id = group_data.id
    end

    global_data.remove_group(group2_data)

    global_data.show_group_update(group_data, string.format("Join Group %d", group_data.id))
end

function global_data.remove_machine_from_group(machine_data)
    local group_id = machine_data and machine_data.group_id or 0
    local group_data = global.groups[group_id]

    if group_data then
        -- remove the machine id from the group
        local size = flib_table.size(group_data.machines)
        local index = flib_table.find(group_data.machines, machine_data.id)

        -- Removing from front or rear, no problem
        if index == 1 then 
            group_data.machines = flib_table.slice(group_data.machines, 2, size)
            global_data.show_group_update(group_data, string.format("Shrink Group %d", group_data.id))
        elseif index == size then
            group_data.machines = flib_table.slice(group_data.machines, 1, size-1)
            global_data.show_group_update(group_data, string.format("Shrink Group %d", group_data.id))
        else
            -- Removing from the middle. Now we have to split this up into two groups
            local new_group_machines = flib_table.slice(group_data.machines, index + 1, size)
            
            group_data.machines = flib_table.slice(group_data.machines, 1, index - 1)
            global_data.show_group_update(group_data, string.format("Split Group %d", group_data.id))

            local new_group = global_data.add_new_group(new_group_machines[1], {
                group_config = group_data.config
            })
            global_data.add_machines_to_group(new_group, new_group_machines, false, true)
        end

        if flib_table.size(group_data.machines) < 1 then
            global_data.remove_group(group_data)
        end
    end

    machine_data.group_id = nil
end

function global_data.get_group_from_entity(entity)
    local machine_data = global_data.get_machine_data_from_entity(entity)
    if machine_data then
        return global.groups[machine_data.group_id]
    end
    return nil
end

function global_data.machine_config_change(entity, config)
    local machine_data = global_data.get_machine_data_from_entity(entity)
    machine_data.config = flib_table.deep_merge{machine_data.config, config}
    global_data.show_machine_update(machine_data, "Machine Config Change")
end

function global_data.group_config_change(entity, config)
    local group = global_data.get_group_from_entity(entity)
    if group then
        group.config = flib_table.deep_merge{group.config, config}
        global_data.show_group_update(group, "Group Config Change")
    end
end

function global_data.show_machine_update(machine_data, message)
    if machine_data then
        machine_data.entity.surface.create_entity {
            name = "flying-text",
            text = message,
            position = machine_data.entity.position,
        }
    end
end

function global_data.show_group_update(group_data, message)
    for _, machine_id in pairs(group_data.machines) do
        local machine_data = global.machines[machine_id]
        global_data.show_machine_update(machine_data, message)
    end
end

return global_data
