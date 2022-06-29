local flib_table = require("__flib__.table")
local constants = require("constants")

local items_resulting_in_full_size_entities = {}
local items_resulting_in_half_size_entities = {}

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

-- Find the technology that unlocks straight-rail and move in
for _,tech in pairs(data.raw.technology) do
    for _,effect in pairs(tech.effects or {}) do
        if effect.type == "unlock-recipe" and effect.recipe == "rail" then
            table.insert(tech.effects, #tech.effects+1, {
                type = "unlock-recipe",
                recipe = "trainfactory-full",
            })
            table.insert(tech.effects, #tech.effects+1, {
                type = "unlock-recipe",
                recipe = "trainfactory-half",
            })
        end
    end
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
for _, recipe in pairs(data.raw["recipe"]) do
    for _, full_size_item in pairs(items_resulting_in_full_size_entities) do
        if recipe_makes_item(recipe, full_size_item.name) then
            recipe.category = constants.full_size_recipe_category
            recipe.hide_from_player_crafting = true
        end
    end
    for _, half_size_item in pairs(items_resulting_in_half_size_entities) do
        if recipe_makes_item(recipe, half_size_item.name) then
            recipe.category = constants.half_size_recipe_category
            recipe.hide_from_player_crafting = true
        end
    end
end

require("prototypes.modded-updates")
