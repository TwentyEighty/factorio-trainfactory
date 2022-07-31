local flib_table = require("__flib__.table")
local constants = require("constants")
local collision_data = require("prototypes.collision-mask")
local trainfactory_layer = collision_data and collision_data.layer or "layer-50" -- make YAFC happy

local base_prototype = data.raw["assembling-machine"]["assembling-machine-1"]
local trainfactory_entity = flib_table.deep_merge { base_prototype, {
    name = constants.full_size_entity_name,
    minable = {
        mining_time = 1,
        hardness = 0.5,
        result = constants.full_size_placer_item_name,
    },
    placeable_by = {
        item = constants.full_size_placer_item_name,
        count = 1,
    },
    flags = flib_table.array_merge({ base_prototype.flags, { "placeable-off-grid" } }),

    crafting_speed = 0.5,
    energy_usage = "200kW",

    module_slots = 1,
    allowed_effects = { "consumption", },

    -- Resolve localization here so the placer entity can copy it
    localised_name = { "entity-name.trainfactory-full-entity" },
    localised_description = { "entity-description.trainfactory-full-entity" },
    subgroup = "other",

    -- facing north
    selection_box = { { -3, -3 }, { 3, 3 } },
    collision_box = { { -2.9, -2.9 }, { 2.9, 2.9 } },
    collision_mask = { "player-layer", trainfactory_layer },

    -- We want this to be lower than locos/wagons, but higher than rails. Default is 50,
    -- so we'll set this to 49 and adjust straight rails to also be 49
    selection_priority = 49,

    joint_distance = 4,
    connection_distance = 3,
} }

trainfactory_entity.crafting_categories = { "train-crafting-full", }
trainfactory_entity.fast_replaceable_group = nil
trainfactory_entity.next_upgrade = nil

-- A fluid box forces the entity to have a direction. Otherwise it always
-- points towards the north. The fluid box also gives an indicator arrow
trainfactory_entity.fluid_boxes = { -- give it an output pipe so it has a direction
    {
        production_type = "output",
        pipe_picture = nil,
        pipe_covers = nil,
        base_area = 0.01,
        base_level = 0,
        pipe_connections = { { type = "output", position = { 0, -3.0 } } },
    },
    off_when_no_fluid_recipe = false,
}

