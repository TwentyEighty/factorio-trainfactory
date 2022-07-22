local table = require("__flib__.table")
local constants = require("constants")
local collision_data = require("prototypes.collision-mask")

local base_prototype = data.raw["locomotive"]["locomotive"]
local result_entity = data.raw["assembling-machine"][constants.full_size_entity_name]
local trainfactory_placer_entity = table.deep_merge { base_prototype, {
    name = constants.full_size_placer_entity_name,
    minable = {
        result = constants.full_size_placer_item_name,
    },
    flags = table.array_merge({base_prototype.flags, {"placeable-off-grid"}}),

    -- Copy the localization from the real entity
    localised_name = table.deep_copy(result_entity.localised_name),
    localised_description = table.deep_copy(result_entity.localised_description),

    -- facing north
    vertical_selection_shift = -0.5,
    selection_box = { { -3, -2.5 }, { 3, 2.5 } },
    collision_box = { { -2.95, -2.45 }, { 2.95, 2.45 } },
    collision_mask = { "train-layer", "player-layer", collision_data.layer},

    joint_distance = constants.entity_joint_data[constants.full_size_entity_name].joint_distance,
    connection_distance = -5, -- don't try to connect to nearby trains

    drawing_box = { { -4, -4 }, { 4, 4 } }
}}

trainfactory_placer_entity.fast_replaceable_group = nil
trainfactory_placer_entity.next_upgrade = nil
trainfactory_placer_entity.front_light = nil
trainfactory_placer_entity.back_light = nil
trainfactory_placer_entity.stand_by_light = nil

trainfactory_placer_entity.wheels = {
    priority = "very-low",
    width = 1,
    height = 1,
    direction_count = 4,
    frame_count = 1,
    line_length = 1,
    lines_per_file = 1,
    filenames =
    {
        "__core__/graphics/empty.png",
        "__core__/graphics/empty.png",
        "__core__/graphics/empty.png",
        "__core__/graphics/empty.png",
    },
    hr_version = nil
}

trainfactory_placer_entity.pictures = {
    layers = {
        -- north/south
        {
            priority = "high",
            width = 129,
            height = 100,
            direction_count = 4,
            frame_count = 1,
            line_length = 1,
            lines_per_file = 1,
            shift = { 0.421875, 0 },
            scale = 1.8,
            tint = constants.trainfactory_tint,
            filenames = {
                "__trainfactory__/graphics/entity/trainfactory-full/trainfactory-full-ns.png",
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/entity/trainfactory-full/trainfactory-full-ns.png",
                "__trainfactory__/graphics/entity/empty.png",
            },
            hr_version = {
                width = 239,
                height = 219,
                direction_count = 4,
                frame_count = 1,
                line_length = 1,
                lines_per_file = 1,
                shift = util.by_pixel(0.75, 5.75),
                scale = 0.9,
                tint = constants.trainfactory_tint,
                filenames = {
                    "__trainfactory__/graphics/entity/trainfactory-full/hr-trainfactory-full-ns.png",
                    "__trainfactory__/graphics/entity/empty.png",
                    "__trainfactory__/graphics/entity/trainfactory-full/hr-trainfactory-full-ns.png",
                    "__trainfactory__/graphics/entity/empty.png",
                }
            }
        },
        -- east/west
        {
            priority = "high",
            width = 129,
            height = 100,
            direction_count = 4,
            frame_count = 1,
            line_length = 1,
            lines_per_file = 1,
            shift = { 0.421875, 0 },
            scale = 1.8,
            tint = constants.trainfactory_tint,
            filenames = {
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/entity/trainfactory-full/trainfactory-full-ew.png",
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/entity/trainfactory-full/trainfactory-full-ew.png",
            },
            hr_version = {
                width = 239,
                height = 219,
                direction_count = 4,
                frame_count = 1,
                line_length = 1,
                lines_per_file = 1,
                shift = util.by_pixel(0.75, 5.75),
                scale = 0.9,
                tint = constants.trainfactory_tint,
                filenames = {
                    "__trainfactory__/graphics/entity/empty.png",
                    "__trainfactory__/graphics/entity/trainfactory-full/hr-trainfactory-full-ew.png",
                    "__trainfactory__/graphics/entity/empty.png",
                    "__trainfactory__/graphics/entity/trainfactory-full/hr-trainfactory-full-ew.png",
                }
            }
        },
        -- We need to manually draw on the indicator arrows because locomotives don't
        -- have fluid boxes. Not that I tried to add one or anything
        -- north
        {
            priority = "high",
            width = 48,
            height = 48,
            direction_count = 4,
            frame_count = 1,
            line_length = 1,
            lines_per_file = 1,
            scale = 0.5,
            shift = {0, -2.5},
            filenames = {
                "__trainfactory__/graphics/arrow-N.png",
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/entity/empty.png",
            }
        },
        -- east
        {
            priority = "high",
            width = 48,
            height = 48,
            direction_count = 4,
            frame_count = 1,
            line_length = 1,
            lines_per_file = 1,
            scale = 0.5,
            shift = {2.5, 0},
            filenames = {
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/arrow-E.png",
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/entity/empty.png",
            }
        },
        -- south
        {
            priority = "high",
            width = 48,
            height = 48,
            direction_count = 4,
            frame_count = 1,
            line_length = 1,
            lines_per_file = 1,
            scale = 0.5,
            shift = {0, 2.5},
            filenames = {
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/arrow-S.png",
                "__trainfactory__/graphics/entity/empty.png",
            }
        },
        -- west
        {
            priority = "high",
            width = 48,
            height = 48,
            direction_count = 4,
            frame_count = 1,
            line_length = 1,
            lines_per_file = 1,
            scale = 0.5,
            shift = {-2.5, 0},
            filenames = {
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/arrow-W.png",
            }
        }
    }
}

