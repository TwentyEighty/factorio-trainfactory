local constants = require('constants')
local util = require('util')
local flib_table = require('__flib__.table')

local global_data = {}

function global_data.on_init()
    if global.version == 1 then
        -- v1 machines will need to be recreated
        game.print("Breaking update. TrainFactory buildings will need to be recreated.")
        global_data.clear()
    end

    if not global.version then
        global.version = 2
        global.players = {}
        global.machines = {
            assemble = {},
            disassemble = {},
        }
        global.groups = {
            assemble = {},
            disassemble = {},
        }
        global.buckets = {}
        global.group_index = 1
    end

    for _, player in pairs(game.players) do
        global_data.init_player_data(player.index)
    end
end

function global_data.init_player_data(player_index)
    if not global.players[player_index] then
        global.players[player_index] = {}
    end
end

function global_data.clear()
    for key, _ in pairs(global) do
        global[key] = nil
    end
end

local function add_to_bucket(group)
    local min_index = 0
    local min_count = 1000000
    for i = 1, constants.num_buckets do
        local bucket = global.buckets[i]
        if not bucket then
            global.buckets[i] = {}
            bucket = global.buckets[i]
        end

        local size = flib_table.size(bucket)
        if flib_table.size(bucket) < min_count then
            min_index = i
            min_count = size
        end
    end

    global.buckets[min_index][group.id] = group
    group.bucket = global.buckets[min_index]
end

local function remove_from_bucket(group)
    group.bucket[group.id] = nil
end

function global_data.get_bucket(tick)
    local bucket_index = (tick / 60 / constants.bucket_update_interval_seconds) % constants.num_buckets
    return global.buckets[bucket_index + 1]
end

function global_data.remove_player_data(player_index)
    global.players[player_index] = nil
end

function global_data.get_type(entity)
    return flib_table.find(constants.assemble_entities, entity.name) and "assemble" or "disassemble"
end

local function show_machine_message(machine, message)
    util.show_message(message, machine.entity.surface, machine.entity.position)
end

function global_data.add_new_machine_data(entity, tags)
    local type = global_data.get_type(entity)
    local new_machine_data = {
        id = entity.unit_number,
        entity = entity,
        config = tags and tags.machine_config or flib_table.deep_copy(constants.default_machine_config[type]),
        containers = {},
        type = type,
        link = {},
    }
    global.machines[type][new_machine_data.id] = new_machine_data
    return new_machine_data
end

function global_data.get_machine_data(machine_id, disassemble)
    local type = disassemble and "disassemble" or "assemble"
    return global.machines[type][machine_id]
end

function global_data.get_machine_data_from_entity(entity)
    if not entity then return nil end
    local type = global_data.get_type(entity)
    return global.machines[type][entity.unit_number]
end

function global_data.remove_machine_data(entity)
    local machine_data = global_data.get_machine_data_from_entity(entity)
    if machine_data then
        local group_data = machine_data.group

        -- everything downstream is no longer part of a group
        if group_data then
            local align = util.get_align(util.opposite(group_data.stop.direction))
            local link = machine_data
            while link do
                show_machine_message(link, { "message.remove-group", group_data.id })
                group_data.machines[link.id] = nil
                link.group = nil
                link.entity.operable = false
                link.entity.active = false
                link = link.link[align]
            end
            if flib_table.size(group_data.machines) < 1 then
                global_data.remove_group(group_data)
            end
        end

        global_data.unlink_machines(machine_data.link[constants.align.NW], machine_data)
        global_data.unlink_machines(machine_data, machine_data.link[constants.align.SE])

        global.machines[machine_data.type][entity.unit_number] = nil
    end
end

function global_data.add_new_group(tags, train_stop, type)
    -- Don't identify groups by machine ID, otherwise we
    -- will need complex logic when splitting and re-joining
    -- groups together.
    local new_group_data = {
        id = global.group_index,
        machines = {},
        config = tags and tags.group_config or flib_table.deep_copy(constants.default_group_config[type]),
        type = type,
        stop = train_stop,
    }

    global.groups[type][new_group_data.id] = new_group_data
    global.group_index = global.group_index + 1
    add_to_bucket(new_group_data)
    return new_group_data
end

function global_data.remove_group(group_data)
    remove_from_bucket(group_data)
    global.groups[group_data.type][group_data.id] = nil
end

local function link_group(group, start_machine, align)
    local link = start_machine
    while link do
        show_machine_message(link, { "message.expand-group", group.id })
        group.machines[link.id] = link
        link.group = group
        link.entity.operable = true
        link.entity.active = true
        link = link.link[align]
    end
end

function global_data.link_machines(nw_machine, se_machine)
    if nw_machine and se_machine then
        if nw_machine.group and se_machine.group then error("Cannot link two machines having existing groups") end
        nw_machine.link[constants.align.SE] = se_machine
        se_machine.link[constants.align.NW] = nw_machine

        if nw_machine.group then
            link_group(nw_machine.group, se_machine, constants.align.SE)
        elseif se_machine.group then
            link_group(se_machine.group, nw_machine, constants.align.NW)
        end
    end
end

function global_data.unlink_machines(nw_machine, se_machine)
    if nw_machine then nw_machine.link[constants.align.SE] = nil end
    if se_machine then se_machine.link[constants.align.NW] = nil end
end

function global_data.add_machines_to_group(group, machines, is_new)
    for _, machine_data in pairs(machines) do
        group.machines[machine_data.id] = machine_data
    end

    for _, machine in pairs(group.machines) do
        machine.group = group
    end

    util.show_group_message(group, { is_new and "message.new-group" or "message.expand-group", group.id })
end

function global_data.get_group_from_entity(entity)
    local machine_data = global_data.get_machine_data_from_entity(entity)
    if machine_data then
        return machine_data.group
    end
    return nil
end

function global_data.machine_config_change(entity, config)
    local machine = global_data.get_machine_data_from_entity(entity)
    if machine then
        machine.config = flib_table.deep_merge { machine.config, config }
        show_machine_message(machine, { "message.machine-config-change" })
    end
end

function global_data.group_config_change(entity, config)
    local group = global_data.get_group_from_entity(entity)
    if group then
        group.config = flib_table.deep_merge { group.config, config }
        util.show_group_message(group, { "message.group-config-change" })
    end
end

return global_data