trainfactory_entity.animation = {
    north = {
        layers =
        {
            {
                filename = "__trainfactory__/graphics/entity/trainfactory-full/trainfactory-full-ns.png",
                priority = "high",
                width = 129,
                height = 100,
                frame_count = 1,
                shift = { 0.421875, 0 },
                scale = 1.8,
                tint = constants.trainfactory_tint,
                hr_version =
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-full/hr-trainfactory-full-ns.png",
                    priority = "high",
                    width = 239,
                    height = 219,
                    frame_count = 1,
                    shift = util.by_pixel(0.75, 5.75),
                    scale = 0.9,
                    tint = constants.trainfactory_tint,
                }
            },
            {
                filename = "__trainfactory__/graphics/entity/trainfactory-full/trainfactory-full-shadow-ns.png",
                priority = "high",
                width = 129,
                height = 100,
                frame_count = 1,
                shift = { 0.421875, 0 },
                draw_as_shadow = true,
                scale = 1.8,
                tint = constants.trainfactory_tint,
                hr_version =
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-full/hr-trainfactory-full-shadow-ns.png",
                    priority = "high",
                    width = 227,
                    height = 171,
                    frame_count = 1,
                    draw_as_shadow = true,
                    shift = util.by_pixel(11.25, 7.75),
                    scale = 0.9,
                    tint = constants.trainfactory_tint,
                }
            }
        }
    },
    south = {
        layers =
        {
            {
                filename = "__trainfactory__/graphics/entity/trainfactory-full/trainfactory-full-ns.png",
                priority = "high",
                width = 129,
                height = 100,
                frame_count = 1,
                shift = { 0.421875, 0 },
                scale = 1.8,
                tint = constants.trainfactory_tint,
                hr_version =
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-full/hr-trainfactory-full-ns.png",
                    priority = "high",
                    width = 239,
                    height = 219,
                    frame_count = 1,
                    shift = util.by_pixel(0.75, 5.75),
                    scale = 0.9,
                    tint = constants.trainfactory_tint,
                }
            },
            {
                filename = "__trainfactory__/graphics/entity/trainfactory-full/trainfactory-full-shadow-ns.png",
                priority = "high",
                width = 129,
                height = 100,
                frame_count = 1,
                shift = { 0.421875, 0 },
                draw_as_shadow = true,
                scale = 1.8,
                tint = constants.trainfactory_tint,
                hr_version =
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-full/hr-trainfactory-full-shadow-ns.png",
                    priority = "high",
                    width = 227,
                    height = 171,
                    frame_count = 1,
                    draw_as_shadow = true,
                    shift = util.by_pixel(11.25, 7.75),
                    scale = 0.9,
                    tint = constants.trainfactory_tint,
                }
            }
        }
    },
    east = {
        layers =
        {
            {
                filename = "__trainfactory__/graphics/entity/trainfactory-full/trainfactory-full-ew.png",
                priority = "high",
                width = 129,
                height = 100,
                frame_count = 1,
                shift = { 0.421875, 0 },
                scale = 1.8,
                tint = constants.trainfactory_tint,
                hr_version =
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-full/hr-trainfactory-full-ew.png",
                    priority = "high",
                    width = 239,
                    height = 219,
                    frame_count = 1,
                    shift = util.by_pixel(0.75, 5.75),
                    scale = 0.9,
                    tint = constants.trainfactory_tint,
                }
            },
            {
                filename = "__trainfactory__/graphics/entity/trainfactory-full/trainfactory-full-shadow-ew.png",
                priority = "high",
                width = 129,
                height = 100,
                frame_count = 1,
                shift = { 0.421875, 0 },
                draw_as_shadow = true,
                scale = 1.8,
                tint = constants.trainfactory_tint,
                hr_version =
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-full/hr-trainfactory-full-shadow-ew.png",
                    priority = "high",
                    width = 227,
                    height = 171,
                    frame_count = 1,
                    draw_as_shadow = true,
                    shift = util.by_pixel(11.25, 7.75),
                    scale = 0.9,
                    tint = constants.trainfactory_tint,
                }
            }
        }
    },
    west = {
        layers =
        {
            {
                filename = "__trainfactory__/graphics/entity/trainfactory-full/trainfactory-full-ew.png",
                priority = "high",
                width = 129,
                height = 100,
                frame_count = 1,
                shift = { 0.421875, 0 },
                scale = 1.8,
                tint = constants.trainfactory_tint,
                hr_version =
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-full/hr-trainfactory-full-ew.png",
                    priority = "high",
                    width = 239,
                    height = 219,
                    frame_count = 1,
                    shift = util.by_pixel(0.75, 5.75),
                    scale = 0.9,
                    tint = constants.trainfactory_tint,
                }
            },
            {
                filename = "__trainfactory__/graphics/entity/trainfactory-full/trainfactory-full-shadow-ew.png",
                priority = "high",
                width = 129,
                height = 100,
                frame_count = 1,
                shift = { 0.421875, 0 },
                draw_as_shadow = true,
                scale = 1.8,
                tint = constants.trainfactory_tint,
                hr_version =
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-full/hr-trainfactory-full-shadow-ew.png",
                    priority = "high",
                    width = 227,
                    height = 171,
                    frame_count = 1,
                    draw_as_shadow = true,
                    shift = util.by_pixel(11.25, 7.75),
                    scale = 0.9,
                    tint = constants.trainfactory_tint,
                }
            }
        }
    },
}

