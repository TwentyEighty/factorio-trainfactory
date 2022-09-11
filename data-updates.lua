local flib_table = require("__flib__.table")
local flib_data = require("__flib__.data-util")
local constants = require("constants")

local items_resulting_in_full_size_entities = {}
local items_resulting_in_half_size_entities = {}

local function normalize_recipe_result(recipe)
    if recipe.results then return recipe.results end
    return {
        { recipe.result, recipe.result_count or 1 },
    }
end

local function recipe_makes_item(recipe, item_name)
    if recipe.results then
        for _, result in pairs(recipe.results) do
            if result[1] == item_name or result.name == item_name then
                return true
            end
        end
    elseif recipe.result == item_name then
        return true
    end

    return false
end

-- First, find all items that produce the desired rolling-stock entities
for _, train_type in pairs({ "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon" }) do
    for _, entity in pairs(data.raw[train_type]) do
        -- Find the item that produces this entity
        local item_name = entity.minable and entity.minable.result
        local item = data.raw["item-with-entity-data"][item_name] or data.raw["item"][item_name]

        if item_name then
            if entity.connection_distance == 3 and entity.joint_distance == 4 then
                items_resulting_in_full_size_entities = flib_table.array_merge { items_resulting_in_full_size_entities,
                    {{
                        name = item_name,
                        item = item,
                    }}
                }
                -- item.place_result = nil
            elseif entity.connection_distance == 2 and entity.joint_distance == 1.5 then
                items_resulting_in_half_size_entities = flib_table.array_merge { items_resulting_in_half_size_entities,
                    {{
                        name = item_name,
                        item = item,
                    }}
                }
                -- item.place_result = nil
            end
        end
    end
end


-- Now find all recipes that produce these items
-- Make the inverse furnace recipes for the train disassembler factory
local new_recipes = {}
local full_size_recipe_names = {}
local max_full_ingredients = 1
local half_size_recipe_names = {}
local max_half_ingredients = 1
for _, recipe in pairs(data.raw["recipe"]) do
    for _, full_size_item in pairs(items_resulting_in_full_size_entities) do
        if recipe_makes_item(recipe, full_size_item.name) then
            recipe.category = constants.full_size_recipe_category
            recipe.energy_required = constants.energy_required
            local new_recipe = flib_table.deep_merge{recipe, {
                type = "recipe",
                name = string.format("%s-disassemble", recipe.name),
                category = constants.full_size_disassemble_recipe_category,
                localised_name = {"recipe-name.disassembly", {string.format("entity-name.%s", full_size_item.name)}}
            }}
            new_recipe.ingredients = normalize_recipe_result(recipe)
            new_recipe.result = nil
            new_recipe.results = {}
            for _, result in pairs(recipe.ingredients) do
                local name = result.name or result[1]
                local type = result.type or "item"
                local amount = result.amount or result[2] or 1
                table.insert(new_recipe.results,
                    {
                        name = name,
                        type = type,
                        amount = math.ceil(amount * constants.disassembly_efficiency)
                    }
                )
            end
            new_recipe.icons = flib_data.create_icons(full_size_item.item)
            if not new_recipe.subgroup then new_recipe.subgroup = full_size_item.item.subgroup end
            table.insert(new_recipes, new_recipe)

            full_size_recipe_names[recipe.name] = new_recipe.name
            max_full_ingredients = math.max(max_full_ingredients, #recipe.ingredients)
        end
    end
    for _, half_size_item in pairs(items_resulting_in_half_size_entities) do
        if recipe_makes_item(recipe, half_size_item.name) then
            recipe.category = constants.half_size_recipe_category
            recipe.energy_required = constants.energy_required
            local new_recipe = flib_table.deep_merge{recipe, {
                type = "recipe",
                name = string.format("%s-disassemble", recipe.name),
                category = constants.half_size_disassemble_recipe_category,
                localised_name = {"recipe-name.disassembly", {string.format("entity-name.%s", half_size_item.name)}}
            }}
            new_recipe.ingredients = normalize_recipe_result(recipe)
            new_recipe.result = nil
            new_recipe.results = {}
            for _, result in pairs(recipe.ingredients) do
                local name = result.name or result[1]
                local type = result.type or "item"
                local amount = result.amount or result[2] or 1
                table.insert(new_recipe.results,
                    {
                        name = name,
                        type = type,
                        amount = math.ceil(amount * constants.disassembly_efficiency)
                    }
                )
            end
            new_recipe.icons = flib_data.create_icons(half_size_item.item)
            if not new_recipe.subgroup then new_recipe.subgroup = half_size_item.item.subgroup end
            table.insert(new_recipes, new_recipe)

            half_size_recipe_names[recipe.name] = new_recipe.name
            max_half_ingredients = math.max(max_half_ingredients, #recipe.ingredients)
        end
    end
end
data:extend(new_recipes)

-- Limit the output of the disassembler furnace to be as small as possible
data.raw["furnace"][constants.full_size_disassemble_entity_name].result_inventory_size = max_full_ingredients
data.raw["furnace"][constants.half_size_disassemble_entity_name].result_inventory_size = max_half_ingredients

for _,tech in pairs(data.raw.technology) do
    for _,effect in pairs(tech.effects or {}) do
        if effect.type == "unlock-recipe" then
            -- Find the technology that unlocks straight-rail and move the factory machines
            -- into it
            if effect.recipe == "rail" then
                table.insert(tech.effects, #tech.effects+1, {
                    type = "unlock-recipe",
                    recipe = "trainfactory-full",
                })
                table.insert(tech.effects, #tech.effects+1, {
                    type = "unlock-recipe",
                    recipe = "trainfactory-half",
                })
                table.insert(tech.effects, #tech.effects+1, {
                    type = "unlock-recipe",
                    recipe = "trainfactory-disassemble-full",
                })
                table.insert(tech.effects, #tech.effects+1, {
                    type = "unlock-recipe",
                    recipe = "trainfactory-disassemble-half",
                })
            elseif full_size_recipe_names[effect.recipe] ~= nil then
                table.insert(tech.effects, #tech.effects+1, {
                    type = "unlock-recipe",
                    recipe = full_size_recipe_names[effect.recipe]
                })
            elseif half_size_recipe_names[effect.recipe] ~= nil then
                table.insert(tech.effects, #tech.effects+1, {
                    type = "unlock-recipe",
                    recipe = half_size_recipe_names[effect.recipe]
                })
            end
        end
    end
end

require("prototypes.modded-updates")
