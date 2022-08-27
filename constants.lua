local constants = {}

constants.num_buckets = 5
constants.bucket_update_interval_seconds = 1
constants.energy_required = 30

constants.align = {
    NW = 0,
    SE = 1
}

constants.linked_fuel_chest_namespace = 0x28000000
constants.linked_recipe_chest_namespace = 0x28100000

constants.full_size_recipe_category = "train-crafting-full"
constants.half_size_recipe_category = "train-crafting-half"

constants.full_size_placer_item_name = "trainfactory-full-placer-item"
constants.half_size_placer_item_name = "trainfactory-half-placer-item"

constants.full_size_placer_entity_name = "trainfactory-full-placer-entity"
constants.half_size_placer_entity_name = "trainfactory-half-placer-entity"

constants.full_size_entity_name = "trainfactory-full-entity"
constants.half_size_entity_name = "trainfactory-half-entity"

constants.full_size_disassemble_recipe_category = "train-disassembling-full"
constants.half_size_disassemble_recipe_category = "train-disassembling-half"

constants.full_size_disassemble_placer_item_name = "trainfactory-disassemble-full-placer-item"
constants.half_size_disassemble_placer_item_name = "trainfactory-disassemble-half-placer-item"

constants.full_size_disassemble_placer_entity_name = "trainfactory-disassemble-full-placer-entity"
constants.half_size_disassemble_placer_entity_name = "trainfactory-disassemble-half-placer-entity"

constants.full_size_disassemble_entity_name = "trainfactory-disassemble-full-entity"
constants.half_size_disassemble_entity_name = "trainfactory-disassemble-half-entity"

constants.input_fuel_container_name = "trainfactory-fuel-and-equipment-input-container"
constants.input_fuel_container_name_horiz = "trainfactory-fuel-and-equipment-input-container-horiz"
constants.output_container_name_full = "trainfactory-output-container-full"
constants.output_container_name_half = "trainfactory-output-container-half"
constants.output_container_name_full_horiz = "trainfactory-output-container-full-horiz"
constants.output_container_name_half_horiz = "trainfactory-output-container-half-horiz"
constants.integrated_stop_name = "trainfactory-trainstop"

constants.trainfactory_tint = { 1, 1, .4 }
constants.trainfactory_disassemble_tint = { 1, .8, .8 }

constants.default_station_name = ""
constants.default_color = {
    r = 118,
    g = 185,
    b = 0,
}

constants.placer_mapping = {
    [constants.full_size_placer_entity_name] = constants.full_size_entity_name,
    [constants.half_size_placer_entity_name] = constants.half_size_entity_name,
    [constants.full_size_disassemble_placer_entity_name] = constants.full_size_disassemble_entity_name,
    [constants.half_size_disassemble_placer_entity_name] = constants.half_size_disassemble_entity_name,
}

constants.fuel_joules_to_insert = 200 * 1000000 -- stack of coal
constants.rolling_stock_types = {
    "locomotive",
    "artillery-wagon",
    "cargo-wagon",
    "fluid-wagon",
}

constants.placer_entities = {
    constants.full_size_placer_entity_name,
    constants.half_size_placer_entity_name,
    constants.full_size_disassemble_placer_entity_name,
    constants.half_size_disassemble_placer_entity_name,
}

constants.assemble_entities = {
    constants.full_size_entity_name,
    constants.half_size_entity_name,
}

constants.disassemble_entities = {
    constants.full_size_disassemble_entity_name,
    constants.half_size_disassemble_entity_name,
}

constants.building_entities = {
    constants.full_size_entity_name,
    constants.half_size_entity_name,
    constants.full_size_disassemble_entity_name,
    constants.half_size_disassemble_entity_name,
}

constants.join_mapping = {
    [constants.full_size_entity_name] = constants.assemble_entities,
    [constants.half_size_entity_name] = constants.assemble_entities,
    [constants.full_size_disassemble_entity_name] = constants.disassemble_entities,
    [constants.half_size_disassemble_entity_name] = constants.disassemble_entities,
}

-- true == ns_aligned, false == ew_aligned
constants.fuel_container_mapping = {
    [constants.full_size_entity_name] = {
        [true] = constants.input_fuel_container_name,
        [false] = constants.input_fuel_container_name_horiz
    },
    [constants.half_size_entity_name] = {
        [true] = constants.input_fuel_container_name,
        [false] = constants.input_fuel_container_name_horiz
    },
}

constants.output_container_mapping = {
    [constants.full_size_disassemble_entity_name] = {
        [true] = constants.output_container_name_full,
        [false] = constants.output_container_name_full_horiz
    },
    [constants.half_size_disassemble_entity_name] = {
        [true] = constants.output_container_name_half,
        [false] = constants.output_container_name_half_horiz
    },
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
    },
}
constants.entity_joint_data[constants.full_size_disassemble_entity_name] = constants.entity_joint_data[
    constants.full_size_entity_name]
constants.entity_joint_data[constants.half_size_disassemble_entity_name] = constants.entity_joint_data[
    constants.half_size_entity_name]

constants.fuel_box_placement = {
    [constants.full_size_entity_name] = { x = 2.2, y = 2.5 },
    [constants.half_size_entity_name] = { x = 2.2, y = .75 },
}

constants.output_box_placement = {
    [constants.full_size_disassemble_entity_name] = { x = 2.2, y = 0 },
    [constants.half_size_disassemble_entity_name] = { x = 2.2, y = 0 },
}

constants.result = {
    OK = 0,
    OCCUPIED = 1,
    NO_STOCK = 2,
    CANT_BUILD = 3,
    BROKEN = 4,
    BUSY = 5,
    NO_INSERT = 6,
    NO_TRAIN = 7,
    NOT_EMPTY = 8,
    NEED_RAILS = 9,
    TWO_GROUPS = 10,
    FRONT_OF_LINE = 11,
    HALF_SIZE_NOT_SUPPORTED = 12,
    COLLISION = 13,
    GROUP_CONFIG_CHANGE = 15,
    NEW_GROUP = 16,
    EXPAND_GROUP = 17,
    REMOVE_GROUP = 18,
}

constants.default_machine_config = {
    assemble = {
        color = constants.default_color,
    },
    disassemble = {},
}

constants.default_group_config = {
    assemble = {},
    disassemble = {},
}

return constants