trainfactory_entity.working_visualisations = {
    {
        render_layer = "higher-object-above",
        always_draw = true,
        north_animation = {
            layers =
            {
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-full/trainfactory-full-ns.png",
                    priority = "high",
                    width = 129,
                    height = 100,
                    frame_count = 1,
                    shift = { 0.421875, 0 },
                    scale = 1.8,
                    tint = constants.trainfactory_tint,
                    hr_version =
                    {
                        filename = "__trainfactory__/graphics/entity/trainfactory-full/hr-trainfactory-full-ns.png",
                        priority = "high",
                        width = 239,
                        height = 219,
                        frame_count = 1,
                        shift = util.by_pixel(0.75, 5.75),
                        scale = 0.9,
                        tint = constants.trainfactory_tint,
                    }
                },
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-full/trainfactory-full-shadow-ns.png",
                    priority = "high",
                    width = 129,
                    height = 100,
                    frame_count = 1,
                    shift = { 0.421875, 0 },
                    draw_as_shadow = true,
                    scale = 1.8,
                    tint = constants.trainfactory_tint,
                    hr_version =
                    {
                        filename = "__trainfactory__/graphics/entity/trainfactory-full/hr-trainfactory-full-shadow-ns.png",
                        priority = "high",
                        width = 227,
                        height = 171,
                        frame_count = 1,
                        draw_as_shadow = true,
                        shift = util.by_pixel(11.25, 7.75),
                        scale = 0.9,
                        tint = constants.trainfactory_tint,
                    }
                }
            }
        },
        south_animation = {
            layers =
            {
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-full/trainfactory-full-ns.png",
                    priority = "high",
                    width = 129,
                    height = 100,
                    frame_count = 1,
                    shift = { 0.421875, 0 },
                    scale = 1.8,
                    tint = constants.trainfactory_tint,
                    hr_version =
                    {
                        filename = "__trainfactory__/graphics/entity/trainfactory-full/hr-trainfactory-full-ns.png",
                        priority = "high",
                        width = 239,
                        height = 219,
                        frame_count = 1,
                        shift = util.by_pixel(0.75, 5.75),
                        scale = 0.9,
                        tint = constants.trainfactory_tint,
                    }
                },
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-full/trainfactory-full-shadow-ns.png",
                    priority = "high",
                    width = 129,
                    height = 100,
                    frame_count = 1,
                    shift = { 0.421875, 0 },
                    draw_as_shadow = true,
                    scale = 1.8,
                    tint = constants.trainfactory_tint,
                    hr_version =
                    {
                        filename = "__trainfactory__/graphics/entity/trainfactory-full/hr-trainfactory-full-shadow-ns.png",
                        priority = "high",
                        width = 227,
                        height = 171,
                        frame_count = 1,
                        draw_as_shadow = true,
                        shift = util.by_pixel(11.25, 7.75),
                        scale = 0.9,
                        tint = constants.trainfactory_tint,
                    }
                }
            }
        },
        east_animation = {
            layers =
            {
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-full/trainfactory-full-ew.png",
                    priority = "high",
                    width = 129,
                    height = 100,
                    frame_count = 1,
                    shift = { 0.421875, 0 },
                    scale = 1.8,
                    tint = constants.trainfactory_tint,
                    hr_version =
                    {
                        filename = "__trainfactory__/graphics/entity/trainfactory-full/hr-trainfactory-full-ew.png",
                        priority = "high",
                        width = 239,
                        height = 219,
                        frame_count = 1,
                        shift = util.by_pixel(0.75, 5.75),
                        scale = 0.9,
                        tint = constants.trainfactory_tint,
                    }
                },
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-full/trainfactory-full-shadow-ew.png",
                    priority = "high",
                    width = 129,
                    height = 100,
                    frame_count = 1,
                    shift = { 0.421875, 0 },
                    draw_as_shadow = true,
                    scale = 1.8,
                    tint = constants.trainfactory_tint,
                    hr_version =
                    {
                        filename = "__trainfactory__/graphics/entity/trainfactory-full/hr-trainfactory-full-shadow-ew.png",
                        priority = "high",
                        width = 227,
                        height = 171,
                        frame_count = 1,
                        draw_as_shadow = true,
                        shift = util.by_pixel(11.25, 7.75),
                        scale = 0.9,
                        tint = constants.trainfactory_tint,
                    }
                }
            }
        },
        west_animation = {
            layers =
            {
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-full/trainfactory-full-ew.png",
                    priority = "high",
                    width = 129,
                    height = 100,
                    frame_count = 1,
                    shift = { 0.421875, 0 },
                    scale = 1.8,
                    tint = constants.trainfactory_tint,
                    hr_version =
                    {
                        filename = "__trainfactory__/graphics/entity/trainfactory-full/hr-trainfactory-full-ew.png",
                        priority = "high",
                        width = 239,
                        height = 219,
                        frame_count = 1,
                        shift = util.by_pixel(0.75, 5.75),
                        scale = 0.9,
                        tint = constants.trainfactory_tint,
                    }
                },
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-full/trainfactory-full-shadow-ew.png",
                    priority = "high",
                    width = 129,
                    height = 100,
                    frame_count = 1,
                    shift = { 0.421875, 0 },
                    draw_as_shadow = true,
                    scale = 1.8,
                    tint = constants.trainfactory_tint,
                    hr_version =
                    {
                        filename = "__trainfactory__/graphics/entity/trainfactory-full/hr-trainfactory-full-shadow-ew.png",
                        priority = "high",
                        width = 227,
                        height = 171,
                        frame_count = 1,
                        draw_as_shadow = true,
                        shift = util.by_pixel(11.25, 7.75),
                        scale = 0.9,
                        tint = constants.trainfactory_tint,
                    }
                }
            }
        },
    }
}

