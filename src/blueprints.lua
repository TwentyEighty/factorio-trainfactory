local flib_table = require("__flib__.table")
local constants = require("constants")
local global_data = require("global-data")
local util = require("src.util")

local blueprints = {}

local function fail_blueprint(bp, player, message)
    bp.clear_blueprint()

    player.create_local_flying_text {
        text = message,
        position = player.position,
    }
end

local function get_blueprint(player)
    local bp = player.blueprint_to_setup

    if bp and bp.valid_for_read and bp.is_blueprint_setup() then
        return bp
    end

    local cursor_stack = player.cursor_stack
    if cursor_stack
            and cursor_stack.valid_for_read
            and cursor_stack.is_blueprint
            and cursor_stack.is_blueprint_setup() then
        local cursor_bp = cursor_stack
        while cursor_bp.is_blueprint_book do
            cursor_bp = cursor_bp.get_inventory(defines.inventory.item_main)[cursor_bp.active_index]
        end
        return cursor_bp
    end
end

local function tag_train_factories(bp, player, surface)
    local entities = bp.get_blueprint_entities()
    if not entities then return end

    local found_rail = false
    local found_train_factories = false
    for _,blueprint_entity in pairs(entities) do
        if blueprint_entity.name == "straight-rail" then
            found_rail = true
        elseif flib_table.find(constants.building_entities, blueprint_entity.name) then
            found_train_factories = true
            
            -- Find the corresponding surface entity to grab its global data
            local real_entity = surface.find_entities_filtered{
                name = constants.building_entities,
                position = blueprint_entity.position,
            }

            if real_entity[1] then
                local machine_data = global_data.get_machine_data_from_entity(real_entity[1]) or {}
                local group_data = global_data.get_group_from_entity(real_entity[1]) or {}
                blueprint_entity.tags = {
                    machine_config = machine_data.config or {},
                }

                if machine_data.stop then
                    blueprint_entity.tags.group_config = flib_table.deep_copy(group_data.config or {})
                    blueprint_entity.tags.stop_config = {
                        backer_name = machine_data.stop.backer_name,
                        trains_limit = machine_data.stop.trains_limit,
                    }
                end
            end
        end
    end

    if found_train_factories and not found_rail then
        fail_blueprint(bp, player, "Must have at least one straight rail in TrainFactory blueprint")
    else
        -- Commit the tags
        bp.set_blueprint_entities(entities)
    end
end

function blueprints.on_player_paste_blueprint_ghosts(blueprint_entities, surface, direction, position)
    -- The blueprint entities correspond to the area that the user generated the blueprint from
    -- Convert this to cover the area the user in pasting onto
    local our_translated_entities = util.translate_blueprint_entities(blueprint_entities, direction, position)
    for _,our_translated_entity in pairs(our_translated_entities) do
        local surface_entity = surface.find_entity(our_translated_entity.name, our_translated_entity.position)
        if surface_entity and our_translated_entity.tags
                and util.is_northsouth_aligned(our_translated_entity.direction) == util.is_northsouth_aligned(surface_entity.direction) then
            local machine_data = global_data.get_machine_data_from_entity(surface_entity)
            if machine_data then
                global_data.machine_config_change(surface_entity, our_translated_entity.tags["machine_config"])
                -- global_data.group_config_change(surface_entity, our_translated_entity.tags["group_config"])
            end
        end
    end
end

function blueprints.on_player_setup_blueprint(player, surface)
    local bp = get_blueprint(player)

    if bp and bp.valid_for_read then
        tag_train_factories(bp, player, surface)
    end
end

return blueprints