data:extend({ trainfactory_placer_entity })

result_entity = data.raw["assembling-machine"][constants.half_size_entity_name]
local trainfactory_half_placer_entity = table.deep_merge { trainfactory_placer_entity, {
    name = constants.half_size_placer_entity_name,
    minable = {
        result = constants.half_size_placer_item_name
    },

    -- Copy the localization from the real entity
    localised_name = table.deep_copy(result_entity.localised_name),
    localised_description = table.deep_copy(result_entity.localised_description),

    -- facing north
    selection_box = { { -3, -1.25 }, { 3, 1.25 } },
    collision_box = { { -2.95, -1.15 }, { 2.95, 1.15 } },

    joint_distance = 1.5,

    drawing_box = { { -4, -4 }, { 4, 4 } }
}}

trainfactory_half_placer_entity.pictures = {
    layers = {
        -- north/south
        {
            priority = "high",
            width = 100,
            height = 68,
            direction_count = 4,
            frame_count = 1,
            line_length = 1,
            lines_per_file = 1,
            shift = { 0.421875, 0 },
            scale = 1.8,
            tint = constants.trainfactory_tint,
            filenames = {
                "__trainfactory__/graphics/entity/trainfactory-half/trainfactory-half-ns.png",
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/entity/trainfactory-half/trainfactory-half-ns.png",
                "__trainfactory__/graphics/entity/empty.png",
            },
            hr_version =
            {
                priority = "high",
                width = 219,
                height = 125,
                direction_count = 4,
                frame_count = 1,
                line_length = 1,
                lines_per_file = 1,
                shift = util.by_pixel(0.75, 5.75),
                scale = 0.9,
                tint = constants.trainfactory_tint,
                filenames = {
                    "__trainfactory__/graphics/entity/trainfactory-half/hr-trainfactory-half-ns.png",
                    "__trainfactory__/graphics/entity/empty.png",
                    "__trainfactory__/graphics/entity/trainfactory-half/hr-trainfactory-half-ns.png",
                    "__trainfactory__/graphics/entity/empty.png",
                }
            }
        },
        -- east/west
        {
            priority = "high",
            width = 68,
            height = 100,
            direction_count = 4,
            frame_count = 1,
            line_length = 1,
            lines_per_file = 1,
            shift = { 0.421875, 0 },
            scale = 1.8,
            tint = constants.trainfactory_tint,
            filenames = {
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/entity/trainfactory-half/trainfactory-half-ew.png",
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/entity/trainfactory-half/trainfactory-half-ew.png",
            },
            hr_version =
            {
                priority = "high",
                width = 125,
                height = 219,
                direction_count = 4,
                frame_count = 1,
                line_length = 1,
                lines_per_file = 1,
                shift = util.by_pixel(0.75, 5.75),
                scale = 0.9,
                tint = constants.trainfactory_tint,
                filenames = {
                    "__trainfactory__/graphics/entity/empty.png",
                    "__trainfactory__/graphics/entity/trainfactory-half/hr-trainfactory-half-ew.png",
                    "__trainfactory__/graphics/entity/empty.png",
                    "__trainfactory__/graphics/entity/trainfactory-half/hr-trainfactory-half-ew.png",
                }
            }
        },
        -- We need to manually draw on the indicator arrows because locomotives don't
        -- have fluid boxes. Not that I tried to add one or anything
        -- north
        {
            priority = "high",
            width = 48,
            height = 48,
            direction_count = 4,
            frame_count = 1,
            line_length = 1,
            lines_per_file = 1,
            scale = 0.5,
            shift = {0, -1},
            filenames = {
                "__trainfactory__/graphics/arrow-N.png",
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/entity/empty.png",
            }
        },
        -- east
        {
            priority = "high",
            width = 48,
            height = 48,
            direction_count = 4,
            frame_count = 1,
            line_length = 1,
            lines_per_file = 1,
            scale = 0.5,
            shift = {1, 0},
            filenames = {
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/arrow-E.png",
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/entity/empty.png",
            }
        },
        -- south
        {
            priority = "high",
            width = 48,
            height = 48,
            direction_count = 4,
            frame_count = 1,
            line_length = 1,
            lines_per_file = 1,
            scale = 0.5,
            shift = {0, 1},
            filenames = {
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/arrow-S.png",
                "__trainfactory__/graphics/entity/empty.png",
            }
        },
        -- west
        {
            priority = "high",
            width = 48,
            height = 48,
            direction_count = 4,
            frame_count = 1,
            line_length = 1,
            lines_per_file = 1,
            scale = 0.5,
            shift = {-1, 0},
            filenames = {
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/entity/empty.png",
                "__trainfactory__/graphics/arrow-W.png",
            }
        }
    }
}

