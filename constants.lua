local constants = {}

constants.global_data_key = "train-crafting-data"

constants.linked_chest_namespace = 0x28000000

constants.full_size_recipe_category = "train-crafting-full"
constants.half_size_recipe_category = "train-crafting-half"

constants.full_size_placer_item_name = "trainfactory-full-placer-item"
constants.half_size_placer_item_name = "trainfactory-half-placer-item"

constants.full_size_placer_entity_name = "trainfactory-full-placer-entity"
constants.half_size_placer_entity_name = "trainfactory-half-placer-entity"

constants.full_size_entity_name = "trainfactory-full-entity"
constants.half_size_entity_name = "trainfactory-half-entity"

constants.full_size_disassemble_placer_item_name = "trainfactory-disassemble-full-placer-item"
constants.half_size_disassemble_placer_item_name = "trainfactory-disassemble-half-placer-item"

constants.full_size_disassemble_placer_entity_name = "trainfactory-disassemble-full-placer-entity"
constants.half_size_disassemble_placer_entity_name = "trainfactory-disassemble-half-placer-entity"

constants.full_size_disassemble_entity_name = "trainfactory-full-entity"
constants.half_size_disassemble_entity_name = "trainfactory-half-entity"

constants.default_station_name = ""
constants.default_color = {
    r = 118,
    g = 185,
    b = 0,
}

constants.fuel_joules_to_insert = 40 * 1000000
constants.rolling_stock_types = {
    "locomotive",
    "artillery-wagon",
    "cargo-wagon",
    "fluid-wagon",
}

constants.placer_entities = {
    constants.full_size_placer_entity_name,
    constants.half_size_placer_entity_name,
}

constants.building_entities = {
    constants.full_size_entity_name,
    constants.half_size_entity_name,
}

-- I would have chosen about 2 tiles for the snap distance, but then
-- it gets complicated when a half-size factory is placed too closely
-- together and we could end up snapping to the next factory over
constants.entity_joint_data = {
    [constants.full_size_entity_name] = {
        joint_distance = 4,
        connection_distance = 3,
        snap_distance = 1.49,
    },
    [constants.half_size_entity_name] = {
        joint_distance = 1.5,
        connection_distance = 2,
        snap_distance = 1.49,
    }
}

constants.fuel_box_placement = {
    [constants.full_size_entity_name] = { x = 2.5, y = 2.5},
    [constants.half_size_entity_name] = { x = 2.5, y = .75},
}

constants.check_rail_segment_result = {
    CLEAR = 0,
    NOT_CLEAR = 1,
    BROKEN = 2,
    ERROR = 3,
}

constants.check_rail_segment_message = {
    [0] = { "message.clear" },
    [1] = { "message.not_clear" },
    [2] = { "message.broken" },
    [3] = { "message.error" },
}

return constants
