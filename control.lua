local event = require("__flib__.event")
local flib_table = require("__flib__.table")
local constants = require("constants")
local global_data = require("src.global-data")
local placer_control = require("src.placer-control")
local building_control = require("src.building-control")
local gui = require("src.gui")
local blueprints = require("src.blueprints")

script.on_configuration_changed(function()
    global_data.on_init(game.players)
end)

local function remote_init()
    if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["add_blacklist_name"] then
        for _,entity_name in pairs(constants.building_entities) do
            remote.call("PickerDollies", "add_blacklist_name", entity_name)
        end
    end    
end

script.on_init(function()
    global_data.on_init()
    remote_init()
end)

script.on_load(function()
    remote_init()
end)

script.on_event(defines.events.on_player_created, function(event)
    global_data.init_player_data(event.player_index)
end)

script.on_event(defines.events.on_player_removed, function(event)
    global.players[event.player_index] = nil
end)

script.on_event({
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
    defines.events.script_raised_built,
    defines.events.script_raised_revive, }, function(event)
    local entity = event.created_entity or event.entity
    if entity and entity.valid then
        if flib_table.find(constants.placer_entities, entity.name) then
            placer_control.on_entity_built(entity, event.player_index)
        elseif flib_table.find(constants.building_entities, entity.name) then
            building_control.on_entity_built(entity, event.player_index, event.tags)
        end
    end
end)

script.on_event({
    defines.events.on_player_mined_entity,
    defines.events.on_robot_mined_entity, }, function(event)
    local entity = event.entity
    if entity and entity.valid then
        if flib_table.find(constants.building_entities, entity.name) then
            building_control.on_entity_removed(entity, event.player_index)
        end
    end
end)

script.on_event({defines.events.on_player_setup_blueprint}, function (event)
    local player = game.players[event.player_index]
    blueprints.on_player_setup_blueprint(player, event.surface)
end)

script.on_event({defines.events.on_pre_build }, function (event)
    local player = game.players[event.player_index]
    local blueprint_entities = player.get_blueprint_entities()
    if blueprint_entities and next(blueprint_entities) then
        -- The most likely case is that the blueprint doesn't involve us at all, so bail as early as possible
        local found_our_entity = false
        for _,bp_entity in pairs(blueprint_entities) do
            if flib_table.find(constants.building_entities, bp_entity.name) then
                found_our_entity = true
                break
            end
        end
        if found_our_entity then
            blueprints.on_player_paste_blueprint_ghosts(blueprint_entities, player.surface, event.direction, event.position)
        end
    end
end)

script.on_event({defines.events.on_entity_settings_pasted}, function (event)
    local source = event.source
    local dest = event.destination
    if flib_table.find(constants.building_entities, source.name) and flib_table.find(constants.building_entities, dest.name) then
        local player = game.players[event.player_index]
        building_control.on_entity_settings_pasted(player, source, dest)
    end
end)

script.on_event({
    defines.events.on_gui_opened,
}, function(event)
    local entity = event.entity
    if entity and flib_table.find(constants.building_entities, event.entity.name) then
        gui.create_assembler_gui(game.players[event.player_index], entity)
    end
end)

script.on_event({
    defines.events.on_gui_closed,
}, function(event)
    local entity = event.entity
    if entity and flib_table.find(constants.building_entities, event.entity.name) then
        gui.destroy_assembler_gui(game.players[event.player_index])
    end
end)

script.on_event(defines.events.on_gui_value_changed, function(event)
    if string.sub(event.element.name, 1, 13) == "trainfactory_" then
        gui.on_gui_value_changed(event)
    end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
    if string.sub(event.element.name, 1, 13) == "trainfactory_" then
        gui.on_gui_text_changed(event)
    end
end)

script.on_event(defines.events.on_gui_confirmed, function(event)
    if string.sub(event.element.name, 1, 13) == "trainfactory_" then
        gui.on_gui_text_confirmed(event)
    end
end)

script.on_nth_tick(120, function(event)
    building_control.on_nth_tick()
end)