data:extend({ trainfactory_half_placer_entity })


local item = data.raw["item"][constants.full_size_disassemble_placer_item_name]
local trainfactory_disassemble_placer_entity = table.deep_merge { trainfactory_placer_entity, {
    name = constants.full_size_disassemble_placer_entity_name,
    minable = {
        result = constants.full_size_disassemble_placer_item_name
    },

    -- Same localization and icon as the item
    localised_name = table.deep_copy(item.localised_name),
    localised_description = table.deep_copy(item.localised_description),
    icon = table.deep_copy(item.icon),
    icon_size = table.deep_copy(item.icon_size),
    icon_mipmaps = table.deep_copy(item.icon_mipmaps),

    pictures = {
        layers = {
            -- north/south
            {
                tint = constants.trainfactory_disassemble_tint,
                hr_version = {
                    tint = constants.trainfactory_disassemble_tint,
                }
            },
            -- east/west
            {
                tint = constants.trainfactory_disassemble_tint,
                hr_version = {
                    tint = constants.trainfactory_disassemble_tint,
                }
            },
        }
    }
}}
data:extend({ trainfactory_disassemble_placer_entity })



local item = data.raw["item"][constants.half_size_disassemble_placer_item_name]
local trainfactory_disassemble_half_placer_entity = table.deep_merge { trainfactory_half_placer_entity, {
    name = constants.half_size_disassemble_placer_entity_name,
    minable = {
        result = constants.half_size_disassemble_placer_item_name
    },

    -- Same localization and icon as the item
    localised_name = table.deep_copy(item.localised_name),
    localised_description = table.deep_copy(item.localised_description),
    icon = table.deep_copy(item.icon),
    icon_size = table.deep_copy(item.icon_size),
    icon_mipmaps = table.deep_copy(item.icon_mipmaps),

    pictures = {
        layers = {
            -- north/south
            {
                tint = constants.trainfactory_disassemble_tint,
                hr_version = {
                    tint = constants.trainfactory_disassemble_tint,
                }
            },
            -- east/west
            {
                tint = constants.trainfactory_disassemble_tint,
                hr_version = {
                    tint = constants.trainfactory_disassemble_tint,
                }
            },
        }
    }
}}
data:extend({ trainfactory_disassemble_half_placer_entity })