data:extend({ trainfactory_entity })

local trainfactory_half_entity = flib_table.deep_merge { trainfactory_entity, {
    name = constants.half_size_entity_name,
    minable = {
        result = constants.half_size_placer_item_name,
    },
    placeable_by = {
        item = constants.half_size_placer_item_name,
    },

    -- Resolve localization here so the placer entity can copy it
    localised_name = { "entity-name.trainfactory-half-entity" },
    localised_description = { "entity-description.trainfactory-half-entity" },
    subgroup = "other",

    -- facing north
    selection_box = { { -3, -1.25 }, { 3, 1.25 } },
    collision_box = { { -2.9, -1.15 }, { 2.9, 1.15 } },

    joint_distance = 1.5,
    connection_distance = 2,
} }

trainfactory_half_entity.crafting_categories = { "train-crafting-half", }
trainfactory_half_entity.fluid_boxes[1].pipe_connections = { { type = "output", position = { 0, -1.5 } } }

trainfactory_half_entity.animation = {
    north = {
        layers =
        {
            {
                filename = "__trainfactory__/graphics/entity/trainfactory-half/trainfactory-half-ns.png",
                priority = "high",
                width = 100,
                height = 68,
                frame_count = 1,
                shift = { 0.421875, 0 },
                scale = 1.8,
                tint = constants.trainfactory_tint,
                hr_version =
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-half/hr-trainfactory-half-ns.png",
                    priority = "high",
                    width = 219,
                    height = 125,
                    frame_count = 1,
                    shift = util.by_pixel(0.75, 5.75),
                    scale = 0.9,
                    tint = constants.trainfactory_tint,
                }
            },
            {
                filename = "__trainfactory__/graphics/entity/trainfactory-half/trainfactory-half-shadow-ns.png",
                priority = "high",
                width = 100,
                height = 68,
                frame_count = 1,
                shift = { 0.421875, 0 },
                draw_as_shadow = true,
                scale = 1.8,
                tint = constants.trainfactory_tint,
                hr_version =
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-half/hr-trainfactory-half-shadow-ns.png",
                    priority = "high",
                    width = 171,
                    height = 111,
                    frame_count = 1,
                    draw_as_shadow = true,
                    shift = util.by_pixel(11.25, 7.75),
                    scale = 0.9,
                    tint = constants.trainfactory_tint,
                }
            }
        }
    },
    south = {
        layers =
        {
            {
                filename = "__trainfactory__/graphics/entity/trainfactory-half/trainfactory-half-ns.png",
                priority = "high",
                width = 100,
                height = 68,
                frame_count = 1,
                shift = { 0.421875, 0 },
                scale = 1.8,
                tint = constants.trainfactory_tint,
                hr_version =
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-half/hr-trainfactory-half-ns.png",
                    priority = "high",
                    width = 219,
                    height = 125,
                    frame_count = 1,
                    shift = util.by_pixel(0.75, 5.75),
                    scale = 0.9,
                    tint = constants.trainfactory_tint,
                }
            },
            {
                filename = "__trainfactory__/graphics/entity/trainfactory-half/trainfactory-half-shadow-ns.png",
                priority = "high",
                width = 100,
                height = 68,
                frame_count = 1,
                shift = { 0.421875, 0 },
                draw_as_shadow = true,
                scale = 1.8,
                tint = constants.trainfactory_tint,
                hr_version =
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-half/hr-trainfactory-half-shadow-ns.png",
                    priority = "high",
                    width = 171,
                    height = 111,
                    frame_count = 1,
                    draw_as_shadow = true,
                    shift = util.by_pixel(11.25, 7.75),
                    scale = 0.9,
                    tint = constants.trainfactory_tint,
                }
            }
        }
    },
    east = {
        layers =
        {
            {
                filename = "__trainfactory__/graphics/entity/trainfactory-half/trainfactory-half-ew.png",
                priority = "high",
                width = 68,
                height = 100,
                frame_count = 1,
                shift = { 0.421875, 0 },
                scale = 1.8,
                tint = constants.trainfactory_tint,
                hr_version =
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-half/hr-trainfactory-half-ew.png",
                    priority = "high",
                    width = 125,
                    height = 219,
                    frame_count = 1,
                    shift = util.by_pixel(0.75, 5.75),
                    scale = 0.9,
                    tint = constants.trainfactory_tint,
                }
            },
            {
                filename = "__trainfactory__/graphics/entity/trainfactory-half/trainfactory-half-shadow-ew.png",
                priority = "high",
                width = 68,
                height = 100,
                frame_count = 1,
                shift = { 0.421875, 0 },
                draw_as_shadow = true,
                scale = 1.8,
                tint = constants.trainfactory_tint,
                hr_version =
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-half/hr-trainfactory-half-shadow-ew.png",
                    priority = "high",
                    width = 111,
                    height = 171,
                    frame_count = 1,
                    draw_as_shadow = true,
                    shift = util.by_pixel(11.25, 7.75),
                    scale = 0.9,
                    tint = constants.trainfactory_tint,
                }
            }
        }
    },
    west = {
        layers =
        {
            {
                filename = "__trainfactory__/graphics/entity/trainfactory-half/trainfactory-half-ew.png",
                priority = "high",
                width = 68,
                height = 100,
                frame_count = 1,
                shift = { 0.421875, 0 },
                scale = 1.8,
                tint = constants.trainfactory_tint,
                hr_version =
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-half/hr-trainfactory-half-ew.png",
                    priority = "high",
                    width = 125,
                    height = 219,
                    frame_count = 1,
                    shift = util.by_pixel(0.75, 5.75),
                    scale = 0.9,
                    tint = constants.trainfactory_tint,
                }
            },
            {
                filename = "__trainfactory__/graphics/entity/trainfactory-half/trainfactory-half-shadow-ew.png",
                priority = "high",
                width = 68,
                height = 100,
                frame_count = 1,
                shift = { 0.421875, 0 },
                draw_as_shadow = true,
                scale = 1.8,
                tint = constants.trainfactory_tint,
                hr_version =
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-half/hr-trainfactory-half-shadow-ew.png",
                    priority = "high",
                    width = 111,
                    height = 171,
                    frame_count = 1,
                    draw_as_shadow = true,
                    shift = util.by_pixel(11.25, 7.75),
                    scale = 0.9,
                    tint = constants.trainfactory_tint,
                }
            }
        }
    },
}

