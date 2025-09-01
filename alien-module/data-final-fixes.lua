local loot_to_add = { "artifact-ore" }

function RampantAddLootToCategory(category, c_max)
    for name, table_entry in pairs(data.raw[category]) do
        v, tier = string.match(name, "%-v(%d+)%-t(%d+)%-rampant")
        if v ~= nil and tier ~= nil then
            if table_entry.loot == nil then
                table_entry.loot = {}
            end
            for _, loot in pairs(loot_to_add) do
                local already_has_loot = false
                for _, loot_entry in pairs(table_entry.loot) do
                    if loot_entry.item == loot then
                        already_has_loot = true
                    end
                end
                if not already_has_loot then
                    table.insert(table_entry.loot, {
                        item = loot,
                        probability = 1,
                        count_min = 1,
                        count_max = c_max * tier,
                    })
                    -- log("added loot " .. loot .. " (" .. p .. "," .. c_min .. "," .. c_max .. ") to " .. name)
                else
                    -- log("skipping loot " .. loot .. " for " .. name)
                end

                log(name .. "current loot " .. serpent.line(table_entry.loot))
            end
        end
    end
end

RampantAddLootToCategory("turret", settings.startup["rampant-alienmodule-compat-max-count-turret"].value)
RampantAddLootToCategory("unit-spawner", settings.startup["rampant-alienmodule-compat-max-count-spawner"].value)


if (settings.startup["alien-module-productivity-everything"].value) then
    -- Allow Hyper Modules in any recipe (Cheaty)
    for _, recipe in pairs(data.raw.recipe) do
        recipe.allow_productivity = true
    end
end

-- Modded ore conversion recipes based on dynamic discovery
local ore_categories = require("prototypes.recipe.ore-conversions")
local nauvis_ores = ore_categories.nauvis_ores
local vulcanus_ores = ore_categories.vulcanus_ores
local fulgora_scrap_ores = ore_categories.fulgora_scrap_ores

-- Function to create conversion recipe for modded ores
local function create_modded_ore_recipe(ore_name)
    local recipe_name = "alien-ore-to-" .. ore_name
    -- Skip if recipe already exists
    if data.raw.recipe[recipe_name] then
        return
    end

    data:extend({
        {
            type = "recipe",
            name = recipe_name,
            enabled = true,
            energy_required = 20,
            ingredients = { { type = "item", name = "artifact-ore", amount = 2 } },
            results = { { type = "item", name = ore_name, amount = 1 } },
            auto_recycle = not settings.startup["alien-module-ore-recycle-to-alien"].value,
            localised_name = {
                "?",  -- fallback option
                {"recipe-name.alien-ore-conversion-template", {"item-name." .. ore_name}},
                {"recipe-name.alien-ore-conversion-template", ore_name}
            }
        }
    })
end

-- Collect all mineable ore names from resources for modded content
local all_ores = {}
for _, resource_data in pairs(data.raw.resource) do
    if not resource_data.minable then
        goto continue
    end

    -- normalize the data structure (mineable resources can return 1 or more ores)
    local results
    if resource_data.minable.results then
        results = resource_data.minable.results
    elseif resource_data.minable.result then
        results = {{name = resource_data.minable.result, amount = resource_data.minable.count or 1}}
    else
        goto continue
    end

    for _, result in pairs(results) do
        local ore_name = result.name or result[1]
        if ore_name and data.raw.item[ore_name] then
            all_ores[ore_name] = true
        end
    end

    ::continue::
end

-- Generate recipes for modded ores only
for ore_name, _ in pairs(all_ores) do
    -- Skip base game ores (handled in ore-conversions.lua)
    if nauvis_ores[ore_name] or vulcanus_ores[ore_name] or fulgora_scrap_ores[ore_name] then
        goto continue
    end

    -- Check if we should create recipe for this ore
    if settings.startup["alien-module-modded-scrap-conversion"].value and string.find(string.lower(ore_name), "scrap") then
        create_modded_ore_recipe(ore_name)
    elseif settings.startup["alien-module-modded-ore-conversion"].value then
        create_modded_ore_recipe(ore_name)
    end

    ::continue::
end
