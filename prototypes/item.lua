local flib_table = require("__flib__.table")
local flib_data = require("__flib__.data-util")
local constants = require("constants")

local trainfactory_placer_item = flib_table.deep_merge { data.raw["item"]["rail-signal"], {
    name = constants.full_size_placer_item_name,
    icons = flib_data.create_icons(data.raw["item-with-entity-data"]["locomotive"], { {
        icon = "__base__/graphics/icons/assembling-machine-1.png",
        icon_size = 64, icon_mipmaps = 4,
        scale = 0.25,
        shift = { -8, -8 },
    }, {
        icon = "__base__/graphics/icons/signal/signal_F.png",
        icon_size = 64, icon_mipmaps = 4,
        scale = 0.25,
        shift = { 8, -8 },
    } }),
    subgroup = "trainfactory",
    order = "a",
    place_result = constants.full_size_placer_entity_name,
    stack_size = 10,
} }

data:extend({ trainfactory_placer_item })

local trainfactory_half_placer_item = flib_table.deep_merge { data.raw["item"]["rail-signal"],
    {
        name = constants.half_size_placer_item_name,
        icons = flib_data.create_icons(data.raw["item-with-entity-data"]["locomotive"], { {
            icon = "__base__/graphics/icons/assembling-machine-1.png",
            icon_size = 64, icon_mipmaps = 4,
            scale = 0.25,
            shift = { -8, -8 },
        }, {
            icon = "__base__/graphics/icons/signal/signal_H.png",
            icon_size = 64, icon_mipmaps = 4,
            scale = 0.25,
            shift = { 8, -8 },
        } }),
        subgroup = "trainfactory",
        order = "b",
        place_result = constants.half_size_placer_entity_name,
        stack_size = 10,
    }
}

data:extend({ trainfactory_half_placer_item })

local trainfactory_disassemble_placer_item = flib_table.deep_merge { data.raw["item"]["rail-signal"], {
    name = constants.full_size_disassemble_placer_item_name,
    icons = flib_data.create_icons(data.raw["item-with-entity-data"]["locomotive"], { {
        icon = "__base__/graphics/icons/deconstruction-planner.png",
        icon_size = 64, icon_mipmaps = 4,
        scale = 0.25,
        shift = { -8, -8 },
    }, {
        icon = "__base__/graphics/icons/signal/signal_F.png",
        icon_size = 64, icon_mipmaps = 4,
        scale = 0.25,
        shift = { 8, -8 },
    } }),
    subgroup = "trainfactory",
    order = "c",
    place_result = constants.full_size_disassemble_placer_entity_name,
    stack_size = 10,
} }

data:extend({ trainfactory_disassemble_placer_item })

local trainfactory_disassemble_half_placer_item = flib_table.deep_merge { data.raw["item"]["rail-signal"], {
    name = constants.half_size_disassemble_placer_item_name,
    icons = flib_data.create_icons(data.raw["item-with-entity-data"]["locomotive"], { {
        icon = "__base__/graphics/icons/deconstruction-planner.png",
        icon_size = 64, icon_mipmaps = 4,
        scale = 0.25,
        shift = { -8, -8 },
    }, {
        icon = "__base__/graphics/icons/signal/signal_H.png",
        icon_size = 64, icon_mipmaps = 4,
        scale = 0.25,
        shift = { 8, -8 },
    } }),
    subgroup = "trainfactory",
    order = "d",
    place_result = constants.half_size_disassemble_placer_entity_name,
    stack_size = 10,
} }

data:extend({ trainfactory_disassemble_half_placer_item })