trainfactory_half_entity.working_visualisations = {
    {
        render_layer = "higher-object-above",
        always_draw = true,
        north_animation = {
            layers =
            {
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-half/trainfactory-half-ns.png",
                    priority = "high",
                    width = 100,
                    height = 68,
                    frame_count = 1,
                    shift = { 0.421875, 0 },
                    scale = 1.8,
                    tint = constants.trainfactory_tint,
                    hr_version =
                    {
                        filename = "__trainfactory__/graphics/entity/trainfactory-half/hr-trainfactory-half-ns.png",
                        priority = "high",
                        width = 219,
                        height = 125,
                        frame_count = 1,
                        shift = util.by_pixel(0.75, 5.75),
                        scale = 0.9,
                        tint = constants.trainfactory_tint,
                    }
                },
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-half/trainfactory-half-shadow-ns.png",
                    priority = "high",
                    width = 100,
                    height = 68,
                    frame_count = 1,
                    shift = { 0.421875, 0 },
                    draw_as_shadow = true,
                    scale = 1.8,
                    tint = constants.trainfactory_tint,
                    hr_version =
                    {
                        filename = "__trainfactory__/graphics/entity/trainfactory-half/hr-trainfactory-half-shadow-ns.png",
                        priority = "high",
                        width = 171,
                        height = 111,
                        frame_count = 1,
                        draw_as_shadow = true,
                        shift = util.by_pixel(11.25, 7.75),
                        scale = 0.9,
                        tint = constants.trainfactory_tint,
                    }
                }
            }
        },
        south_animation = {
            layers =
            {
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-half/trainfactory-half-ns.png",
                    priority = "high",
                    width = 100,
                    height = 68,
                    frame_count = 1,
                    shift = { 0.421875, 0 },
                    scale = 1.8,
                    tint = constants.trainfactory_tint,
                    hr_version =
                    {
                        filename = "__trainfactory__/graphics/entity/trainfactory-half/hr-trainfactory-half-ns.png",
                        priority = "high",
                        width = 219,
                        height = 125,
                        frame_count = 1,
                        shift = util.by_pixel(0.75, 5.75),
                        scale = 0.9,
                        tint = constants.trainfactory_tint,
                    }
                },
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-half/trainfactory-half-shadow-ns.png",
                    priority = "high",
                    width = 100,
                    height = 68,
                    frame_count = 1,
                    shift = { 0.421875, 0 },
                    draw_as_shadow = true,
                    scale = 1.8,
                    tint = constants.trainfactory_tint,
                    hr_version =
                    {
                        filename = "__trainfactory__/graphics/entity/trainfactory-half/hr-trainfactory-half-shadow-ns.png",
                        priority = "high",
                        width = 171,
                        height = 111,
                        frame_count = 1,
                        draw_as_shadow = true,
                        shift = util.by_pixel(11.25, 7.75),
                        scale = 0.9,
                        tint = constants.trainfactory_tint,
                    }
                }
            }
        },
        east_animation = {
            layers =
            {
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-half/trainfactory-half-ew.png",
                    priority = "high",
                    width = 68,
                    height = 100,
                    frame_count = 1,
                    shift = { 0.421875, 0 },
                    scale = 1.8,
                    tint = constants.trainfactory_tint,
                    hr_version =
                    {
                        filename = "__trainfactory__/graphics/entity/trainfactory-half/hr-trainfactory-half-ew.png",
                        priority = "high",
                        width = 125,
                        height = 219,
                        frame_count = 1,
                        shift = util.by_pixel(0.75, 5.75),
                        scale = 0.9,
                        tint = constants.trainfactory_tint,
                    }
                },
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-half/trainfactory-half-shadow-ew.png",
                    priority = "high",
                    width = 68,
                    height = 100,
                    frame_count = 1,
                    shift = { 0.421875, 0 },
                    draw_as_shadow = true,
                    scale = 1.8,
                    tint = constants.trainfactory_tint,
                    hr_version =
                    {
                        filename = "__trainfactory__/graphics/entity/trainfactory-half/hr-trainfactory-half-shadow-ew.png",
                        priority = "high",
                        width = 111,
                        height = 171,
                        frame_count = 1,
                        draw_as_shadow = true,
                        shift = util.by_pixel(11.25, 7.75),
                        scale = 0.9,
                        tint = constants.trainfactory_tint,
                    }
                }
            }
        },
        west_animation = {
            layers =
            {
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-half/trainfactory-half-ew.png",
                    priority = "high",
                    width = 68,
                    height = 100,
                    frame_count = 1,
                    shift = { 0.421875, 0 },
                    scale = 1.8,
                    tint = constants.trainfactory_tint,
                    hr_version =
                    {
                        filename = "__trainfactory__/graphics/entity/trainfactory-half/hr-trainfactory-half-ew.png",
                        priority = "high",
                        width = 125,
                        height = 219,
                        frame_count = 1,
                        shift = util.by_pixel(0.75, 5.75),
                        scale = 0.9,
                        tint = constants.trainfactory_tint,
                    }
                },
                {
                    filename = "__trainfactory__/graphics/entity/trainfactory-half/trainfactory-half-shadow-ew.png",
                    priority = "high",
                    width = 68,
                    height = 100,
                    frame_count = 1,
                    shift = { 0.421875, 0 },
                    draw_as_shadow = true,
                    scale = 1.8,
                    tint = constants.trainfactory_tint,
                    hr_version =
                    {
                        filename = "__trainfactory__/graphics/entity/trainfactory-half/hr-trainfactory-half-shadow-ew.png",
                        priority = "high",
                        width = 111,
                        height = 171,
                        frame_count = 1,
                        draw_as_shadow = true,
                        shift = util.by_pixel(11.25, 7.75),
                        scale = 0.9,
                        tint = constants.trainfactory_tint,
                    }
                }
            }
        },
    }
}

