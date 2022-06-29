local flib_math = require("__flib__.math")
local flib_table = require("__flib__.table")
local global_data = require("src.global-data")

local gui = {}

local function clamp_color(number_text)
    return flib_math.clamp(tonumber(number_text) or 0, 0, 255)
end

local function change_station_name(player, name)
    local entity = player.opened
    for _, relative in pairs({
        player.gui.relative["trainfactory_config_1"],
        player.gui.relative["trainfactory_config_2"],
    }) do
        relative.trainfactory_group_config.trainfactory_stations.trainfactory_station_textfield.text = name
    end

    if entity then
        global_data.group_config_change(entity, {
            station_name = name
        })
    end
end

local function change_color(player, color_text)
    local color = flib_table.map(color_text, function (c) return clamp_color(c) end)
    for _, relative in pairs({
        player.gui.relative["trainfactory_config_1"],
        player.gui.relative["trainfactory_config_2"],
    }) do
        if relative then
            local color_picker = relative.trainfactory_machine_config.trainfactory_color_picker
            color_picker.trainfactory_color_r.trainfactory_color_r_text.text = tostring(color.r)
            color_picker.trainfactory_color_g.trainfactory_color_g_text.text = tostring(color.g)
            color_picker.trainfactory_color_b.trainfactory_color_b_text.text = tostring(color.b)
            color_picker.trainfactory_color_r.trainfactory_color_r_slider.slider_value = color.r
            color_picker.trainfactory_color_g.trainfactory_color_g_slider.slider_value = color.g
            color_picker.trainfactory_color_b.trainfactory_color_b_slider.slider_value = color.b
        end
    end

    local entity = player.opened
    if entity then
        global_data.machine_config_change(entity, {
            color = color
        })
    end
end

function gui.on_gui_value_changed(event)
    if string.sub(event.element.name, 1, 16) == "trainfactory_color" then
        local trainfactory_config_gui = event.element.parent.parent.parent
        local player = game.get_player(event.player_index)
        local color_picker = trainfactory_config_gui.trainfactory_color_picker
        if event.element.name == "trainfactory_color_r_slider" then
            color_picker.trainfactory_color_r.trainfactory_color_r_text.text = tostring(event.element.slider_value)
        elseif event.element.name == "trainfactory_color_g_slider" then
            color_picker.trainfactory_color_g.trainfactory_color_g_text.text = tostring(event.element.slider_value)
        elseif event.element.name == "trainfactory_color_b_slider" then
            color_picker.trainfactory_color_b.trainfactory_color_b_text.text = tostring(event.element.slider_value)
        else
            return
        end
        change_color(player, {
            r = color_picker.trainfactory_color_r.trainfactory_color_r_text.text,
            g = color_picker.trainfactory_color_g.trainfactory_color_g_text.text,
            b = color_picker.trainfactory_color_b.trainfactory_color_b_text.text,
        })
    end
end

function gui.on_gui_text_changed(event)
    local player = game.get_player(event.player_index)
    if string.sub(event.element.name, 1, 16) == "trainfactory_color" then
        local trainfactory_config_gui = event.element.parent.parent.parent
        local color_picker = trainfactory_config_gui.trainfactory_color_picker
        change_color(player, {
            r = color_picker.trainfactory_color_r.trainfactory_color_r_text.text,
            g = color_picker.trainfactory_color_g.trainfactory_color_g_text.text,
            b = color_picker.trainfactory_color_b.trainfactory_color_b_text.text,
        })
    end
end

function gui.on_gui_text_confirmed(event)
    local player = game.get_player(event.player_index)
    if event.element.name == "trainfactory_station_textfield" then
        change_station_name(player, event.element.text)
    end
end

function gui.create_assembler_gui(player, entity)
    local machine_data = global_data.get_machine_data_from_entity(entity)
    local group_data = global_data.get_group_from_entity(entity)
    if player and group_data then
        for index, relative_gui_type in pairs({
            defines.relative_gui_type.assembling_machine_gui,
            defines.relative_gui_type.assembling_machine_select_recipe_gui,
        }) do
            local anchor = { gui = relative_gui_type,
                position = defines.relative_gui_position.left }
            local trainfactory_config = player.gui.relative.add { type = "frame", anchor = anchor,
                name = string.format("trainfactory_config_%i",index),
                direction = "vertical" }
            local trainfactory_group_config = trainfactory_config.add { type = "frame", name = "trainfactory_group_config",
                caption = {"trainfactory.group_config"}, style="trainfactory_group_frame" }
            local stations = trainfactory_group_config.add { type = "flow", name = "trainfactory_stations",
                direction = "horizontal" }
            stations.add { type = "label", name = "trainfactory_station_label", caption = { "trainfactory.station" } }
            stations.add { type = "textfield", name = "trainfactory_station_textfield", text = group_data.config.station_name }
            local trainfactory_machine_config = trainfactory_config.add { type = "frame", name = "trainfactory_machine_config",
                caption = {"trainfactory.machine_config"}, style="trainfactory_machine_frame"  }
            local color_picker = trainfactory_machine_config.add { type = "flow", name = "trainfactory_color_picker",
                direction = "vertical" }
            local color_picker_r = color_picker.add { type = "flow", name = "trainfactory_color_r",
                direction = "horizontal" }
            color_picker_r.add { type = "label", name = "trainfactory_color_r_label", caption = { "trainfactory.color_r" } }
            color_picker_r.add { type = "slider", name = "trainfactory_color_r_slider", value = machine_data.config.color.r, minimum_value = 0,
                maximum_value = 255 }
            color_picker_r.add { type = "textfield", name = "trainfactory_color_r_text", text = machine_data.config.color.r, numeric = true,
                allow_decimal = false, allow_negative = false, style = "trainfactory_color_textfield" }
            local color_picker_g = color_picker.add { type = "flow", name = "trainfactory_color_g",
                direction = "horizontal" }
            color_picker_g.add { type = "label", name = "trainfactory_color_g_label", caption = { "trainfactory.color_g" } }
            color_picker_g.add { type = "slider", name = "trainfactory_color_g_slider", value = machine_data.config.color.g, minimum_value = 0,
                maximum_value = 255 }
            color_picker_g.add { type = "textfield", name = "trainfactory_color_g_text", text = machine_data.config.color.g, numeric = true,
                allow_decimal = false, allow_negative = false, style = "trainfactory_color_textfield" }
            local color_picker_b = color_picker.add { type = "flow", name = "trainfactory_color_b",
                direction = "horizontal" }
            color_picker_b.add { type = "label", name = "trainfactory_color_b_label", caption = { "trainfactory.color_b" } }
            color_picker_b.add { type = "slider", name = "trainfactory_color_b_slider", value = machine_data.config.color.b, minimum_value = 0,
                maximum_value = 255 }
            color_picker_b.add { type = "textfield", name = "trainfactory_color_b_text", text = machine_data.config.color.b, numeric = true,
                allow_decimal = false, allow_negative = false, style = "trainfactory_color_textfield" }
        end
    end
end

function gui.destroy_assembler_gui(player)
    if player then
        for _, relative in pairs({
            player.gui.relative["trainfactory_config_1"],
            player.gui.relative["trainfactory_config_2"],
        }) do
            if relative then
                relative.destroy()
            end
        end
    end
end

return gui
