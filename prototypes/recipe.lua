local constants = require("constants")

data:extend {
    {
        type = "recipe",
        name = "trainfactory-full",
        category = "advanced-crafting",
        normal =
        {
            enabled = false,
            energy_required = 30,
            ingredients =
            {
                { "fast-inserter", 10 },
                { "assembling-machine-1", 1 },
                { "rail", 50 },
                { "electronic-circuit", 10 }
            },
            results =
            {
                {
                    type   = "item",
                    name   = constants.full_size_placer_item_name,
                    amount = 1,
                },
            },
        },
    }, {
        type = "recipe",
        name = "trainfactory-half",
        category = "advanced-crafting",
        normal =
        {
            enabled = false,
            energy_required = 30,
            ingredients =
            {
                { "fast-inserter", 10 },
                { "assembling-machine-1", 1 },
                { "rail", 50 },
                { "electronic-circuit", 10 }
            },
            results =
            {
                {
                    type   = "item",
                    name   = constants.half_size_placer_item_name,
                    amount = 1,
                },
            },
        },
    },
    {
        type = "recipe",
        name = "trainfactory-disassemble-full",
        category = "advanced-crafting",
        normal =
        {
            enabled = false,
            energy_required = 30,
            ingredients =
            {
                { "fast-inserter", 10 },
                { "assembling-machine-1", 1 },
                { "rail", 50 },
                { "electronic-circuit", 10 }
            },
            results =
            {
                {
                    type   = "item",
                    name   = constants.full_size_disassemble_placer_item_name,
                    amount = 1,
                },
            },
        },
    }, {
        type = "recipe",
        name = "trainfactory-disassemble-half",
        category = "advanced-crafting",
        normal =
        {
            enabled = false,
            energy_required = 30,
            ingredients =
            {
                { "fast-inserter", 10 },
                { "assembling-machine-1", 1 },
                { "rail", 50 },
                { "electronic-circuit", 10 }
            },
            results =
            {
                {
                    type   = "item",
                    name   = constants.half_size_disassemble_placer_item_name,
                    amount = 1,
                },
            },
        },
    },
}