data:extend({ trainfactory_half_entity })

local trainfactory_disassemble_full_entity = flib_table.deep_merge { trainfactory_entity, {
    name = constants.full_size_disassemble_entity_name,
    type = "furnace",
    source_inventory_size = 1,
    result_inventory_size = 20,
    minable = {
        result = constants.full_size_disassemble_placer_item_name,
    },
    placeable_by = {
        item = constants.full_size_disassemble_placer_item_name,
    },

    -- Resolve localization here so the placer entity can copy it
    localised_name = { "entity-name.trainfactory-disassemble-full-entity" },
    localised_description = { "entity-description.trainfactory-disassemble-full-entity" },

    -- Cannot interact with the fuel box as an output if we can pull out of the crafting machine
    flags = { "no-automated-item-insertion", "no-automated-item-removal" },

    animation = {
        north = {
            layers = {
                {
                    tint = constants.trainfactory_disassemble_tint,
                    hr_version = { tint = constants.trainfactory_tint },
                },
            }
        },
        south = {
            layers = {
                {
                    tint = constants.trainfactory_disassemble_tint,
                    hr_version = { tint = constants.trainfactory_tint },
                },
            }
        },
        east = {
            layers = {
                {
                    tint = constants.trainfactory_disassemble_tint,
                    hr_version = { tint = constants.trainfactory_tint },
                },
            }
        },
        west = {
            layers = {
                {
                    tint = constants.trainfactory_disassemble_tint,
                    hr_version = { tint = constants.trainfactory_tint },
                },
            }
        },
    },

    working_visualisations = {
        {
            north_animation = {
                layers =
                {
                    {
                        tint = constants.trainfactory_disassemble_tint,
                        hr_version = { tint = constants.trainfactory_disassemble_tint },
                    },
                }
            },
            south_animation = {
                layers =
                {
                    {
                        tint = constants.trainfactory_disassemble_tint,
                        hr_version = { tint = constants.trainfactory_disassemble_tint },
                    },
                }
            },
            east_animation = {
                layers =
                {
                    {
                        tint = constants.trainfactory_disassemble_tint,
                        hr_version = { tint = constants.trainfactory_disassemble_tint },
                    },
                }
            },
            west_animation = {
                layers =
                {
                    {
                        tint = constants.trainfactory_disassemble_tint,
                        hr_version = { tint = constants.trainfactory_disassemble_tint },
                    },
                }
            },
        }
    }
} }
trainfactory_disassemble_full_entity.crafting_categories = { constants.full_size_disassemble_recipe_category, }
data:extend({ trainfactory_disassemble_full_entity })

local trainfactory_disassemble_half_entity = flib_table.deep_merge { trainfactory_half_entity, {
    name = constants.half_size_disassemble_entity_name,
    type = "furnace",
    source_inventory_size = 1,
    result_inventory_size = 20,
    minable = {
        result = constants.half_size_disassemble_placer_item_name,
    },
    placeable_by = {
        item = constants.half_size_disassemble_placer_item_name,
    },

    -- Resolve localization here so the placer entity can copy it
    localised_name = { "entity-name.trainfactory-disassemble-half-entity" },
    localised_description = { "entity-description.trainfactory-disassemble-half-entity" },

    -- Cannot interact with the fuel box as an output if we can pull out of the crafting machine
    flags = { "no-automated-item-insertion", "no-automated-item-removal" },

    animation = {
        north = {
            layers = {
                {
                    tint = constants.trainfactory_disassemble_tint,
                    hr_version = { tint = constants.trainfactory_tint },
                },
            }
        },
        south = {
            layers = {
                {
                    tint = constants.trainfactory_disassemble_tint,
                    hr_version = { tint = constants.trainfactory_tint },
                },
            }
        },
        east = {
            layers = {
                {
                    tint = constants.trainfactory_disassemble_tint,
                    hr_version = { tint = constants.trainfactory_tint },
                },
            }
        },
        west = {
            layers = {
                {
                    tint = constants.trainfactory_disassemble_tint,
                    hr_version = { tint = constants.trainfactory_tint },
                },
            }
        },
    },

    working_visualisations = {
        {
            north_animation = {
                layers =
                {
                    {
                        tint = constants.trainfactory_disassemble_tint,
                        hr_version = { tint = constants.trainfactory_disassemble_tint },
                    },
                }
            },
            south_animation = {
                layers =
                {
                    {
                        tint = constants.trainfactory_disassemble_tint,
                        hr_version = { tint = constants.trainfactory_disassemble_tint },
                    },
                }
            },
            east_animation = {
                layers =
                {
                    {
                        tint = constants.trainfactory_disassemble_tint,
                        hr_version = { tint = constants.trainfactory_disassemble_tint },
                    },
                }
            },
            west_animation = {
                layers =
                {
                    {
                        tint = constants.trainfactory_disassemble_tint,
                        hr_version = { tint = constants.trainfactory_disassemble_tint },
                    },
                }
            },
        }
    }
} }
trainfactory_disassemble_half_entity.crafting_categories = { constants.half_size_disassemble_recipe_category, }
data:extend({ trainfactory_disassemble_half_entity })

------------------------------------------
----- FUEL AND EQUIPMENT CONTAINERS ------
------------------------------------------

local input_fuel_and_equipment_container = {
    type = "linked-container",
    name = constants.input_fuel_container_name,
    icon = "__base__/graphics/icons/iron-chest.png",
    icon_size = 64,
    flags = { "placeable-neutral", "player-creation", "not-blueprintable", "not-deconstructable", "placeable-off-grid" },
    max_health = 200,
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.5 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.5 },
    collision_mask = {},
    collision_box = { { -.8, -.5 }, { .8, .5 } },
    selection_box = { { -.8, -.5 }, { .8, .5 } },
    inventory_size = 1,
    gui_mode = "none",
    picture = {
        direction_count = 4,
        frame_count = 1,
        filename = "__trainfactory__/graphics/entity/empty.png",
        width = 1,
        height = 1,
        priority = "low",
    },
    selection_priority = 53,
}
data:extend({ input_fuel_and_equipment_container })

local input_fuel_and_equipment_container_horiz = flib_table.deep_merge { input_fuel_and_equipment_container, {
    name = constants.input_fuel_container_name_horiz,
    collision_box = { { -.5, -.8 }, { .5, .8 } },
    selection_box = { { -.5, -.8 }, { .5, .8 } },
}}
data:extend({ input_fuel_and_equipment_container_horiz })

------------------------------------------
----- DISASSEMBLY OUTPUT CONTAINER  ------
------------------------------------------

local output_container_full = flib_table.deep_merge { input_fuel_and_equipment_container, {
    name = constants.output_container_name_full,
    inventory_size = 20,
    collision_box = { { -.8, -3.0 }, { .8, 3.0 } },
    selection_box = { { -.8, -3.0 }, { .8, 3.0 } },
    placeable_by = {
        item = constants.full_size_placer_item_name,
        count = 1,
    },
}}
data:extend({ output_container_full })

local output_container_half = flib_table.deep_merge { output_container_full, {
    name = constants.output_container_name_half,
    collision_box = { { -.8, -1.0 }, { .8, 1.0 } },
    selection_box = { { -.8, -1.0 }, { .8, 1.0 } },
    placeable_by = {
        item = constants.half_size_placer_item_name,
        count = 1,
    },
}}
data:extend({ output_container_half })

local output_container_full_horiz = flib_table.deep_merge { input_fuel_and_equipment_container, {
    name = constants.output_container_name_full_horiz,
    inventory_size = 20,
    collision_box = { { -3.0, -0.8 }, { 3.0, 0.8 } },
    selection_box = { { -3.0, -0.8 }, { 3.0, 0.8 } },
}}
data:extend({ output_container_full_horiz })

local output_container_half_horiz = flib_table.deep_merge { output_container_full, {
    name = constants.output_container_name_half_horiz,
    collision_box = { { -1.0, -0.8 }, { 1.0, 0.8 } },
    selection_box = { { -1.0, -0.8 }, { 1.0, 0.8 } },
}}
data:extend({ output_container_half_horiz })

------------------------------------------
------------ INTEGRATED STOP  ------------
------------------------------------------

local integrated_stop = flib_table.deep_merge { data.raw["train-stop"]["train-stop"], {
    name = constants.integrated_stop_name,
    icon = "__base__/graphics/icons/iron-chest.png",
    icon_size = 64,
    flags = { "placeable-neutral", "player-creation", "not-blueprintable", "not-deconstructable", "placeable-off-grid" },
    selectable_in_game = false,
}}
integrated_stop.minable = nil
data:extend({ integrated_stop })